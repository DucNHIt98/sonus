import 'package:sonus/features/home/data/datasources/home_remote_data_source.dart';
import 'package:sonus/features/home/data/models/home_model.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Map<String, List<Home>>> getHomeData() async {
    // Parallel fetch
    final results = await Future.wait([
      _remoteDataSource.getRecentlyPlayed(),
      _remoteDataSource.getPlaylists(),
    ]);

    final recentlyPlayed = results[0];
    final playlists = results[1];

    // MOCK: Still keeping some mock sections if arrays are empty or to fill up UI
    // In real app, you might have separate endpoints for each section.

    return {
      'Recently Played': recentlyPlayed.map((e) => e.toEntity()).toList(),
      'Your Top Mixes': playlists.map((e) => e.toEntity()).toList(),
      // 'Made For You': ...,
    };
  }

  @override
  Future<void> addToRecentlyPlayed(Home song) async {
    // Convert Entity to Model
    final model = HomeModel(
      id: song.id,
      title: song.title,
      subtitle: song.subtitle,
      imageUrl: song.imageUrl,
      audioUrl: song.audioUrl,
      source: song.source,
      youtubeId: song.youtubeId,
    );
    await _remoteDataSource.addToRecentlyPlayed(model);
  }
}
