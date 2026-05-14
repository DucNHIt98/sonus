import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:sonus/core/models/music_model.dart';

part 'youtube_service.g.dart';

@Riverpod(keepAlive: true)
YoutubeService youtubeService(YoutubeServiceRef ref) {
  final yt = YoutubeExplode();
  ref.onDispose(() => yt.close());
  return YoutubeService(yt);
}

class YoutubeService {
  final YoutubeExplode _yt;

  YoutubeService(this._yt);

  Future<List<MusicModel>> fetchYoutubeChart(String regionName) async {
    try {
      final query = 'Top 20 bài hát $regionName mới nhất';
      debugPrint('YouTube Search Query: $query');

      final searchResult = await _yt.search.search(query);

      // Filter out live videos and shorts if possible, or just take the first 20
      final List<MusicModel> songs = [];
      int rank = 1;

      for (var video in searchResult) {
        if (songs.length >= 20) break;

        songs.add(
          MusicModel(
            id: video.id.value,
            title: video.title,
            artist: video.author,
            albumArt: video.thumbnails.highResUrl,
            source: MusicSource.youtube,
            rank: rank++,
            duration: video.duration,
            region: regionName,
          ),
        );
      }

      return songs;
    } catch (e) {
      debugPrint('YouTube Search Error: $e');
      return [];
    }
  }

  Future<List<MusicModel>> fetchSongsFromPlaylist(String playlistId) async {
    try {
      // Fetch playlist videos
      final videos = await _yt.playlists.getVideos(playlistId).toList();

      int rank = 1;
      return videos.map((video) {
        return MusicModel(
          id: video.id.value,
          title: video.title,
          artist: video.author,
          albumArt: video.thumbnails.highResUrl,
          source: MusicSource.youtube,
          rank: rank++,
          duration: video.duration,
        );
      }).toList();
    } catch (e) {
      debugPrint('YouTube Playlist Fetch Error: $e');
      return [];
    }
  }

  Future<String?> getStreamUrl(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      return streamInfo.url.toString();
    } catch (e) {
      debugPrint('YouTube Stream URL Fetch Error: $e');
      return null;
    }
  }
}
