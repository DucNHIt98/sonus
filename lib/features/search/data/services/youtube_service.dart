import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Search for songs/videos on YouTube
  Future<List<Video>> searchSongs(String query) async {
    try {
      final searchList = await _yt.search.search(query);
      return searchList.toList();
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  /// Get direct audio stream URL with highest quality and retry mechanism to avoid 403
  Future<String?> getStreamUrl(String videoId) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        print(
          'Attempting to fetch manifest for $videoId (Retry: $retryCount)...',
        );
        // Using a highly resilient set of clients, prioritizing VR and TV which often bypass music video restrictions
        final manifest = await _yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: [
            YoutubeApiClient.androidVr,
            YoutubeApiClient.tv,
            YoutubeApiClient.ios,
            YoutubeApiClient.safari,
          ],
        );

        // Priority 1: Audio-only streams
        Iterable<AudioStreamInfo> audioStreams = manifest.audioOnly;

        if (audioStreams.isEmpty) {
          audioStreams = manifest.muxed;
        }

        if (audioStreams.isEmpty) {
          print('No available streams found for $videoId');
          return null;
        }

        // Filter for MP4/M4A for maximum compatibility
        final bestStream =
            audioStreams.where((s) => s.container.name == 'mp4').isNotEmpty
            ? audioStreams
                  .where((s) => s.container.name == 'mp4')
                  .withHighestBitrate()
            : audioStreams.withHighestBitrate();

        final url = bestStream.url.toString();
        print('Successfully found stream URL for $videoId');
        return url;
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('403') || errorStr.contains('Forbidden')) {
          retryCount++;
          print(
            'YouTube 403 Forbidden - Segment/Manifest access denied ($retryCount/$maxRetries)',
          );

          // Music videos like "APT." are heavily protected.
          // We wait longer between retries to allow potential rate-limits to cool down.
          await Future.delayed(Duration(milliseconds: 1500 * retryCount));
          continue;
        }
        print('Error getting stream URL for video $videoId: $e');
        break;
      }
    }
    return null;
  }

  /// Get video details
  Future<Video?> getVideoDetails(String videoId) async {
    try {
      return await _yt.videos.get(videoId);
    } catch (e) {
      print('Error getting video details: $e');
      return null;
    }
  }

  void dispose() {
    _yt.close();
  }
}
