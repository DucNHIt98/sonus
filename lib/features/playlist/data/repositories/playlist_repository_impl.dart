import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/playlist/data/datasources/playlist_remote_data_source.dart';
import 'package:sonus/features/playlist/domain/repositories/playlist_repository.dart';

part 'playlist_repository_impl.g.dart';

@riverpod
PlaylistRepository playlistRepository(PlaylistRepositoryRef ref) {
  return PlaylistRepositoryImpl(ref.read(playlistRemoteDataSourceProvider));
}

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remoteDataSource;

  PlaylistRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Home>> getPlaylistSongs(String playlistId) async {
    final models = await _remoteDataSource.getPlaylistSongs(playlistId);
    return models.map((e) => e.toEntity()).toList();
  }
}
