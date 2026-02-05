import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonus/core/network/supabase_provider.dart';
import 'package:sonus/features/home/data/models/home_model.dart';

part 'library_remote_data_source.g.dart';

@riverpod
LibraryRemoteDataSource libraryRemoteDataSource(
  LibraryRemoteDataSourceRef ref,
) {
  return LibraryRemoteDataSourceImpl(ref.read(supabaseClientProvider));
}

abstract class LibraryRemoteDataSource {
  Future<List<HomeModel>> getUserPlaylists();
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final SupabaseClient _client;

  LibraryRemoteDataSourceImpl(this._client);

  @override
  Future<List<HomeModel>> getUserPlaylists() async {
    try {
      // Fetch playlists where user_id matches current user OR is public
      // For now, fetching all public playlists or just all playlists as per RLS
      final response = await _client.from('playlists').select();

      final data = response as List<dynamic>;
      debugPrint('Library: Fetched ${data.length} playlists');

      return data.map((json) {
        return HomeModel(
          id: json['id'],
          title: json['title'],
          subtitle: json['description'] ?? 'Playlist',
          imageUrl: json['image_url'] ?? '',
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('Error fetching user playlists: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }
}
