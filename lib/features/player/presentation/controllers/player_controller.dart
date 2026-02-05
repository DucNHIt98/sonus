import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/data/repositories/home_repository_provider.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/search/presentation/controllers/search_controller.dart';
import 'package:sonus/features/home/presentation/providers/home_provider.dart';

part 'player_controller.g.dart';

@Riverpod(keepAlive: true)
class PlayerController extends _$PlayerController {
  late final AudioPlayer _audioPlayer;

  @override
  FutureOr<Home?> build() {
    print("DEBUG: PlayerController INITIALIZED (Hash: ${hashCode})");
    _audioPlayer = AudioPlayer();
    ref.onDispose(() {
      print("DEBUG: PlayerController DISPOSED (Hash: ${hashCode})");
      _audioPlayer.dispose();
    });
    return null;
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  /// Updated to be more efficient: accepts metadata to show UI immediately
  Future<void> playSelectedSongWithMetadata(Home metadata) async {
    print("DEBUG: playSelectedSongWithMetadata for ${metadata.title}");

    // 1. Reset player immediately to avoid "old cache" sound/UI
    try {
      await _audioPlayer.pause();
      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      print("Reset player error: $e");
    }

    // 2. Show metadata immediately
    state = AsyncValue.data(metadata);

    final youtubeService = ref.read(youtubeServiceProvider);

    try {
      // 3. Fetch URL in background
      final videoId = metadata.youtubeId ?? metadata.id;
      final audioUrl = await youtubeService.getStreamUrl(videoId);

      // SAFETY: If user already switched to ANOTHER song during fetch, bail out.
      final currentState = state.valueOrNull;
      if (currentState == null ||
          (currentState.youtubeId ?? currentState.id) != videoId) {
        print(
          "DEBUG: Navigation changed during fetch, ignoring result for $videoId",
        );
        return;
      }

      if (audioUrl == null) {
        state = AsyncValue<Home?>.error(
          'Could not get audio stream',
          StackTrace.current,
        ).copyWithPrevious(AsyncValue.data(metadata));
        return;
      }

      final song = metadata.copyWith(audioUrl: audioUrl);
      state = AsyncValue.data(song);

      // Save to History (Fire and forget)
      try {
        final homeRepository = ref.read(homeRepositoryProvider);
        homeRepository.addToRecentlyPlayed(song);
      } catch (e) {
        print('Error saving history: $e');
      }

      // 4. Start Player
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(song.audioUrl),
          tag: MediaItem(
            id: song.id,
            title: song.title,
            artist: song.subtitle,
            artUri: Uri.parse(song.imageUrl),
            duration: song.duration, // For Lock Screen
          ),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Referer': 'https://www.youtube.com/',
          },
        ),
      );
      _audioPlayer.play();
    } catch (e, stack) {
      print('Audio Playback Error: $e');
      state = AsyncValue<Home?>.error(
        e,
        stack,
      ).copyWithPrevious(AsyncValue.data(metadata));
    }
  }

  /// Legacy method: kept for compatibility, but now uses the faster metadata-first approach
  Future<void> playSelectedSong(String videoId) async {
    print("DEBUG: playSelectedSong called with $videoId");
    state = const AsyncValue.loading();

    final youtubeService = ref.read(youtubeServiceProvider);

    try {
      final video = await youtubeService.getVideoDetails(videoId);
      if (video == null) {
        state = AsyncValue.error('Could not get details', StackTrace.current);
        return;
      }

      final songMetadata = Home(
        id: video.id.value,
        title: video.title,
        subtitle: video.author,
        imageUrl: video.thumbnails.highResUrl,
        source: 'youtube',
        youtubeId: video.id.value,
      );

      await playSelectedSongWithMetadata(songMetadata);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// When playing from history/favorites, the URL might be expired.
  Future<void> playSong(Home song) async {
    print("DEBUG: playSong for ${song.title} (Source: ${song.source})");

    if (song.source == 'youtube') {
      // Always refresh URL for YouTube songs
      await playSelectedSongWithMetadata(song);
    } else {
      // For local or other sources, play directly
      state = AsyncValue.data(song);
      try {
        await _audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(song.audioUrl),
            tag: MediaItem(
              id: song.id,
              title: song.title,
              artist: song.subtitle,
              artUri: Uri.parse(song.imageUrl),
            ),
          ),
        );
        _audioPlayer.play();
      } catch (e, stack) {
        state = AsyncValue<Home?>.error(
          e,
          stack,
        ).copyWithPrevious(AsyncValue.data(song));
      }
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
    state = const AsyncValue.data(null);
  }
}
