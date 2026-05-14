import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/jamendo_service.dart';
import 'package:sonus/core/network/supabase_provider.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

part 'supabase_repository.g.dart';

@Riverpod(keepAlive: true)
SupabaseRepository supabaseRepository(SupabaseRepositoryRef ref) {
  return SupabaseRepository(
    ref.read(supabaseClientProvider),
    ref.read(jamendoServiceProvider),
  );
}

class SupabaseRepository {
  final SupabaseClient _client;
  final JamendoService _jamendoService;

  SupabaseRepository(this._client, this._jamendoService);

  /// Updates last_played timestamp for the current song immediately.
  /// Does NOT increment play count.
  Future<void> updateLastPlayed(Home song) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final songId = song.youtubeId ?? song.id;

    try {
      // Step 0: Ensure song exists in songs table
      await _client.from('songs').upsert({
        'id': songId,
        'title': song.title,
        'image_url': song.imageUrl,
        'duration': song.duration?.inSeconds ?? 0,
        'source': song.source,
        'subtitle': song.subtitle,
      });

      // Step 1: Check if record exists, then insert or update accordingly
      final existing = await _client
          .from('play_history')
          .select('count')
          .eq('user_id', user.id)
          .eq('song_id', songId)
          .maybeSingle();

      if (existing == null) {
        // New record → insert with count 0
        await _client.from('play_history').insert({
          'user_id': user.id,
          'song_id': songId,
          'last_played': DateTime.now().toIso8601String(),
          'count': 0,
        });
      } else {
        // Existing record → only update last_played, preserve count
        await _client
            .from('play_history')
            .update({'last_played': DateTime.now().toIso8601String()})
            .eq('user_id', user.id)
            .eq('song_id', songId);
      }

      debugPrint('Supabase: Updated last_played for $songId');
    } catch (e) {
      debugPrint('Supabase Error updating last_played: $e');
    }
  }

  /// Increments play count for the current user.
  /// Called when song reaches 50% playback.
  Future<void> upsertPlayHistory(Home song) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final songId = song.youtubeId ?? song.id;

    try {
      // Step 0: Ensure song exists in songs table (Fix FK constraint)
      await _client.from('songs').upsert({
        'id': songId,
        'title': song.title,
        'image_url': song.imageUrl,
        'duration': song.duration?.inSeconds ?? 0,
        'source': song.source,
        'subtitle': song.subtitle,
      });

      // Step 1: Check if record exists for this user and song
      final existing = await _client
          .from('play_history')
          .select('count')
          .eq('user_id', user.id)
          .eq('song_id', songId)
          .maybeSingle();

      if (existing == null) {
        // Step 2: Insert new record
        await _client.from('play_history').insert({
          'user_id': user.id,
          'song_id': songId,
          'count': 1,
          'last_played': DateTime.now().toIso8601String(),
        });
      } else {
        // Step 3: Increment count and update last_played
        final currentCount = existing['count'] as int;
        await _client
            .from('play_history')
            .update({
              'count': currentCount + 1,
              'last_played': DateTime.now().toIso8601String(),
            })
            .eq('user_id', user.id)
            .eq('song_id', songId);
      }

      debugPrint(
        'Supabase: Incremented play count for $songId | New Count: ${existing == null ? 1 : (existing['count'] as int) + 1}',
      );
    } catch (e) {
      debugPrint('Supabase Error incrementing play history: $e');
    }
  }

  /// Gets the 10 most recently played songs for the current user.
  Future<List<Home>> getRecentHistory() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('play_history')
          .select('count, last_played, songs(*)')
          .eq('user_id', user.id)
          .order('last_played', ascending: false)
          .limit(10);

      final data = response as List<dynamic>;

      return data.where((item) => item['songs'] != null).map((item) {
        final song = item['songs'];
        return Home(
          id: song['id'],
          title: song['title'],
          subtitle: song['subtitle'] ?? '',
          imageUrl: song['image_url'] ?? '',
          source: song['source'] ?? 'youtube',
          youtubeId: song['id'],
          duration: Duration(seconds: song['duration'] ?? 0),
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase Error fetching recent history: $e');
      return [];
    }
  }

  /// Lấy danh sách ID các video người dùng đã từng nghe
  Future<Set<String>> getHistoryVideoIds() async {
    try {
      final response = await _client.from('play_history').select('song_id');
      final data = response as List<dynamic>;
      return data.map((item) => item['song_id'] as String).toSet();
    } catch (e) {
      debugPrint('Supabase Error fetching history IDs: $e');
      return {};
    }
  }

  /// Lấy danh sách bài hát hay nghe nhất
  Future<List<Home>> getMostPlayedSongs(int limit) async {
    try {
      // Join play_history với bảng songs để lấy metadata đầy đủ
      final response = await _client
          .from('play_history')
          .select('count, songs(*)')
          .order('count', ascending: false)
          .limit(limit);

      final data = response as List<dynamic>;

      return data.map((item) {
        final song = item['songs'];
        return Home(
          id: song['id'],
          title: song['title'],
          subtitle: song['subtitle'] ?? '',
          imageUrl: song['image_url'] ?? '',
          source: song['source'] ?? 'youtube',
          youtubeId: song['id'],
          duration: Duration(seconds: song['duration'] ?? 0),
        );
      }).toList();
    } catch (e) {
      debugPrint('Supabase Error fetching most played: $e');
      return [];
    }
  }

  // --- Profile Features ---

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle(); // Use maybeSingle to avoid exception if not found
      return response;
    } catch (e) {
      debugPrint('Supabase Error fetching user profile: $e');
      return null;
    }
  }

  Future<int> getPlayHistoryCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;
    try {
      final response = await _client
          .from('play_history')
          .count(CountOption.exact)
          .eq('user_id', user.id);
      return response;
    } catch (e) {
      debugPrint('Supabase Error counting history: $e');
      return 0;
    }
  }

  Future<int> getFavoritesCount() async {
    final user = _client.auth.currentUser;
    if (user == null) return 0;
    try {
      final response = await _client
          .from('favorites')
          .count(CountOption.exact)
          .eq('user_id', user.id);
      return response;
    } catch (e) {
      // debugPrint('Supabase Error counting favorites: $e');
      return 0;
    }
  }

  Future<int> getPlaylistsCount() async {
    // Assuming counting public playlists or user's playlists
    // If user specific: .eq('user_id', user.id)
    // For now, let's count all playlists as a placeholder or user's if schema supports
    try {
      final response = await _client.from('playlists').count(CountOption.exact);
      return response;
    } catch (e) {
      return 0;
    }
  }

  /// Update user profile (display name, avatar url)
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final updates = <String, dynamic>{};

    if (displayName != null) updates['full_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    if (updates.isEmpty) return; // Nothing to update

    try {
      await _client.from('users').update(updates).eq('id', user.id);
    } catch (e) {
      debugPrint('Supabase Error updating profile: $e');
      rethrow;
    }
  }

  /// Convert avatar image to base64 data URL
  /// Bypasses Supabase Storage entirely — stores directly in users table
  Future<String> uploadAvatar(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final fileExt = file.path.split('.').last.toLowerCase();
      final mimeType = fileExt == 'png' ? 'image/png' : 'image/jpeg';

      final dataUrl = 'data:$mimeType;base64,$base64String';

      debugPrint(
        'Avatar converted to base64 | Size: ${(bytes.length / 1024).toStringAsFixed(1)} KB',
      );
      return dataUrl;
    } catch (e) {
      debugPrint('Error converting avatar: $e');
      rethrow;
    }
  }

  /// Search songs by title or artist (Level 1 SmartSearch)
  Future<List<MusicModel>> searchSongs(String query) async {
    try {
      final response = await _client
          .from('songs')
          .select()
          .or('title.ilike.%$query%,artist_names.ilike.%$query%')
          .limit(20); // Limit to top 20 matches

      return (response as List).map((e) => MusicModel.fromSupabase(e)).toList();
    } catch (e) {
      debugPrint('Supabase Search Error: $e');
      return [];
    }
  }

  /// Saves song metadata to Supabase 'songs' table (Hybrid Logic)
  Future<void> saveSongToLibrary(MusicModel song) async {
    try {
      // Check if song already exists
      final existing = await _client
          .from('songs')
          .select('id')
          .eq('id', song.id)
          .maybeSingle();

      if (existing == null) {
        final songData = song.toMap();

        // Handling logic for Deezer (audio_url handled by Python backend later)
        if (song.source == MusicSource.deezer) {
          songData['audio_url'] = null;
        }

        await _client.from('songs').insert(songData);
        debugPrint('Supabase: Saved new track: ${song.title}');
      }
    } catch (e) {
      debugPrint('Supabase Error saving song: $e');
    }
  }

  /// Syncs Jamendo track metadata to Supabase 'songs' table
  Future<void> syncJamendoToSupabase(Home song) async {
    // Legacy support or fallback
    try {
      final songId = song.jamendoId ?? song.id;

      // Check if song already exists
      final existing = await _client
          .from('songs')
          .select('id')
          .eq('id', songId)
          .maybeSingle();

      if (existing == null) {
        await _client.from('songs').upsert({
          'id': songId,
          'title': song.title,
          'subtitle': song.subtitle,
          'image_url': song.imageUrl,
          'audio_url': song.audioUrl,
          'source': 'jamendo',
          'duration': song.duration?.inSeconds ?? 0,
        });
        debugPrint('Supabase: Synced new Jamendo track: ${song.title}');
      }
    } catch (e) {
      debugPrint('Supabase Error syncing Jamendo track: $e');
    }
  }

  /// Fetches top tracks from Jamendo and syncs them to Supabase 'songs' table
  Future<void> fetchAndSyncJamendo() async {
    try {
      // 1. Fetch top tracks from Jamendo
      final List<MusicModel> songs = await _jamendoService.getDiscoveryMusic();

      if (songs.isEmpty) {
        debugPrint('Supabase: No songs fetched from Jamendo to sync.');
        return;
      }

      // 2. Prepare data for batch upsert
      final List<Map<String, dynamic>> syncData = songs
          .map(
            (song) => {
              'id': song.id,
              'title': song.title,
              'subtitle': song.artist, // Standardizing to 'subtitle'
              'album_name': song.albumName,
              'image_url': song.albumArt,
              'audio_url': song.audioUrl,
              'source': 'jamendo',
              'duration': song.duration?.inSeconds ?? 0,
            },
          )
          .toList();

      // 3. Perform batch upsert with onConflict: 'id'
      await _client.from('songs').upsert(syncData, onConflict: 'id');

      debugPrint(
        'Supabase: Successfully fetched and synced ${songs.length} songs from Jamendo.',
      );
    } catch (e) {
      debugPrint('Supabase Error in fetchAndSyncJamendo: $e');
    }
  }

  /// Get songs by genre from Supabase
  Future<List<MusicModel>> getSongsByGenre(String genre) async {
    try {
      final response = await _client
          .from('songs')
          .select()
          .eq('genre', genre)
          .limit(20);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MusicModel.fromSupabase(json)).toList();
    } catch (e) {
      debugPrint('Supabase Error in getSongsByGenre: $e');
      return [];
    }
  }

  /// Upsert a list of genre-tagged songs to Supabase
  Future<void> upsertGenreSongs(List<MusicModel> songs, String genre) async {
    try {
      if (songs.isEmpty) return;

      final List<Map<String, dynamic>> syncData = songs.map((song) {
        final map = song.toMap();
        map['genre'] = genre; // Ensure genre is set
        return map;
      }).toList();

      await _client.from('songs').upsert(syncData, onConflict: 'id');
      debugPrint(
        'Supabase: Successfully upserted ${songs.length} songs for genre: $genre',
      );
    } catch (e) {
      debugPrint('Supabase Error in upsertGenreSongs: $e');
    }
  }

  /// Get trending songs by region from Supabase
  Future<List<MusicModel>> getTrendingSongs(String region) async {
    try {
      final response = await _client
          .from('songs')
          .select()
          .eq('region', region)
          .eq('region', region)
          .eq('is_trending', true);
      // .order('trending_rank', ascending: true); // Removed as per user request

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => MusicModel.fromSupabase(json)).toList();
    } catch (e) {
      debugPrint('Supabase Error in getTrendingSongs: $e');
      return [];
    }
  }

  /// Upsert trending songs with region and rank
  Future<void> upsertTrendingSongs(
    List<MusicModel> songs,
    String region,
  ) async {
    try {
      if (songs.isEmpty) return;

      final List<Map<String, dynamic>> syncData = songs.map((song) {
        final map = song.toMap();
        map['region'] = region;
        map['is_trending'] = true;
        // Rank is already in song data if fetched from Deezer
        return map;
      }).toList();

      await _client.from('songs').upsert(syncData, onConflict: 'id');
      debugPrint(
        'Supabase: Successfully upserted ${songs.length} trending songs for region: $region',
      );
    } catch (e) {
      debugPrint('Supabase Error in upsertTrendingSongs: $e');
    }
  }
}
