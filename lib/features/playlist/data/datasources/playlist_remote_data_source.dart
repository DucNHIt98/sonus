import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonus/core/network/supabase_provider.dart';
import 'package:sonus/features/home/data/models/home_model.dart'; // Using HomeModel for songs as well for simplicity

part 'playlist_remote_data_source.g.dart';

@riverpod
PlaylistRemoteDataSource playlistRemoteDataSource(
  PlaylistRemoteDataSourceRef ref,
) {
  return PlaylistRemoteDataSourceImpl(ref.read(supabaseClientProvider));
}

abstract class PlaylistRemoteDataSource {
  Future<List<HomeModel>> getPlaylistSongs(String playlistId);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final SupabaseClient _client;

  PlaylistRemoteDataSourceImpl(this._client);

  @override
  Future<List<HomeModel>> getPlaylistSongs(String playlistId) async {
    try {
      // Join playlist_songs -> songs -> artists
      final response = await _client
          .from('playlist_songs')
          .select('*, songs(*, artists(name))')
          .eq('playlist_id', playlistId);

      final data = response as List<dynamic>;
      debugPrint(
        'Playlist: Fetched ${data.length} songs for playlist $playlistId',
      );

      return data
          .map((json) {
            final songData = json['songs'];
            if (songData == null) return null;

            final artist = songData['artists'] != null
                ? songData['artists']['name']
                : 'Unknown Artist';

            return HomeModel(
              id: songData['id'],
              title: songData['title'],
              subtitle: artist,
              imageUrl: songData['image_url'] ?? '',
              audioUrl: songData['audio_url'] ?? '',
            );
          })
          .whereType<HomeModel>()
          .toList();
    } catch (e, stack) {
      debugPrint('Error fetching playlist songs: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }
}
