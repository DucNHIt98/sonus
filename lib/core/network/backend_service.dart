import 'dart:io';
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
  final Dio dio;

  BackendService(this.dio);

  // ==================== Audio Resolve ====================

  /// Resolves the full YouTube audio URL for a Deezer preview track
  Future<Home?> getFullVersion(Home deezerSong) async {
    try {
      final response = await dio.post(
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
      final response = await dio.post(
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

  /// Resolve audio from youtube_explode format (for player controller)
  Future<Map<String, dynamic>?> resolveAudio(String videoId) async {
    try {
      final response = await dio.post(
        '/api/music/resolve/',
        data: {'video_id': videoId},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Backend resolveAudio error: $e');
      return null;
    }
  }

  // ==================== Search ====================

  /// Multi-source search
  Future<List<MusicModel>> search({
    required String query,
    int limit = 10,
    String sources = 'youtube,jamendo,nct',
  }) async {
    try {
      final response = await dio.get(
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
      final response = await dio.get(
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

  // ==================== Home Feed ====================

  /// Home feed: trending + charts + genres
  Future<Map<String, dynamic>> getHomeFeed() async {
    try {
      final response = await dio.get('/api/music/feed/');
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
      final response = await dio.get(
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
      final response = await dio.get(
        '/api/music/genres/',
        queryParameters: {'genre': genre},
      );
      return _parseMusicList(response.data['tracks']);
    } catch (e) {
      debugPrint('Backend genre error: $e');
      return [];
    }
  }

  // ==================== Recommendations ====================

  /// AI song recommendations based on current song
  Future<List<MusicModel>> getRecommendations(String songId) async {
    return _fetchRecommendations({'song_id': songId});
  }

  /// AI recommendations by title+artist (for queue expansion when no song_id)
  Future<List<MusicModel>> getRecommendationsByTitle(
      String title, String artist) async {
    return _fetchRecommendations({'title': title, 'artist': artist});
  }

  Future<List<MusicModel>> _fetchRecommendations(
      Map<String, dynamic> params) async {
    try {
      final response =
          await dio.get('/api/recommendations/', queryParameters: params);
      return _parseMusicList(response.data['recommendations']);
    } catch (e) {
      debugPrint('Backend recommendations error: $e');
      return [];
    }
  }

  // ==================== Play History ====================

  /// Record a play (increment count or insert new). Called at 50% playback.
  Future<Map<String, dynamic>?> recordPlay({
    required String songId,
    required String title,
    String subtitle = '',
    String imageUrl = '',
    int? duration,
  }) async {
    try {
      final response = await dio.post(
        '/api/history/record/',
        data: {
          'song_id': songId,
          'title': title,
          'subtitle': subtitle,
          'image_url': imageUrl,
          'duration': duration ?? 0,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Backend recordPlay error: $e');
      return null;
    }
  }

  /// Get play history (most recently played first)
  Future<List<Map<String, dynamic>>> getPlayHistory({int limit = 20}) async {
    try {
      final response = await dio.get(
        '/api/history/',
        queryParameters: {'limit': limit},
      );
      final history = List<Map<String, dynamic>>.from(
          (response.data as Map)['history'] ?? []);
      return history;
    } catch (e) {
      debugPrint('Backend getPlayHistory error: $e');
      return [];
    }
  }

  /// Get top played songs (most played first)
  Future<List<Map<String, dynamic>>> getTopPlayed({int limit = 10}) async {
    try {
      final response = await dio.get(
        '/api/history/top/',
        queryParameters: {'limit': limit},
      );
      final top = List<Map<String, dynamic>>.from(
          (response.data as Map)['top'] ?? []);
      return top;
    } catch (e) {
      debugPrint('Backend getTopPlayed error: $e');
      return [];
    }
  }

  // ==================== Favorites ====================

  /// Get user's favorite songs
  Future<List<Map<String, dynamic>>> getFavorites() async {
    try {
      final response = await dio.get('/api/favorites/');
      return List<Map<String, dynamic>>.from(
          (response.data as Map)['favorites'] ?? []);
    } catch (e) {
      debugPrint('Backend getFavorites error: $e');
      return [];
    }
  }

  /// Toggle favorite state for a song
  Future<bool> toggleFavorite(String songId, {bool liked = true}) async {
    try {
      await dio.post(
        '/api/favorites/$songId/',
        data: {'liked': liked},
      );
      return true;
    } catch (e) {
      debugPrint('Backend toggleFavorite error: $e');
      return false;
    }
  }

  /// Check if user's profile has favorites count (from /auth/me/ stats)
  Future<int> getFavoritesCount() async {
    try {
      final response = await dio.get('/api/auth/me/');
      final stats = (response.data as Map)['stats'] as Map?;
      return stats?['favorites_count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== Playlists ====================

  /// Get all playlists
  Future<List<Map<String, dynamic>>> getPlaylists() async {
    try {
      final response = await dio.get('/api/playlists/');
      return List<Map<String, dynamic>>.from(
          (response.data as Map)['playlists'] ?? []);
    } catch (e) {
      debugPrint('Backend getPlaylists error: $e');
      return [];
    }
  }

  /// Create a new playlist
  Future<Map<String, dynamic>?> createPlaylist({
    required String title,
    String description = '',
    String imageUrl = '',
  }) async {
    try {
      final response = await dio.post(
        '/api/playlists/',
        data: {
          'title': title,
          'description': description,
          'image_url': imageUrl,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Backend createPlaylist error: $e');
      return null;
    }
  }

  /// Get playlist detail with songs
  Future<Map<String, dynamic>?> getPlaylistDetail(String playlistId) async {
    try {
      final response = await dio.get('/api/playlists/$playlistId/');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Backend getPlaylistDetail error: $e');
      return null;
    }
  }

  /// Update playlist metadata
  Future<Map<String, dynamic>?> updatePlaylist(
    String playlistId, {
    String? title,
    String? description,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      final response =
          await dio.patch('/api/playlists/$playlistId/', data: body);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Backend updatePlaylist error: $e');
      return null;
    }
  }

  /// Delete a playlist
  Future<bool> deletePlaylist(String playlistId) async {
    try {
      await dio.delete('/api/playlists/$playlistId/');
      return true;
    } catch (e) {
      debugPrint('Backend deletePlaylist error: $e');
      return false;
    }
  }

  /// Add a song to playlist
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      await dio.post(
        '/api/playlists/$playlistId/songs/',
        data: {'song_id': songId},
      );
      return true;
    } catch (e) {
      debugPrint('Backend addSongToPlaylist error: $e');
      return false;
    }
  }

  /// Remove a song from playlist
  Future<bool> removeSongFromPlaylist(
      String playlistId, String songId) async {
    try {
      await dio.delete('/api/playlists/$playlistId/songs/$songId/');
      return true;
    } catch (e) {
      debugPrint('Backend removeSongFromPlaylist error: $e');
      return false;
    }
  }

  // ==================== User Profile ====================

  /// Get current user profile (includes is_premium, premium_until, stats)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await dio.get('/api/auth/me/');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Backend getCurrentUser error: $e');
      return null;
    }
  }

  /// Update user profile (display name)
  Future<bool> updateCurrentUser({String? displayName}) async {
    try {
      final body = <String, dynamic>{};
      if (displayName != null) body['display_name'] = displayName;
      await dio.patch('/api/auth/me/', data: body);
      return true;
    } catch (e) {
      debugPrint('Backend updateCurrentUser error: $e');
      return false;
    }
  }

  /// Upload avatar as file (multipart)
  Future<String?> uploadAvatar(File file) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(file.path,
            filename: file.path.split('/').last),
      });
      final response =
          await dio.post('/api/auth/me/avatar/', data: formData);
      return response.data['avatar_url'] as String?;
    } catch (e) {
      debugPrint('Backend uploadAvatar error: $e');
      return null;
    }
  }

  // ==================== Helpers ====================

  /// Parse a list of maps to MusicModel list (for recommendations from backend)
  List<MusicModel> parseMusicList(dynamic data) {
    return _parseMusicList(data);
  }

  List<MusicModel> _parseMusicList(dynamic data) {
    if (data is! List) return [];
    return data
        .map((json) => MusicModel.fromSupabase(Map<String, dynamic>.from(json)))
        .toList();
  }
}
