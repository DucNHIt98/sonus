import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/home/data/models/home_model.dart';

part 'library_remote_data_source.g.dart';

@riverpod
LibraryRemoteDataSource libraryRemoteDataSource(
  LibraryRemoteDataSourceRef ref,
) {
  return LibraryRemoteDataSourceImpl(ref.read(backendServiceProvider));
}

abstract class LibraryRemoteDataSource {
  Future<List<HomeModel>> getUserPlaylists();
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final BackendService _backend;

  LibraryRemoteDataSourceImpl(this._backend);

  @override
  Future<List<HomeModel>> getUserPlaylists() async {
    try {
      final playlists = await _backend.getPlaylists();
      return playlists.map((json) {
        return HomeModel(
          id: json['id'] ?? '',
          title: json['title'] ?? '',
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
