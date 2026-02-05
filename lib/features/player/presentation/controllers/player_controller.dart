import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/data/repositories/home_repository_provider.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/search/presentation/controllers/search_controller.dart';
import 'package:sonus/features/search/data/services/ai_recommend_service.dart';
import 'package:sonus/features/home/presentation/providers/home_provider.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'player_controller.g.dart';
part 'player_controller.freezed.dart';

/// State class for the player, holds current song and queue
@freezed
class PlayerState with _$PlayerState {
  const factory PlayerState({
    Home? currentSong,
    @Default([]) List<Home> queue,
    @Default(0) int currentIndex,
    @Default(false) bool isLoading,
    String? error,
    @Default([]) List<Home> aiRecommendations,
  }) = _PlayerState;
}

@Riverpod(keepAlive: true)
class PlayerController extends _$PlayerController {
  late final AudioPlayer _audioPlayer;
  late final ConcatenatingAudioSource _playlist;

  @override
  PlayerState build() {
    print("DEBUG: PlayerController INITIALIZED (Hash: ${hashCode})");
    _audioPlayer = AudioPlayer();
    _playlist = ConcatenatingAudioSource(children: []);

    // Listen to current index changes for seamless queue transitions
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index < state.queue.length) {
        state = state.copyWith(
          currentIndex: index,
          currentSong: state.queue[index],
        );
        // Save to history when song changes
        _saveToHistory(state.queue[index]);

        // Prefetch URLs for next songs in queue (fire and forget)
        prefetchUpcoming();

        // Fetch AI recommendations for current song (fire and forget)
        fetchAiRecommendations();
      }
    });

    // Listen for song completion to trigger autoplay
    _audioPlayer.processingStateStream.listen((processingState) async {
      if (processingState == ProcessingState.completed) {
        print('DEBUG: Song completed, checking for autoplay...');

        // If there are more songs in queue, just_audio handles it
        // Only fetch related if we're at the last song in queue
        if (state.currentIndex >= state.queue.length - 1 &&
            state.currentSong != null) {
          await _handleAutoplay();
        }
      }
    });

    ref.onDispose(() {
      print("DEBUG: PlayerController DISPOSED (Hash: ${hashCode})");
      _audioPlayer.dispose();
    });
    return const PlayerState();
  }

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Home> get queue => state.queue;
  Home? get currentSong => state.currentSong;

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

  /// Play a song immediately, adding it to queue if not present
  Future<void> playSelectedSongWithMetadata(Home metadata) async {
    print("DEBUG: playSelectedSongWithMetadata for ${metadata.title}");

    // 1. Update state to show loading
    state = state.copyWith(currentSong: metadata, isLoading: true, error: null);

    try {
      // 2. Check if song is already in queue
      final existingIndex = state.queue.indexWhere(
        (s) => (s.youtubeId ?? s.id) == (metadata.youtubeId ?? metadata.id),
      );

      if (existingIndex != -1) {
        // Song exists in queue, just seek to it
        await _audioPlayer.seek(Duration.zero, index: existingIndex);
        state = state.copyWith(
          currentIndex: existingIndex,
          currentSong: state.queue[existingIndex],
          isLoading: false,
        );
        _audioPlayer.play();
        return;
      }

      // 3. Resolve stream URL
      final youtubeService = ref.read(youtubeServiceProvider);
      final videoId = metadata.youtubeId ?? metadata.id;
      final audioUrl = await youtubeService.getStreamUrl(videoId);

      if (audioUrl == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get audio stream',
        );
        return;
      }

      final song = metadata.copyWith(audioUrl: audioUrl);

      // 4. Add to queue and playlist
      final newQueue = [...state.queue, song];
      final newIndex = newQueue.length - 1;

      final audioSource = _createAudioSourceFromSong(song);
      await _playlist.add(audioSource);

      // 5. Update state
      state = state.copyWith(
        queue: newQueue,
        currentIndex: newIndex,
        currentSong: song,
        isLoading: false,
      );

      // 6. Set playlist if first song, or seek to new song
      if (newQueue.length == 1) {
        await _audioPlayer.setAudioSource(_playlist);
      } else {
        await _audioPlayer.seek(Duration.zero, index: newIndex);
      }

      _audioPlayer.play();
      _saveToHistory(song);
    } catch (e) {
      print('Audio Playback Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Legacy method for compatibility
  Future<void> playSelectedSong(String videoId) async {
    print("DEBUG: playSelectedSong called with $videoId");
    state = state.copyWith(isLoading: true);

    final youtubeService = ref.read(youtubeServiceProvider);

    try {
      final video = await youtubeService.getVideoDetails(videoId);
      if (video == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Could not get details',
        );
        return;
      }

      final songMetadata = Home(
        id: video.id.value,
        title: video.title,
        subtitle: video.author,
        imageUrl: video.thumbnails.highResUrl,
        source: 'youtube',
        youtubeId: video.id.value,
        duration: video.duration,
      );

      await playSelectedSongWithMetadata(songMetadata);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Play a song from history/favorites
  Future<void> playSong(Home song) async {
    print("DEBUG: playSong for ${song.title} (Source: ${song.source})");
    await playSelectedSongWithMetadata(song);
  }

  /// Skip to next song in queue
  Future<void> skipNext() async {
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    }
  }

  /// Skip to previous song in queue
  Future<void> skipPrevious() async {
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      await _audioPlayer.seek(Duration.zero);
    }
  }

  Future<void> togglePlay() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void stop() {
    _audioPlayer.stop();
    state = const PlayerState();
  }

  /// Clear the queue
  Future<void> clearQueue() async {
    await _playlist.clear();
    state = const PlayerState();
  }

  /// Remove a song from queue by index
  Future<void> removeFromQueue(int index) async {
    if (index < 0 || index >= state.queue.length) return;

    await _playlist.removeAt(index);
    final newQueue = [...state.queue]..removeAt(index);

    int newIndex = state.currentIndex;
    if (index < state.currentIndex) {
      newIndex--;
    } else if (index == state.currentIndex && newQueue.isNotEmpty) {
      newIndex = newIndex.clamp(0, newQueue.length - 1);
    }

    state = state.copyWith(
      queue: newQueue,
      currentIndex: newIndex,
      currentSong: newQueue.isNotEmpty ? newQueue[newIndex] : null,
    );
  }

  // Private helpers
  Future<AudioSource?> _createAudioSource(Home song) async {
    String? audioUrl = song.audioUrl;

    if (song.source == 'youtube' && audioUrl.isEmpty) {
      final youtubeService = ref.read(youtubeServiceProvider);
      audioUrl = await youtubeService.getStreamUrl(song.youtubeId ?? song.id);
    }

    if (audioUrl == null || audioUrl.isEmpty) return null;

    return _createAudioSourceFromSong(song.copyWith(audioUrl: audioUrl));
  }

  AudioSource _createAudioSourceFromSong(Home song) {
    return AudioSource.uri(
      Uri.parse(song.audioUrl),
      tag: MediaItem(
        id: song.id,
        title: song.title,
        artist: song.subtitle,
        artUri: Uri.parse(song.imageUrl),
        duration: song.duration,
      ),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.youtube.com/',
      },
    );
  }

  void _saveToHistory(Home song) {
    try {
      final homeRepository = ref.read(homeRepositoryProvider);
      homeRepository.addToRecentlyPlayed(song);
    } catch (e) {
      print('Error saving history: $e');
    }
  }

  /// Handle autoplay by fetching related songs and playing the first one
  /// Falls back to history if no related songs found
  Future<void> _handleAutoplay() async {
    final currentSong = state.currentSong;
    if (currentSong == null) return;

    final videoId = currentSong.youtubeId ?? currentSong.id;
    print('DEBUG: Fetching related songs for autoplay (videoId: $videoId)');

    try {
      final youtubeService = ref.read(youtubeServiceProvider);
      final relatedVideos = await youtubeService.getRelatedSongs(videoId);

      Home? nextSong;

      if (relatedVideos.isNotEmpty) {
        // Use first related video
        final nextVideo = relatedVideos.first;
        print('DEBUG: Autoplay next song from related: ${nextVideo.title}');

        nextSong = Home(
          id: nextVideo.id.value,
          title: nextVideo.title,
          subtitle: nextVideo.author,
          imageUrl: nextVideo.thumbnails.highResUrl,
          source: 'youtube',
          youtubeId: nextVideo.id.value,
          duration: nextVideo.duration,
        );
      } else {
        // Fallback to history
        print('DEBUG: No related songs, falling back to history');
        nextSong = await _getRandomFromHistory();
      }

      if (nextSong != null) {
        await playSelectedSongWithMetadata(nextSong);
      } else {
        print('DEBUG: No songs available for autoplay');
      }
    } catch (e) {
      print('DEBUG: Autoplay error: $e');
      // Try history as last resort
      final historySong = await _getRandomFromHistory();
      if (historySong != null) {
        await playSelectedSongWithMetadata(historySong);
      }
    }
  }

  /// Get a random song from history that's not currently playing
  Future<Home?> _getRandomFromHistory() async {
    try {
      final homeRepository = ref.read(homeRepositoryProvider);
      final homeData = await homeRepository.getHomeData();
      final recentlyPlayed = homeData['Recently Played'] ?? [];

      if (recentlyPlayed.isEmpty) return null;

      // Filter out current song and songs already in queue
      final currentIds = state.queue.map((s) => s.youtubeId ?? s.id).toSet();
      final availableSongs = recentlyPlayed
          .where((s) => !currentIds.contains(s.youtubeId ?? s.id))
          .toList();

      if (availableSongs.isEmpty) {
        // If all history is in queue, just pick random from full history
        availableSongs.addAll(recentlyPlayed);
      }

      // Shuffle and pick first
      availableSongs.shuffle();
      print('DEBUG: Selected from history: ${availableSongs.first.title}');
      return availableSongs.first;
    } catch (e) {
      print('DEBUG: Error getting history: $e');
      return null;
    }
  }

  /// Prefetch stream URLs for upcoming songs in queue
  Future<void> prefetchUpcoming({int count = 2}) async {
    final currentIdx = state.currentIndex;
    final queue = state.queue;

    for (int i = 1; i <= count; i++) {
      final nextIdx = currentIdx + i;
      if (nextIdx >= queue.length) break;

      final song = queue[nextIdx];
      if (song.audioUrl.isNotEmpty) continue; // Already has URL

      print('DEBUG: Prefetching URL for: ${song.title}');

      try {
        final youtubeService = ref.read(youtubeServiceProvider);
        final audioUrl = await youtubeService.getStreamUrl(
          song.youtubeId ?? song.id,
        );

        if (audioUrl != null) {
          // Update song in queue with prefetched URL
          final updatedQueue = [...state.queue];
          updatedQueue[nextIdx] = song.copyWith(audioUrl: audioUrl);
          state = state.copyWith(queue: updatedQueue);
          print('DEBUG: Prefetched URL for: ${song.title}');
        }
      } catch (e) {
        print('DEBUG: Prefetch error for ${song.title}: $e');
      }
    }
  }

  /// Fetch AI-powered song recommendations for the current song
  Future<void> fetchAiRecommendations() async {
    final currentSong = state.currentSong;
    if (currentSong == null) return;

    print('DEBUG: Fetching AI recommendations for ${currentSong.title}');

    try {
      final aiService = ref.read(aiRecommendServiceProvider);
      final youtubeService = ref.read(youtubeServiceProvider);

      final recommendations = await aiService.getRecommendedSongs(
        currentSong.title,
        currentSong.subtitle,
        youtubeService,
      );

      state = state.copyWith(aiRecommendations: recommendations);
      print('DEBUG: Stored ${recommendations.length} AI recommendations');
    } catch (e) {
      print('DEBUG: Error fetching AI recommendations: $e');
    }
  }

  /// Get AI recommendations (exposed for UI)
  List<Home> get aiRecommendations => state.aiRecommendations;
}
