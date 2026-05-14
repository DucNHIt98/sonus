import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

part 'ai_recommend_service.g.dart';

@Riverpod(keepAlive: true)
AiRecommendService aiRecommendService(AiRecommendServiceRef ref) {
  return AiRecommendService(ref.read(backendServiceProvider));
}

class AiRecommendService {
  final BackendService _backend;

  AiRecommendService(this._backend);

  Future<List<MusicModel>> getRecommendations(String songId) async {
    try {
      return await _backend.getRecommendations(songId);
    } catch (e) {
      debugPrint('AI recommend error: $e');
      return [];
    }
  }

  /// Kept for backward compatibility with player controller
  Future<List<Home>> getRecommendedSongs(
    String title,
    String artist,
    dynamic youtubeService, {
    int count = 5,
  }) async {
    final recs = await _backend.getRecommendationsByTitle(title, artist);
    return recs.map((m) => m.toEntity()).toList();
  }
}
