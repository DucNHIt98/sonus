import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/presentation/providers/home_provider.dart';
import 'package:sonus/features/search/data/services/ai_recommend_service.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/core/network/supabase_repository.dart';


part 'player_controller.freezed.dart';
part 'player_controller.g.dart';

@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    @Default([]) List<Home> queue,
    @Default(-1) int currentIndex,
    Home? currentSong,
    @Default(false) bool isPlaying,
    @Default(false) bool isLoading,
    String? error,
    @Default([]) List<Home> aiRecommendations,
    @Default(LoopMode.off) LoopMode repeatMode,
    @Default(false) bool isShuffleModeEnabled,
  }) = _PlayerState;
}

@Riverpod(keepAlive: true)
class PlayerController extends _$PlayerController {
  late AudioPlayer _audioPlayer;
  late ConcatenatingAudioSource _playlist;
  Timer? _syncTimer; // Timer for periodic state sync
  bool _hasCountedPlay =
      false; // Track if current song has been counted for most played

  @override
  PlayerState build() {
    _audioPlayer = AudioPlayer(
      audioLoadConfiguration: const AudioLoadConfiguration(
        androidLoadControl: AndroidLoadControl(
          minBufferDuration: Duration(seconds: 1),
          bufferForPlaybackDuration: Duration(seconds: 1),
        ),
        darwinLoadControl: DarwinLoadControl(
          automaticallyWaitsToMinimizeStalling: true,
          preferredForwardBufferDuration: Duration(seconds: 1),
        ),
      ),
    );

    _playlist = ConcatenatingAudioSource(
      children: [],
      useLazyPreparation:
          true, // CRITICAL: This ensures proper per-song tracking
    );

    _audioPlayer.setAudioSource(_playlist).catchError((e) => null);
    _audioPlayer.setLoopMode(LoopMode.off);

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (state.isPlaying != playerState.playing) {
        state = state.copyWith(isPlaying: playerState.playing);
      }
    });

    _audioPlayer.loopModeStream.listen((loopMode) {
      state = state.copyWith(repeatMode: loopMode);
    });

    // CRITICAL FIX: Intercept system shuffle commands to prevent RangeError
    // We manage shuffle manually (queue reordering) because native shuffle
    // crashes with Lazy Loading (RangeError: Invalid value: Not in inclusive range 0..1: 2).
    _audioPlayer.shuffleModeEnabledStream.listen((isEnabled) {
      if (isEnabled) {
        // 1. Force native player back to linear mode immediately to prevent crash
        _audioPlayer.setShuffleModeEnabled(false);

        // 2. Treat this as a toggle request for our manual shuffle logic
        toggleShuffle();
      }
    });
    try {
      if (_playlist.length > 0) {
        _audioPlayer.setShuffleModeEnabled(false);
      }
    } catch (e) {
      print('DEBUG: PlayerController - Error disabling shuffle on init: $e');
    }

    _audioPlayer.playbackEventStream.listen((event) {
      final eventIndex = event.currentIndex;
      if (eventIndex != null &&
          eventIndex != state.currentIndex &&
          eventIndex < state.queue.length) {
        final newSong = state.queue[eventIndex];
        state = state.copyWith(currentIndex: eventIndex, currentSong: newSong);

        // Update History
        ref.read(supabaseRepositoryProvider).updateLastPlayed(newSong);

        // Invalidate Home Controller to refresh Recently Played list
        ref.invalidate(homeControllerProvider);

        // Reset count flag for new song
        _hasCountedPlay = false;

        _preloadNextSong();
        if (newSong.source == 'youtube' || newSong.youtubeId != null) {
          fetchAiRecommendations();
        }
      }
    });

    // AUTO-SKIP on Error
    _audioPlayer.playbackEventStream.listen(
      (event) {},
      onError: (Object e, StackTrace st) {
        if (e is PlayerException) {
          print('DEBUG: PlayerException caught: ${e.message}');
        } else {
          print('DEBUG: Player error caught: $e');
        }

        // Automatically skip to next song if current song fails
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleAndSkipError();
        });
      },
    );

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < state.queue.length) {
        final shouldUpdate =
            index != state.currentIndex ||
            state.currentSong?.id != state.queue[index].id;

        if (shouldUpdate) {
          state = state.copyWith(
            currentIndex: index,
            currentSong: state.queue[index],
          );

          // Update History
          ref
              .read(supabaseRepositoryProvider)
              .updateLastPlayed(state.queue[index]);

          // Invalidate Home Controller to refresh Recently Played list
          ref.invalidate(homeControllerProvider);

          // Reset count flag for new song
          _hasCountedPlay = false;

          _preloadNextSong();
          if (state.queue[index].source == 'youtube' ||
              state.queue[index].youtubeId != null) {
            fetchAiRecommendations();
          }
        }
      }
    });

    _audioPlayer.sequenceStateStream.listen((sequenceState) {
      if (sequenceState?.currentSource?.tag != null) {
        try {
          final tag = sequenceState!.currentSource!.tag as MediaItem;
          final playingSongId = tag.id;

          if (state.currentSong?.id != playingSongId) {
            final queueIndex = state.queue.indexWhere(
              (s) => s.id == playingSongId,
            );
            if (queueIndex != -1) {
              state = state.copyWith(
                currentIndex: queueIndex,
                currentSong: state.queue[queueIndex],
              );
              // Reset count flag for new song
              _hasCountedPlay = false;

              _preloadNextSong();
              if (state.queue[queueIndex].source == 'youtube' ||
                  state.queue[queueIndex].youtubeId != null) {
                fetchAiRecommendations();
              }
            }
          }
        } catch (_) {}
      }
    });

    _audioPlayer.positionStream.listen((position) {
      final duration = _audioPlayer.duration;
      if (duration != null && (duration - position).inSeconds < 15) {
        _preloadNextSong();
      }

      final metaDur = state.currentSong?.duration ?? Duration.zero;

      // LOGIC: Increment play count if reached 50%
      if (!_hasCountedPlay &&
          metaDur.inSeconds > 0 &&
          position.inSeconds >= (metaDur.inSeconds / 2)) {
        _hasCountedPlay = true;
        if (state.currentSong != null) {
          ref
              .read(supabaseRepositoryProvider)
              .upsertPlayHistory(state.currentSong!);
        }
      }

      if (metaDur.inSeconds > 0 && position.inSeconds > metaDur.inSeconds)
        return;

      try {
        final sequenceState = _audioPlayer.sequenceState;
        if (sequenceState?.currentSource?.tag != null) {
          final tag = sequenceState!.currentSource!.tag as MediaItem;
          final playingSongId = tag.id;

          if (state.currentSong?.id != playingSongId) {
            final queueIndex = state.queue.indexWhere(
              (s) => s.id == playingSongId,
            );
            if (queueIndex != -1) {
              state = state.copyWith(
                currentIndex: queueIndex,
                currentSong: state.queue[queueIndex],
              );
            }
          }
        }
      } catch (_) {}
    });

    _audioPlayer.processingStateStream.listen((processingState) async {
      if (processingState == ProcessingState.completed) {
        // FIX: Handle Repeat One manually to ensure UI sync
        if (state.repeatMode == LoopMode.one) {
          // FIX: Toggle LoopMode to force internal state/position stream reset
          await _audioPlayer.setLoopMode(LoopMode.off);
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.setLoopMode(LoopMode.one);
          _audioPlayer.play();
          return;
        }

        if (_audioPlayer.hasNext) {
          await _audioPlayer.seekToNext();
          _audioPlayer.play();

          final newIndex = _audioPlayer.currentIndex;
          if (newIndex != null && newIndex < state.queue.length) {
            state = state.copyWith(
              currentIndex: newIndex,
              currentSong: state.queue[newIndex],
            );
          }
        } else if (state.currentIndex + 1 < state.queue.length) {
          await _preloadNextSong();
          if (_audioPlayer.hasNext) {
            await _audioPlayer.seekToNext();
            _audioPlayer.play();

            final newIndex = _audioPlayer.currentIndex;
            if (newIndex != null && newIndex < state.queue.length) {
              state = state.copyWith(
                currentIndex: newIndex,
                currentSong: state.queue[newIndex],
              );
            }
          }
        }
      }
    });

    // Position tracking for song transition detection
    int _advancedFromIndex =
        -1; // Track which index we've already advanced from

    // TIMER-BASED SYNC: Use METADATA duration to detect song transitions
    // (YouTube audio streams can have incorrect duration from certain clients)
    // Reduce interval to 50ms for near-instant repeat detection
    _syncTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      try {
        final position = _audioPlayer.position;
        final stateIndex = state.currentIndex;
        final queueLen = state.queue.length;
        final metadataDuration = state.currentSong?.duration ?? Duration.zero;

        if (metadataDuration.inMilliseconds > 0 &&
            position.inMilliseconds >= metadataDuration.inMilliseconds &&
            _advancedFromIndex != stateIndex) {
          // FIX: Handle Repeat One manually in timer as watchdog
          if (state.repeatMode == LoopMode.one) {
            // Only force seek if metadata is valid AND we are past it
            // Use milliseconds for precision
            if (metadataDuration.inMilliseconds > 0 &&
                position.inMilliseconds > metadataDuration.inMilliseconds) {
              _audioPlayer.seek(Duration.zero);
            }
            return;
          }

          _advancedFromIndex = stateIndex;
          final nextIndex = stateIndex + 1;
          if (nextIndex < queueLen) {
            final newSong = state.queue[nextIndex];
            state = state.copyWith(
              currentIndex: nextIndex,
              currentSong: newSong,
            );

            if (nextIndex < _playlist.length) {
              _audioPlayer.seek(Duration.zero, index: nextIndex);
            } else {
              playSong(newSong);
            }

            _preloadNextSong();
            if (newSong.source == 'youtube' || newSong.youtubeId != null) {
              fetchAiRecommendations();
            }
          }
        }
      } catch (_) {}
    });

    ref.onDispose(() {
      print("DEBUG: PlayerController DISPOSED (Hash: ${hashCode})");
      _syncTimer?.cancel();
      _audioPlayer.dispose();
    });
    return const PlayerState();
  }

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Home> get queue => state.queue;
  Home? get currentSong => state.currentSong;

  // Track the index of the last song added to the actual _playlist audio source
  int _lastLoadedIndex = -1;
  bool _isPreloading = false;
  List<Home> _originalQueue = []; // Store original queue for un-shuffle

  /// Preload the next song in the queue if it hasn't been added to _playlist yet
  Future<void> _preloadNextSong() async {
    if (_isPreloading) return;

    _isPreloading = true;
    try {
      // Preload up to 2 songs ahead
      for (int offset = 1; offset <= 2; offset++) {
        final nextIndex = state.currentIndex + offset;
        if (nextIndex >= state.queue.length) break;
        // Check if already loaded
        if (_lastLoadedIndex >= nextIndex) continue;

        final nextSong = state.queue[nextIndex];
        final audioSource = await _createAudioSource(nextSong);

        if (audioSource != null) {
          final currentPlaylistLen = _playlist.length;
          if (currentPlaylistLen == _lastLoadedIndex + 1) {
            await _playlist.add(audioSource);
            _lastLoadedIndex = nextIndex;
          }
        }
      }

      // If queue is running low, fetch related songs to refill
      final remaining = state.queue.length - state.currentIndex;
      if (remaining <= 3 && state.currentSong != null) {
        _fetchRelatedSongs(state.currentSong!);
      }
    } catch (e) {
      print('DEBUG: Error preloading song: $e');
    } finally {
      _isPreloading = false;
    }
  }

  Future<void> _fetchRelatedSongs(Home seedSong) async {
    try {
      final backend = ref.read(backendServiceProvider);
      final results = await backend.getRelatedSongs(seedSong.id);
      if (results.isEmpty) return;

      final newSongs = results
          .where((m) => !state.queue.any((h) => h.id == m.id))
          .map((m) => m.toEntity())
          .toList();
      if (newSongs.isEmpty) return;

      state = state.copyWith(queue: [...state.queue, ...newSongs]);
    } catch (e) {
      print('DEBUG: Error fetching related songs: $e');
    }
  }
        }
      }

      // If queue is running low, fetch related songs to refill
      final remaining = state.queue.length - state.currentIndex;
      if (remaining <= 3 && state.currentSong != null) {
        _fetchRelatedSongs(state.currentSong!);
      }
    } catch (e) {
      print('DEBUG: Error preloading song: $e');
    } finally {
      _isPreloading = false;
    }
  }

  Future<void> _fetchRelatedSongs(Home seedSong) async {
    try {
      final backend = ref.read(backendServiceProvider);
      final results = await backend.getRelatedSongs(seedSong.id);
      if (results.isEmpty) return;

      final newSongs = results
          .where((m) => !state.queue.any((h) => h.id == m.id))
          .map((m) => m.toEntity())
          .toList();
      if (newSongs.isEmpty) return;

      state = state.copyWith(queue: [...state.queue, ...newSongs]);
    } catch (e) {
      print('DEBUG: Error fetching related songs: $e');
    }
  }

  /// Fetch songs from the current artist's channel and add to queue
  Future<void> fetchAndQueueArtistSongs(Home currentSong) async {
    print(
      'DEBUG: Fetching artist songs for auto-queue: ${currentSong.subtitle}',
    );

    try {
      final artistName = currentSong.subtitle;
      final backend = ref.read(backendServiceProvider);
      final results = await backend.search(
        query: '$artistName official audio',
        limit: 20,
        sources: 'youtube',
      );

      if (results.isEmpty) return;

      final currentQueueIds = state.queue
          .map((s) => s.youtubeId ?? s.id)
          .toSet();

      final newSongs = results
          .where((m) => !currentQueueIds.contains(m.id))
          .map((m) => m.toEntity())
          .toList();

      if (newSongs.isEmpty) return;

      print(
        'DEBUG: Adding ${newSongs.length} songs from artist to queue (state only, lazy loading audio)',
      );

      // ONLY add to queue state - DO NOT add to _playlist here!
      // Let _preloadNextSong() handle lazy loading of audio sources one at a time
      final updatedQueue = [...state.queue, ...newSongs];
      state = state.copyWith(queue: updatedQueue);

      // Trigger preload for the next song only
      _preloadNextSong();
    } catch (e) {
      print('DEBUG: Error auto-queuing artist songs: $e');
    }
  }

  /// Add a song to the end of the queue
  Future<void> addToQueue(Home song) async {
    print("DEBUG: addToQueue - ${song.title}");

    final newQueue = [...state.queue, song];
    state = state.copyWith(queue: newQueue);

    // Resolve URL and add to playlist
    final audioSource = await _createAudioSource(song);
    if (audioSource != null) {
      await _playlist.add(audioSource);
    }
  }

  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    // Cannot remove currently playing song via this method for safety
    if (index == state.currentIndex) return;

    final newQueue = List<Home>.from(state.queue);
    newQueue.removeAt(index);

    // Remove from playlist
    await _playlist.removeAt(index);

    // Update state
    // If we removed a song before current, currentIndex decreases
    int newIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newIndex--;
    }

    state = state.copyWith(queue: newQueue, currentIndex: newIndex);
  }

  Future<void> clearQueue() async {
    // Keep current song
    if (state.currentSong == null) {
      state = state.copyWith(queue: [], currentIndex: -1);
      _playlist = ConcatenatingAudioSource(children: []);
      await _audioPlayer.setAudioSource(_playlist);
      return;
    }

    final current = state.currentSong!;
    state = state.copyWith(queue: [current], currentIndex: 0);

    // Re-init playlist with just current
    final source = await _createAudioSource(current);
    if (source != null) {
      _playlist = ConcatenatingAudioSource(children: [source]);
      await _audioPlayer.setAudioSource(_playlist);
    } else {
      _playlist = ConcatenatingAudioSource(children: []);
      await _audioPlayer.setAudioSource(_playlist);
    }
  }

  /// Play a song immediately, adding it to queue if not present
  Future<void> playSelectedSongWithMetadata(
    Home metadata, {
    List<Home>? contextQueue,
  }) async {
    print("DEBUG: playSelectedSongWithMetadata - ${metadata.title}");
    await playSong(metadata, contextQueue: contextQueue);
  }

  Future<void> playMusicModel(
    MusicModel model, {
    List<MusicModel>? contextQueue,
  }) async {
    await playSong(
      model.toEntity(),
      contextQueue: contextQueue?.map((m) => m.toEntity()).toList(),
    );
  }

  Future<void> playSong(Home song, {List<Home>? contextQueue}) async {
    try {
      // 1. Handle Hybrid Logic based on Source
      if (song.source == 'deezer_preview' && song.youtubeId == null) {
        // ... (existing Deezer resolution logic)
        print("DEBUG: Resolving full version for Deezer track: ${song.title}");
        Home? resolvedSong;
        try {
          final backendService = ref.read(backendServiceProvider);
          resolvedSong = await backendService.getFullVersion(song);
        } catch (e) {
          print("DEBUG: Backend resolution failed: $e");
        }

        if (resolvedSong != null) {
          song = resolvedSong;
          print("DEBUG: Successfully resolved full version: ${song.youtubeId}");
        } else {
          print("DEBUG: Falling back to 30s preview for: ${song.title}");
        }
      } else if (song.source == 'jamendo' || song.source == 'jamendo_preview') {
      }

      // 2. Standard Playback Logic
      await _audioPlayer.stop();

      state = state.copyWith(isLoading: true, error: null);

      // Check for Context Queue or existing queue
      if (contextQueue != null && contextQueue.isNotEmpty) {
        // USE the provided context queue
        final index = contextQueue.indexWhere((s) => s.id == song.id);
        if (index != -1) {
          // If the song is in the context queue, start from there and keep the rest as Up Next
          state = state.copyWith(
            queue: contextQueue,
            currentIndex: index,
            currentSong: song,
          );
        } else {
          // If song not in context queue (odd), just use it as start
          state = state.copyWith(
            queue: [song, ...contextQueue],
            currentIndex: 0,
            currentSong: song,
          );
        }
      } else {
        // Standard queue logic: check if song is already in existing queue
        final index = state.queue.indexWhere((s) => s.id == song.id);
        if (index != -1) {
          final newQueue = state.queue.sublist(index);
          state = state.copyWith(
            queue: newQueue,
            currentIndex: 0,
            currentSong: song,
          );
        } else {
          state = state.copyWith(
            queue: [song],
            currentIndex: 0,
            currentSong: song,
          );
        }
      }

      // Rebuild playlist for the selected song
      final audioSource = await _createAudioSource(song);
      if (audioSource != null) {
        _playlist = ConcatenatingAudioSource(children: [audioSource]);
        await _audioPlayer.setAudioSource(
          _playlist,
          initialIndex: 0,
          initialPosition: Duration.zero,
        );
        _lastLoadedIndex = state.currentIndex;

        await _audioPlayer.seek(Duration.zero);
        state = state.copyWith(isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: "Không thể tải URL bài hát",
        );
        _handleAndSkipError();
        return;
      }

      _audioPlayer.play();

      // Reset count flag
      _hasCountedPlay = false;

      // 3. Generate Auto-Playlist & AI recommendations (SKIP for Jamendo if we have a context queue)
      final isJamendo =
          song.source == 'jamendo' || song.source == 'jamendo_preview';

      if (!isJamendo) {
        if (song.source == 'youtube' || song.youtubeId != null) {
          generateAutoPlaylist(song.youtubeId ?? song.id);
        }
      }

      // Always fetch AI recommendations
      fetchAiRecommendations();
    } catch (e) {
      print("Error playing song: $e");
      state = state.copyWith(isLoading: false, error: e.toString());
      // Skip to next if initial play fails
      _handleAndSkipError();
    }
  }

  /// Helper to skip to NEXT song in QUEUE when current one fails
  void _handleAndSkipError() {
    if (state.currentIndex + 1 < state.queue.length) {
      print('DEBUG: Error detected. Force skipping to next song in queue...');
      final nextSong = state.queue[state.currentIndex + 1];

      // Reset currentIndex for UI and trigger playSong for the next guy
      Future.delayed(const Duration(milliseconds: 1000), () {
        playSong(nextSong);
      });
    } else {
      print('DEBUG: Error detected but end of queue reached.');
    }
  }

  /// Generate an auto-playlist based on the seed song's artist
  Future<void> generateAutoPlaylist(String videoId) async {
    print('DEBUG: Generating Auto-Playlist for video: $videoId');

    try {
      final currentSong = state.currentSong;
      if (currentSong == null) return;

      final backend = ref.read(backendServiceProvider);
      final results = await backend.search(
        query: '${currentSong.subtitle} official audio',
        limit: 20,
        sources: 'youtube',
      );

      if (results.isEmpty) return;

      final seedId = videoId;
      final seenIds = <String>{seedId};
      final seenTitles = <String>{_normalizeTitle(currentSong.title)};
      final uniqueSongs = <Home>[];

      for (final song in results) {
        final id = song.id;
        final normalizedTitle = _normalizeTitle(song.title);

        if (seenIds.contains(id)) continue;
        if (seenTitles.contains(normalizedTitle)) continue;

        seenIds.add(id);
        seenTitles.add(normalizedTitle);
        uniqueSongs.add(song.toEntity());
      }

      final newQueue = [currentSong, ...uniqueSongs];
      state = state.copyWith(queue: newQueue, currentIndex: 0);

      if (newQueue.length < 20) {
        print(
          'DEBUG: Queue small (${newQueue.length}), expanding with AI...',
        );
        _expandQueueSmart(currentSong);
      }

      _lastLoadedIndex = 0;
      _preloadNextSong();
    } catch (_) {}
  }

  /// Internal helper to expand queue using AI recommendations
  Future<void> _expandQueueSmart(Home seedSong) async {
    try {
      final aiService = ref.read(aiRecommendServiceProvider);
      final recs = await aiService.getRecommendations(
        seedSong.youtubeId ?? seedSong.id,
      );
      List<Home> songsToAdd = recs.map((m) => m.toEntity()).toList();

      // STEP 2: If still not enough, ask AI (Slower but creative)
      if (songsToAdd.length < 5) {
        final aiSongs = await aiService.getRecommendedSongs(
          seedSong.title,
          seedSong.subtitle,
          youtubeService,
          count: 10,
        );
        songsToAdd.addAll(aiSongs);
      }

      if (songsToAdd.isEmpty) return;

      // Filter out anything already in the current queue (Deduplication)
      final currentIds = state.queue.map((s) => s.id).toSet();
      final currentTitles = state.queue
          .map((s) => _normalizeTitle(s.title))
          .toSet();

      final filteredSongs = songsToAdd.where((s) {
        final isNewId = !currentIds.contains(s.id);
        final isNewTitle = !currentTitles.contains(_normalizeTitle(s.title));
        return isNewId && isNewTitle;
      }).toList();

      print(
        'DEBUG: Smart Expansion found ${filteredSongs.length} new songs (Source: YT Related + AI). Adding to queue...',
      );

      if (filteredSongs.isNotEmpty) {
        state = state.copyWith(queue: [...state.queue, ...filteredSongs]);
        _preloadNextSong();
      }
    } catch (e) {
      print('DEBUG: Error expanding queue smart: $e');
    }
  }

  /// Normalize title for comparison (case-insensitive, remove common suffixes)
  String _normalizeTitle(String title) {
    return title
        .toLowerCase()
        // Remove text in parentheses or brackets
        .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
        // Remove common suffixes
        .replaceAll('official video', '')
        .replaceAll('official audio', '')
        .replaceAll('official music video', '')
        .replaceAll('music video', '')
        .replaceAll('lyric video', '')
        .replaceAll('lyrics', '')
        .replaceAll('full audio', '')
        .replaceAll('prod.', '')
        .replaceAll('ft.', '')
        .replaceAll('feat.', '')
        // Remove extra spaces and punctuation
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  // Preloading Cache (multi-item)
  final Map<String, String> _preloadedUrls = {};

  /// Cache an already-resolved audio URL for instant playback later
  void cacheAudioUrl(String videoId, String url) {
    _preloadedUrls[videoId] = url;
  }

  /// Preload a single song's URL without playing it
  Future<void> preLoadSong(String videoId) async {
    if (_preloadedUrls.containsKey(videoId)) return;
    try {
      final backendService = ref.read(backendServiceProvider);
      final url = await backendService.convertYoutubeToMp3(videoId);
      if (url != null) {
        _preloadedUrls[videoId] = url;
      }
    } catch (e) {
      print('DEBUG: Error preloading song $videoId: $e');
    }
  }

  /// Preload multiple songs in parallel (for visible list items)
  Future<void> preloadSongs(Iterable<String> videoIds) async {
    final toLoad = videoIds.where((id) => !_preloadedUrls.containsKey(id)).toList();
    if (toLoad.isEmpty) return;
    try {
      final backendService = ref.read(backendServiceProvider);
      await Future.wait(toLoad.map((id) async {
        final url = await backendService.convertYoutubeToMp3(id);
        if (url != null) _preloadedUrls[id] = url;
      }));
    } catch (e) {
      print('DEBUG: Error preloading songs: $e');
    }
  }

  Future<AudioSource?> _createAudioSource(Home song) async {
    // Check cache first
    final videoId = song.youtubeId ?? song.id;
    if (_preloadedUrls.containsKey(videoId)) {
      final secureUrl = _preloadedUrls[videoId]!.replaceFirst(
        'http://',
        'https://',
      );

      final isJamendo = secureUrl.contains('jamendo.com');

      return AudioSource.uri(
        Uri.parse(secureUrl),
        headers: isJamendo
            ? null
            : {
                'User-Agent':
                    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
              },
        tag: MediaItem(
          id: song.id,
          title: song.title,
          artist: song.subtitle,
          artUri: song.imageUrl.isNotEmpty ? Uri.parse(song.imageUrl) : null,
        ),
      );
    }

    try {
      // Check if we need to resolve URL (e.g. YouTube)
      if (song.source == 'youtube' && song.audioUrl.isEmpty) {
        final backendService = ref.read(backendServiceProvider);
        final url = await backendService.convertYoutubeToMp3(
          song.youtubeId ?? song.id,
        );
        if (url != null) {
          final secureUrl = url.replaceFirst('http://', 'https://');
          print('DEBUG: Resolved YouTube stream URL: $secureUrl');

          return AudioSource.uri(
            Uri.parse(secureUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            },
            tag: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.subtitle,
              artUri: song.imageUrl.isNotEmpty
                  ? Uri.parse(song.imageUrl)
                  : null,
            ),
          );
        }
      } else if (song.source == 'nct') {
        print('DEBUG: Resolving NCT via backend: ${song.title}');
        final backendService = ref.read(backendServiceProvider);
        final resolved = await backendService.getFullVersion(song);

        if (resolved != null && resolved.audioUrl.isNotEmpty) {
          final secureUrl = resolved.audioUrl.replaceFirst(
            'http://',
            'https://',
          );
          print('DEBUG: Resolved NCT via YouTube: $secureUrl');

          return AudioSource.uri(
            Uri.parse(secureUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
            },
            tag: MediaItem(
              id: song.id,
              title: resolved.title,
              artist: resolved.subtitle,
              artUri: song.imageUrl.isNotEmpty
                  ? Uri.parse(song.imageUrl)
                  : null,
            ),
          );
        } else {
          print('DEBUG: Failed to resolve NCT via backend for ${song.title}');
        }
      } else if (song.audioUrl.isNotEmpty) {
        final secureUrl = song.audioUrl.replaceFirst('http://', 'https://');
        print('DEBUG: Playing remote URL: $secureUrl');

        final isJamendo =
            song.source == 'jamendo' || secureUrl.contains('jamendo.com');

        return AudioSource.uri(
          Uri.parse(secureUrl),
          headers: isJamendo
              ? null
              : {
                  'User-Agent':
                      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.subtitle,
            artUri: song.imageUrl.isNotEmpty ? Uri.parse(song.imageUrl) : null,
          ),
        );
      }
    } catch (e) {
      print("Error creating audio source: $e");
    }
    return null;
  }

  // Player Controls
  // Player Controls
  void togglePlay() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
  }

  void toggleShuffle() async {
    final enable = !state.isShuffleModeEnabled;

    // We do NOT use _audioPlayer.setShuffleModeEnabled(true) because
    // we are using Lazy Loading (queue has 20 items, playlist has 2).
    // Native shuffle only shuffles the 2 items.

    if (enable) {
      // ENABLE SHUFFLE
      _originalQueue = List.from(state.queue);

      final currentSong = state.currentSong;
      if (currentSong == null) return;

      final tempQueue = List<Home>.from(state.queue);
      tempQueue.removeWhere((s) => s.id == currentSong.id);
      tempQueue.shuffle();
      tempQueue.insert(0, currentSong); // Keep current playing first

      state = state.copyWith(
        queue: tempQueue,
        currentIndex: 0,
        isShuffleModeEnabled: true,
      );

      // Clean up _playlist (Keep index 0 - current song, remove rest)
      if (_playlist.length > 1) {
        try {
          await _playlist.removeRange(1, _playlist.length);
        } catch (e) {
          print(
            'DEBUG: PlayerController - Error removing range from playlist: $e',
          );
        }
      }
      _lastLoadedIndex = 0; // Reset loaded index
    } else {
      // DISABLE SHUFFLE (Restore)
      if (_originalQueue.isNotEmpty) {
        final currentSong = state.currentSong;
        int newIndex = _originalQueue.indexWhere(
          (s) => s.id == currentSong?.id,
        );
        if (newIndex == -1) newIndex = 0;

        state = state.copyWith(
          queue: List.from(_originalQueue),
          currentIndex: newIndex,
          isShuffleModeEnabled: false,
        );

        // Clean up _playlist (Keep index 0 - current song, remove rest)
        // Note: playing index in just_audio is relative to playlist.
        // If we are playing index 0 of playlist, it matches.
        if (_playlist.length > 1) {
          try {
            await _playlist.removeRange(1, _playlist.length);
          } catch (e) {
            print(
              'DEBUG: PlayerController - Error removing range from playlist (un-shuffle): $e',
            );
          }
        }
        _lastLoadedIndex = 0; // Reset loaded index
      }
    }

    // Trigger preload of the NEW next song
    _preloadNextSong();
  }

  void cycleRepeatMode() {
    LoopMode nextMode;
    switch (state.repeatMode) {
      case LoopMode.off:
        nextMode = LoopMode.all;
        break;
      case LoopMode.all:
        nextMode = LoopMode.one;
        break;
      case LoopMode.one:
        nextMode = LoopMode.off;
        break;
    }
    _audioPlayer.setLoopMode(nextMode);
  }

  Future<void> skipNext() async {
    if (_audioPlayer.hasNext) {
      _audioPlayer.seekToNext();
    } else {
      // Check if we have more in queue but not loaded
      if (state.currentIndex + 1 < state.queue.length) {
        print("DEBUG: skipNext - Next song not loaded yet. Loading now...");
        await _preloadNextSong();
        if (_audioPlayer.hasNext) {
          _audioPlayer.seekToNext();
        }
      }
    }
  }

  void skipPrevious() {
    if (_audioPlayer.hasPrevious) {
      _audioPlayer.seekToPrevious();
    } else {
      _audioPlayer.seek(Duration.zero);
    }
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  /// Safe seek to a specific index in the queue, handling lazy loading
  Future<void> seekToIndex(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    print("DEBUG: seekToIndex - Target: $index, Loaded: ${_playlist.length}");

    // Check if the song is already loaded in the just_audio playlist
    try {
      if (index < _playlist.length) {
        // It's loaded. Just seek.
        await _audioPlayer.seek(Duration.zero, index: index);
      } else {
        // Not loaded. "Jump" to this song.
        print("DEBUG: seekToIndex - Jumping to unloaded song at $index");
        final song = state.queue[index];

        state = state.copyWith(isLoading: true);

        // Stop current
        _audioPlayer.stop();

        // Clear and Load
        final audioSource = await _createAudioSource(song);

        if (audioSource != null) {
          // Update queue effectively starting new sequence from this index?
          // To simplify, we treat this jump as reshaping the context.

          final newQueue = state.queue.sublist(index);
          state = state.copyWith(
            queue: newQueue,
            currentIndex: 0,
            currentSong: song,
            isLoading: false,
          );

          _playlist = ConcatenatingAudioSource(children: [audioSource]);
          await _audioPlayer.setAudioSource(_playlist);

          _lastLoadedIndex = 0; // Relative to new queue which starts at 0.

          _audioPlayer.play();

          // Retrigger Auto-Playlist/Preload for the *new* next song
          _preloadNextSong();
        }
      }
    } catch (e) {
      print("Error seeking to index: $e");
    }
  }

  /// Fetch AI-powered song recommendations for the current song
  Future<void> fetchAiRecommendations() async {
    final currentSong = state.currentSong;
    if (currentSong == null) return;

    // Fetch AI recommendations for ALL sources
    print('DEBUG: Fetching AI recommendations for ${currentSong.title}');

    try {
      final aiService = ref.read(aiRecommendServiceProvider);

      final recommendations = await aiService.getRecommendedSongs(
        currentSong.title,
        currentSong.subtitle,
      );

      state = state.copyWith(aiRecommendations: recommendations);
      print('DEBUG: Stored ${recommendations.length} AI recommendations');
    } catch (e) {
      print('DEBUG: Error fetching AI recommendations: $e');
    }
  }

  /// Get AI recommendations (exposed for UI)
  List<Home> get aiRecommendations => state.aiRecommendations;

  /// Fetch Top 20 most played songs and play them as a new queue
  Future<void> playMostPlayedList() async {
    try {
      state = state.copyWith(isLoading: true);

      final repository = ref.read(supabaseRepositoryProvider);
      final topSongs = await repository.getMostPlayedSongs(20);

      if (topSongs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "Bạn chưa có bài hát nào trong danh sách hay nghe",
        );
        return;
      }

      // Stop current
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      }

      // Set new queue
      state = state.copyWith(
        queue: topSongs,
        currentIndex: 0,
        currentSong: topSongs.first,
        isLoading: false,
      );

      // Re-init playlist
      final firstSource = await _createAudioSource(topSongs.first);
      if (firstSource != null) {
        _playlist = ConcatenatingAudioSource(children: [firstSource]);
        await _audioPlayer.setAudioSource(_playlist);
        _lastLoadedIndex = 0;
        await _audioPlayer.play();

        _hasCountedPlay = false;

        // Preload next
        _preloadNextSong();
      } else {
        _handleAndSkipError();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Lỗi khi tải danh sách hay nghe: $e",
      );
      _handleAndSkipError();
    }
  }

  /// Generate a smart personalized "Supermix" playlist
  Future<void> generateMySupermix() async {
    try {
      state = state.copyWith(isLoading: true);
      final repository = ref.read(supabaseRepositoryProvider);

      // Step 1: Get top 5 most played songs
      final allTopSongs = await repository.getMostPlayedSongs(10);

      // Filter top songs: Duration <= 15 mins (900s)
      final topSongs = allTopSongs
          .where((s) {
            if (s.duration != null && s.duration!.inSeconds > 900) return false;
            return true;
          })
          .take(5)
          .toList();

      if (topSongs.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "Hãy nghe nhạc nhiều hơn để AI có thể tạo Supermix cho bạn!",
        );
        return;
      }

      // Get history IDs to ensure we suggest "never heard" songs
      final historyIds = await repository.getHistoryVideoIds();
      final List<Home> supermixSongs = List.from(topSongs);
      final Set<String> currentSupermixIds = topSongs
          .map((s) => s.youtubeId ?? s.id)
          .toSet();

      // Step 2: For each top song, get 2 related songs never heard before
      for (final song in topSongs) {
        final videoId = song.youtubeId ?? song.id;
        final relatedVideos = await youtubeService.getRelatedSongs(videoId);

        int addedFromThisSong = 0;
        for (final video in relatedVideos) {
          if (addedFromThisSong >= 2) break;

          final vidId = video.id.value;

          // Extra safety check for duration (though already filtered in service)
          if (video.duration != null && video.duration!.inSeconds > 900)
            continue;

          // Filter: Never heard (not in history) AND not already in this supermix
          if (!historyIds.contains(vidId) &&
              !currentSupermixIds.contains(vidId)) {
            supermixSongs.add(
              Home(
                id: vidId,
                title: video.title,
                subtitle: video.author,
                imageUrl: video.thumbnails.highResUrl,
                source: 'youtube',
                youtubeId: vidId,
                duration: video.duration,
              ),
            );
            currentSupermixIds.add(vidId);
            addedFromThisSong++;
          }
        }
      }

      // Step 3: Shuffle the list
      supermixSongs.shuffle();

      // Step 4: Play as "Sonus Mix dành cho bạn"
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      }

      state = state.copyWith(
        queue: supermixSongs,
        currentIndex: 0,
        currentSong: supermixSongs.first,
        isLoading: false,
      );

      // Re-init playlist
      final firstSource = await _createAudioSource(supermixSongs.first);
      if (firstSource != null) {
        _playlist = ConcatenatingAudioSource(children: [firstSource]);
        await _audioPlayer.setAudioSource(_playlist);
        _lastLoadedIndex = 0;
        await _audioPlayer.play();

        _hasCountedPlay = false;

        _preloadNextSong();
      } else {
        _handleAndSkipError();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Lỗi khi tạo Supermix: $e",
      );
      _handleAndSkipError();
    }
  }
}
