import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';

part 'genre_provider.g.dart';

@Riverpod(keepAlive: true)
class GenreController extends _$GenreController {
  @override
  Future<List<MusicModel>> build(String genre) async {
    final backend = ref.read(backendServiceProvider);
    return backend.getGenreTracks(genre);
  }

  Future<void> refresh(String genre) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(genre));
  }
}
