import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'youtube_service.g.dart';

@Riverpod(keepAlive: true)
YoutubeService youtubeService(YoutubeServiceRef ref) {
  final service = YoutubeService();
  ref.onDispose(service.dispose);
  return service;
}

class YoutubeService {
  final YoutubeExplode _yt = YoutubeExplode();

  /// Search for songs/videos on YouTube
  Future<List<Video>> searchSongs(String query) async {
    try {
      final refinedQuery = '$query official audio';
      final searchList = await _yt.search.search(refinedQuery);

      final filteredList = searchList.where((video) {
        if (video.isLive) return false;
        if (video.duration == null) return false;
        if (video.duration!.inSeconds >= 900) return false;

        final title = video.title.toLowerCase();
        if (title.contains('teaser') ||
            title.contains('karaoke') ||
            title.contains('live')) {
          return false;
        }

        return true;
      }).toList();

      // Sort by official source first
      filteredList.sort((a, b) {
        final aOfficial = _isOfficialSource(a);
        final bOfficial = _isOfficialSource(b);
        if (aOfficial && !bOfficial) return -1;
        if (!aOfficial && bOfficial) return 1;
        return 0;
      });

      return filteredList;
    } catch (_) {
      return [];
    }
  }

  /// Helper to check if a video comes from an official or trusted source
  bool _isOfficialSource(Video video) {
    final author = video.author.toLowerCase();
    // Common indicators of official artist channels or topics
    return author.contains('vevo') ||
        author.contains('official') ||
        author.contains(' - topic') ||
        // Check for musical note (might be present in some strings but youtube_explode
        // might not always expose it in the same way, but it's a good heuristic)
        video.author.contains('♪');
  }

  /// Get direct audio stream URL with highest quality and retry mechanism to avoid 403
  Future<String?> getStreamUrl(String videoId) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final manifest = await _yt.videos.streamsClient.getManifest(
          videoId,
          ytClients: [
            YoutubeApiClient.androidVr,
            YoutubeApiClient.tv,
            YoutubeApiClient.ios,
            YoutubeApiClient.safari,
          ],
        );

        Iterable<AudioStreamInfo> audioStreams = manifest.audioOnly;

        if (audioStreams.isEmpty) {
          audioStreams = manifest.muxed;
        }

        if (audioStreams.isEmpty) {
          return null;
        }

        final bestStream =
            audioStreams.where((s) => s.container.name == 'mp4').isNotEmpty
            ? audioStreams
                  .where((s) => s.container.name == 'mp4')
                  .withHighestBitrate()
            : audioStreams.withHighestBitrate();

        final url = bestStream.url.toString();
        return url;
      } catch (e) {
        final errorStr = e.toString();
        if (errorStr.contains('403') || errorStr.contains('Forbidden')) {
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
          continue;
        }
        break;
      }
    }
    return null;
  }

  /// Get video details
  Future<Video?> getVideoDetails(String videoId) async {
    try {
      return await _yt.videos.get(videoId);
    } catch (_) {
      return null;
    }
  }

  /// Get related songs/videos for autoplay
  Future<List<Video>> getRelatedSongs(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final relatedVideos = await _yt.videos.getRelatedVideos(video);

      if (relatedVideos == null) {
        return [];
      }

      final filteredList = relatedVideos.where((v) {
        if (v.isLive) return false;
        if (v.duration == null) return false;

        // Filter: Keep only videos <= 15 minutes (900 seconds)
        if (v.duration!.inSeconds > 900) return false;

        final title = v.title.toLowerCase();
        final junkKeywords = [
          'review',
          'vlog',
          'reaction',
          'phỏng vấn',
          'teaser',
          'trailer',
          'karaoke',
          'live',
          'behind the scenes',
          'bts',
        ];

        for (final keyword in junkKeywords) {
          if (title.contains(keyword)) return false;
        }

        return true;
      }).toList();

      return filteredList.take(10).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get latest songs from the artist's official channel with smart filtering
  Future<List<Video>> getSmartArtistSongsFromChannel(String videoId) async {
    try {
      final video = await _yt.videos.get(videoId);
      final channelId = video.channelId;
      final author = video.author;

      final uploads = await _yt.channels
          .getUploads(channelId)
          .take(50) // Increased to 50 to have enough songs after filtering
          .toList();

      final filteredList = uploads.where((video) {
        if (video.isLive) return false;
        if (video.duration == null) return false;

        // Duration Filter: Only keep videos between 2 and 10 minutes
        final durationSec = video.duration!.inSeconds;
        if (durationSec < 120 || durationSec > 600) return false;

        final title = video.title.toLowerCase();

        // Keyword Filter: Exclude non-music content
        final junkKeywords = [
          'hậu trường',
          'review',
          'vlog',
          'reaction',
          'behind the scenes',
          'bts',
          'phỏng vấn',
          'teaser',
          'trailer',
          'karaoke',
          'live',
        ];

        for (final keyword in junkKeywords) {
          if (title.contains(keyword)) return false;
        }

        return true;
      }).toList();

      // Sort: Official sources first
      filteredList.sort((a, b) {
        final aOfficial = _isOfficialSource(a);
        final bOfficial = _isOfficialSource(b);
        if (aOfficial && !bOfficial) return -1;
        if (!aOfficial && bOfficial) return 1;
        return 0;
      });

      final authorLower = author.toLowerCase();
      final group1 = filteredList
          .where((v) => v.title.toLowerCase().contains(authorLower))
          .toList();
      final group2 = filteredList
          .where((v) => !v.title.toLowerCase().contains(authorLower))
          .toList();

      final result = [...group1, ...group2];
      return result;
    } catch (_) {
      return [];
    }
  }

  /// Get official music from channel (Prioritizing MV, Album, Official content)
  Future<List<Video>> getOfficialMusicFromChannel(String videoId) async {
    try {
      // Step 1: Use our already optimized smart artist songs (Uploads + Filtering)
      final songs = await getSmartArtistSongsFromChannel(videoId);

      // Step 2: If we want to be even "cleaner", we can prioritize videos
      // that have "Official MV" or "Official Music Video" in the title
      final officialSongs = songs.where((v) {
        final t = v.title.toLowerCase();
        return t.contains('official mv') ||
            t.contains('official music video') ||
            t.contains('official video');
      }).toList();

      if (officialSongs.isNotEmpty) {
        return [
          ...officialSongs,
          ...songs.where((v) => !officialSongs.contains(v)),
        ];
      }

      return songs;
    } catch (_) {
      return getSmartArtistSongsFromChannel(videoId);
    }
  }

  Future<List<Video>> getSongsFromChannel(String videoId) async {
    return getOfficialMusicFromChannel(videoId);
  }

  Future<List<Playlist>> getChannelPlaylists(String videoId) async {
    return [];
  }

  Future<Channel?> getChannelDetails(String channelId) async {
    try {
      return await _yt.channels.get(channelId);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.isEmpty) return [];
    try {
      final suggestions = await _yt.search.getQuerySuggestions(query);
      return suggestions.toList();
    } catch (_) {
      return [];
    }
  }

  void dispose() {
    _yt.close();
  }
}
