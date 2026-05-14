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

  Future<List<MusicModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final results = await _backend.search(query: query);
      debugPrint('SmartSearch: returned ${results.length} results via backend');
      return results;
    } catch (e) {
      debugPrint('SmartSearch Error: $e');
      return [];
    }
  }
}
