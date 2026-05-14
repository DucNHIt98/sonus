import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/home/data/models/home_model.dart';

part 'playlist_remote_data_source.g.dart';

@riverpod
PlaylistRemoteDataSource playlistRemoteDataSource(
  PlaylistRemoteDataSourceRef ref,
) {
  return PlaylistRemoteDataSourceImpl(ref.read(backendServiceProvider));
}

abstract class PlaylistRemoteDataSource {
  Future<List<HomeModel>> getPlaylistSongs(String playlistId);
}

class PlaylistRemoteDataSourceImpl implements PlaylistRemoteDataSource {
  final BackendService _backend;

  PlaylistRemoteDataSourceImpl(this._backend);

  @override
  Future<List<HomeModel>> getPlaylistSongs(String playlistId) async {
    try {
      final detail = await _backend.getPlaylistDetail(playlistId);
      if (detail == null) return [];

      final songs = (detail['songs'] as List?) ?? [];
      return songs.map((json) {
        final map = json as Map<String, dynamic>;
        return HomeModel(
          id: map['id'] ?? '',
          title: map['title'] ?? '',
          subtitle: map['subtitle'] ?? 'Unknown Artist',
          imageUrl: map['image_url'] ?? '',
          audioUrl: map['audio_url'] ?? '',
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('Error fetching playlist songs: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }
}
