import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/dio_client.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

part 'backend_service.g.dart';

@Riverpod(keepAlive: true)
BackendService backendService(BackendServiceRef ref) {
  return BackendService(ref.read(dioClientProvider));
}

class BackendService {
  final Dio _dio;

  BackendService(this._dio);

  /// Resolves the full YouTube audio URL for a Deezer preview track
  Future<Home?> getFullVersion(Home deezerSong) async {
    try {
      final response = await _dio.post(
        '/api/music/resolve/',
        data: {
          'title': deezerSong.title,
          'artist': deezerSong.subtitle,
          'deezer_id': deezerSong.deezerId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return deezerSong.copyWith(
          youtubeId: data['youtube_id'],
          audioUrl: data['audio_url'] ?? '',
          source: 'youtube',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Triggers conversion of a YouTube video to MP3
  Future<String?> convertYoutubeToMp3(String youtubeId) async {
    try {
      final response = await _dio.post(
        '/api/music/resolve/',
        data: {'video_id': youtubeId},
      );

      if (response.statusCode == 200) {
        return response.data['audio_url'];
      }
      return null;
    } catch (e) {
      debugPrint('Backend Error in convertYoutubeToMp3: $e');
      return null;
    }
  }

  /// Multi-source search
  Future<List<MusicModel>> search({
    required String query,
    int limit = 10,
    String sources = 'youtube,jamendo,nct',
  }) async {
    try {
      final response = await _dio.get(
        '/api/music/search/',
        queryParameters: {'q': query, 'limit': limit, 'sources': sources},
      );
      final data = response.data;
      final results = List<Map<String, dynamic>>.from(data['results'] ?? []);
      return results.map((json) => MusicModel.fromSupabase(json)).toList();
    } catch (e) {
      debugPrint('Backend search error: $e');
      return [];
    }
  }

  /// YouTube autocomplete suggestions
  Future<List<String>> autocomplete(String query) async {
    try {
      final response = await _dio.get(
        '/api/music/autocomplete/',
        queryParameters: {'q': query},
      );
      final data = response.data;
      return List<String>.from(data['suggestions'] ?? []);
    } catch (e) {
      debugPrint('Backend autocomplete error: $e');
      return [];
    }
  }

  /// Home feed: trending + charts + genres
  Future<Map<String, dynamic>> getHomeFeed() async {
    try {
      final response = await _dio.get('/api/music/feed/');
      final data = response.data;
      return {
        'trending': _parseMusicList(data['trending']),
        'charts': data['charts'] is Map
            ? (data['charts'] as Map).map((k, v) =>
                MapEntry(k.toString(), _parseMusicList(v)))
            : <String, List<MusicModel>>{},
        'genres': data['genres'] is Map
            ? (data['genres'] as Map).map((k, v) =>
                MapEntry(k.toString(), _parseMusicList(v)))
            : <String, List<MusicModel>>{},
      };
    } catch (e) {
      debugPrint('Backend home feed error: $e');
      return {'trending': <MusicModel>[], 'charts': {}, 'genres': {}};
    }
  }

  /// Chart tracks by region
  Future<List<MusicModel>> getChart(String region) async {
    try {
      final response = await _dio.get(
        '/api/music/charts/',
        queryParameters: {'region': region},
      );
      return _parseMusicList(response.data['tracks']);
    } catch (e) {
      debugPrint('Backend chart error: $e');
      return [];
    }
  }

  /// Genre tracks
  Future<List<MusicModel>> getGenreTracks(String genre) async {
    try {
      final response = await _dio.get(
        '/api/music/genres/',
        queryParameters: {'genre': genre},
      );
      return _parseMusicList(response.data['tracks']);
    } catch (e) {
      debugPrint('Backend genre error: $e');
      return [];
    }
  }

  List<MusicModel> _parseMusicList(dynamic data) {
    if (data is! List) return [];
    return data
        .map((json) => MusicModel.fromSupabase(Map<String, dynamic>.from(json)))
        .toList();
  }
}
