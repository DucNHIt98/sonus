import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonus/core/network/supabase_provider.dart';
import 'package:sonus/features/home/data/models/home_model.dart';

part 'home_remote_data_source.g.dart';

@riverpod
HomeRemoteDataSource homeRemoteDataSource(HomeRemoteDataSourceRef ref) {
  return HomeRemoteDataSourceImpl(ref.read(supabaseClientProvider));
}

abstract class HomeRemoteDataSource {
  Future<List<HomeModel>> getRecentlyPlayed();

  Future<List<HomeModel>> getPlaylists();
  Future<void> addToRecentlyPlayed(HomeModel song);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient _client;

  HomeRemoteDataSourceImpl(this._client);

  @override
  Future<void> addToRecentlyPlayed(HomeModel song) async {
    try {
      debugPrint('Saving song to History: ${song.title}');

      final user = _client.auth.currentUser;
      if (user == null) return;

      // Ensure song exists in songs table
      await _client.from('songs').upsert({
        'id': song.id,
        'title': song.title,
        'subtitle': song.subtitle,
        'image_url': song.imageUrl,
        'source': song.source,
      });

      // Update play history
      await _client.from('play_history').upsert({
        'user_id': user.id,
        'song_id': song.id,
        'last_played': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, song_id');

      debugPrint('Successfully saved to play_history');
    } catch (e) {
      debugPrint('Error saving to play_history: $e');
    }
  }

  @override
  Future<List<HomeModel>> getRecentlyPlayed() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      // Fetch from play_history JOINED with songs
      final response = await _client
          .from('play_history')
          .select('songs(*)')
          .eq('user_id', user.id)
          .order('last_played', ascending: false)
          .limit(20);

      final data = response as List<dynamic>;
      debugPrint(
        'Fetched ${data.length} recently played items from play_history',
      );

      return data.where((item) => item['songs'] != null).map((item) {
        final song = item['songs'];
        return HomeModel(
          id: song['id'] ?? '',
          title: song['title'] ?? '',
          subtitle: song['subtitle'] ?? '',
          imageUrl: song['image_url'] ?? '',
          source: song['source'] ?? 'youtube',
          youtubeId: song['id'],
          durationMs: (song['duration'] as int? ?? 0) * 1000,
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('Error fetching recently played: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  @override
  Future<List<HomeModel>> getPlaylists() async {
    try {
      final response = await _client.from('playlists').select();
      final data = response as List<dynamic>;
      debugPrint('Fetched ${data.length} playlists');
      return data.map((json) {
        return HomeModel(
          id: json['id'],
          title: json['title'],
          subtitle: json['description'] ?? 'Playlist',
          imageUrl: json['image_url'] ?? '',
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('Error fetching playlists: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }
}
