import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final BackendService _backend;

  HomeRepositoryImpl(this._backend);

  @override
  Future<Map<String, List<Home>>> getHomeData() async {
    final feed = await _backend.getHomeFeed();

    final trending = (feed['trending'] as List<MusicModel>)
        .map((e) => e.toEntity())
        .toList();

    final bySource = <String, List<Home>>{};
    bySource['Trending'] = trending;

    final charts = feed['charts'] as Map<String, List<MusicModel>>;
    for (final entry in charts.entries) {
      final label = _chartLabel(entry.key);
      bySource[label] = entry.value.map((e) => e.toEntity()).toList();
    }

    final genres = feed['genres'] as Map<String, List<MusicModel>>;
    for (final entry in genres.entries) {
      final label = entry.key.toUpperCase();
      bySource[label] = entry.value.map((e) => e.toEntity()).toList();
    }

    return bySource;
  }

  @override
  Future<void> addToRecentlyPlayed(Home song) async {}

  String _chartLabel(String region) {
    const labels = {
      'v-pop': 'V-Pop Chart',
      'us-uk': 'US-UK Chart',
      'k-pop': 'K-Pop Chart',
      'v-rap': 'V-Rap Chart',
      'billboard': 'Billboard Chart',
    };
    return labels[region] ?? '${region.toUpperCase()} Chart';
  }
}
