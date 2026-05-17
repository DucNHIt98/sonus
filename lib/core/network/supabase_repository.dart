import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

part 'supabase_repository.g.dart';

@Riverpod(keepAlive: true)
SupabaseRepository supabaseRepository(SupabaseRepositoryRef ref) {
  return SupabaseRepository(ref.read(backendServiceProvider));
}

class SupabaseRepository {
  final BackendService _backend;

  SupabaseRepository(this._backend);

  /// Updates last_played timestamp via backend record endpoint (no count increment)
  Future<void> updateLastPlayed(Home song) async {
    final songId = song.youtubeId ?? song.id;
    await _backend.recordPlay(
      songId: songId,
      title: song.title,
      subtitle: song.subtitle,
      imageUrl: song.imageUrl,
      duration: song.duration?.inSeconds ?? 0,
    );
  }

  /// Increments play count. Called at 50% playback — uses same backend endpoint
  Future<void> upsertPlayHistory(Home song) async {
    final songId = song.youtubeId ?? song.id;
    await _backend.recordPlay(
      songId: songId,
      title: song.title,
      subtitle: song.subtitle,
      imageUrl: song.imageUrl,
      duration: song.duration?.inSeconds ?? 0,
    );
  }

  /// Gets the 10 most recently played songs
  Future<List<Home>> getRecentHistory() async {
    final history = await _backend.getPlayHistory(limit: 10);
    return history.map((item) {
      final song = item['song'] as Map<String, dynamic>? ?? {};
      return Home(
        id: song['id'] ?? '',
        title: song['title'] ?? '',
        subtitle: song['subtitle'] ?? '',
        imageUrl: song['image_url'] ?? '',
        source: song['source'] ?? 'youtube',
        youtubeId: song['id'],
        duration: Duration(seconds: (song['duration'] ?? 0) as int),
      );
    }).toList();
  }

  /// Lấy danh sách ID các video người dùng đã từng nghe
  Future<Set<String>> getHistoryVideoIds() async {
    final history = await _backend.getPlayHistory(limit: 9999);
    return history
        .map((item) {
          final song = item['song'] as Map<String, dynamic>? ?? {};
          return song['id'] as String? ?? '';
        })
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Lấy danh sách bài hát hay nghe nhất
  Future<List<Home>> getMostPlayedSongs(int limit) async {
    final top = await _backend.getTopPlayed(limit: limit);
    return top.map((item) {
      final song = item['song'] as Map<String, dynamic>? ?? {};
      return Home(
        id: song['id'] ?? '',
        title: song['title'] ?? '',
        subtitle: song['subtitle'] ?? '',
        imageUrl: song['image_url'] ?? '',
        source: song['source'] ?? 'youtube',
        youtubeId: song['id'],
        duration: Duration(seconds: (song['duration'] ?? 0) as int),
      );
    }).toList();
  }

  // --- Profile Features (delegated to BackendService) ---

  Future<Map<String, dynamic>?> getUserProfile() async {
    return _backend.getCurrentUser();
  }

  Future<int> getPlayHistoryCount() async {
    final user = await _backend.getCurrentUser();
    final stats = user?['stats'] as Map<String, dynamic>?;
    return stats?['listened_count'] as int? ?? 0;
  }

  Future<int> getFavoritesCount() async {
    return _backend.getFavoritesCount();
  }

  Future<int> getPlaylistsCount() async {
    final user = await _backend.getCurrentUser();
    final stats = user?['stats'] as Map<String, dynamic>?;
    return stats?['playlists_count'] as int? ?? 0;
  }

  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final success = await _backend.updateCurrentUser(displayName: displayName);
    if (!success) throw Exception('Failed to update profile');
  }

  Future<String> uploadAvatar(File file) async {
    final url = await _backend.uploadAvatar(file);
    if (url == null) throw Exception('Failed to upload avatar');
    return url;
  }

  // --- Library features ---

  Future<void> saveSongToLibrary(MusicModel song) async {
    await _backend.recordPlay(
      songId: song.id,
      title: song.title,
      subtitle: song.artist,
      imageUrl: song.albumArt,
      duration: song.duration?.inSeconds ?? 0,
    );
  }

  Future<void> syncJamendoToSupabase(Home song) async {
    final songId = song.jamendoId ?? song.id;
    await _backend.recordPlay(
      songId: songId,
      title: song.title,
      subtitle: song.subtitle,
      imageUrl: song.imageUrl,
      duration: song.duration?.inSeconds ?? 0,
    );
  }

  Future<void> fetchAndSyncJamendo() async {
    // No-op: backend already handles Jamendo sync via /api/music/feed/
  }

  Future<List<MusicModel>> getSongsByGenre(String genre) async {
    final tracks = await _backend.getGenreTracks(genre);
    return tracks;
  }

  Future<void> upsertGenreSongs(List<MusicModel> songs, String genre) async {
    // No-op: backend handles genre upsert
  }

  Future<List<MusicModel>> getTrendingSongs(String region) async {
    final feed = await _backend.getHomeFeed();
    return feed['trending'] as List<MusicModel>? ?? [];
  }

  Future<void> upsertTrendingSongs(
    List<MusicModel> songs,
    String region,
  ) async {
    // No-op: backend handles trending upsert
  }
}
