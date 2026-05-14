import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';

part 'chart_provider.g.dart';

@Riverpod(keepAlive: true)
class ChartController extends _$ChartController {
  @override
  Future<List<MusicModel>> build(String region, {String? playlistId}) async {
    final backend = ref.read(backendServiceProvider);
    return backend.getChart(region);
  }

  Future<void> refresh(String region, {String? playlistId}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build(region, playlistId: playlistId));
  }
}
