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
      // "Log nó ra" - Print song info
      debugPrint('Saving song to History/DB: ${song.toString()}');

      // Attempt to save to 'recently_played' table in Supabase
      // Assuming simple schema: id, title, artist, image_url, audio_url, created_at
      // We map 'subtitle' (entity) back to 'artist' (db column) if needed.
      // Or just dump the JSON if schema matches.

      final data = {
        'id': song.id, // ID from YouTube
        'title': song.title,
        'subtitle': song.subtitle,
        'image_url': song.imageUrl,
        'source': song.source,
        'youtube_id': song.youtubeId,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('recently_played').upsert(data);
      debugPrint('Successfully saved to recently_played');
    } catch (e) {
      debugPrint(
        'Error saving to recently_played (DB might not have this table?): $e',
      );
      // Fallback: Just log it as requested
    }
  }

  @override
  Future<List<HomeModel>> getRecentlyPlayed() async {
    try {
      // Fetch directly from recently_played table
      final response = await _client
          .from('recently_played')
          .select()
          .order('created_at', ascending: false)
          .limit(20);

      final data = response as List<dynamic>;
      debugPrint('Fetched ${data.length} recently played history items');

      return data.map((json) => HomeModel.fromJson(json)).toList();
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
