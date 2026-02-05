import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/library/data/datasources/library_remote_data_source.dart';
import 'package:sonus/features/library/domain/repositories/library_repository.dart';

part 'library_repository_impl.g.dart';

@riverpod
LibraryRepository libraryRepository(LibraryRepositoryRef ref) {
  return LibraryRepositoryImpl(ref.read(libraryRemoteDataSourceProvider));
}

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource _remoteDataSource;

  LibraryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Home>> getUserPlaylists() async {
    final models = await _remoteDataSource.getUserPlaylists();
    return models.map((e) => e.toEntity()).toList();
  }
}
