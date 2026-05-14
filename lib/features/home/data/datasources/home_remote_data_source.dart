import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/features/home/data/models/home_model.dart';

part 'home_remote_data_source.g.dart';

@riverpod
HomeRemoteDataSource homeRemoteDataSource(HomeRemoteDataSourceRef ref) {
  return HomeRemoteDataSourceImpl(ref.read(backendServiceProvider));
}

abstract class HomeRemoteDataSource {
  Future<List<HomeModel>> getRecentlyPlayed();

  Future<List<HomeModel>> getPlaylists();
  Future<void> addToRecentlyPlayed(HomeModel song);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final BackendService _backend;

  HomeRemoteDataSourceImpl(this._backend);

  @override
  Future<void> addToRecentlyPlayed(HomeModel song) async {
    try {
      final user = await _getUserId();
      if (user == null) return;
      debugPrint('Saving song to History: ${song.title} (delegated to backend)');
    } catch (e) {
      debugPrint('Error saving to play_history: $e');
    }
  }

  @override
  Future<List<HomeModel>> getRecentlyPlayed() async {
    try {
      final feed = await _backend.getHomeFeed();
      final trending = feed['trending'] as List<MusicModel>;
      return trending
          .map((m) => HomeModel(
                id: m.id,
                title: m.title,
                subtitle: m.artist,
                imageUrl: m.albumArt,
                audioUrl: m.audioUrl ?? '',
                source: m.source.name,
                youtubeId: m.id,
                durationMs: m.duration?.inMilliseconds,
              ))
          .toList();
    } catch (e, stack) {
      debugPrint('Error fetching recently played: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  @override
  Future<List<HomeModel>> getPlaylists() async {
    return [];
  }

  Future<String?> _getUserId() async {
    return null;
  }
}
