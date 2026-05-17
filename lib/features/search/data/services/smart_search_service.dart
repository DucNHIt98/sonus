import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';

part 'smart_search_service.g.dart';

@Riverpod(keepAlive: true)
SmartSearchService smartSearchService(SmartSearchServiceRef ref) {
  return SmartSearchService(ref.read(backendServiceProvider));
}

class SmartSearchService {
  final BackendService _backend;

  SmartSearchService(this._backend);

  Future<({List<MusicModel> results, bool truncated})> search(
    String query,
  ) async {
    if (query.trim().isEmpty) {
      return (results: <MusicModel>[], truncated: false);
    }
    try {
      return await _backend.search(query: query);
    } catch (e) {
      debugPrint('SmartSearch Error: $e');
      return (results: <MusicModel>[], truncated: false);
    }
  }
}
