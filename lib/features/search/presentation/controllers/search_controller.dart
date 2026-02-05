import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/search/data/services/youtube_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'search_controller.g.dart';

@Riverpod(keepAlive: true)
YoutubeService youtubeService(YoutubeServiceRef ref) {
  final service = YoutubeService();
  ref.onDispose(service.dispose);
  return service;
}

@riverpod
class SearchController extends _$SearchController {
  @override
  FutureOr<List<Video>> build() {
    return [];
  }

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(youtubeServiceProvider);
      return await service.searchSongs(query);
    });
  }
}
