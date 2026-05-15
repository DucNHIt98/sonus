import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/search/data/services/smart_search_service.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

part 'search_controller.freezed.dart';
part 'search_controller.g.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<MusicModel> results,
    @Default([]) List<String> suggestions,
    @Default([]) List<String> history,
    @Default(false) bool isLoading,
    @Default(false) bool truncated,
    String? error,
  }) = _SearchState;
}

@riverpod
class SearchController extends _$SearchController {
  static const String _historyKey = 'search_history';

  @override
  FutureOr<SearchState> build() async {
    final history = await _loadHistory();
    return SearchState(history: history);
  }

  Future<List<String>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> _saveHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final history = Set<String>.from(state.value?.history ?? []);
    history.remove(query); // Move to top
    final newHistory = [query, ...history].take(10).toList();
    await prefs.setStringList(_historyKey, newHistory);
    state = AsyncValue.data(state.value!.copyWith(history: newHistory));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    state = AsyncValue.data(state.value!.copyWith(history: []));
  }

  Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = List<String>.from(state.value?.history ?? []);
    history.remove(query);
    await prefs.setStringList(_historyKey, history);
    state = AsyncValue.data(state.value!.copyWith(history: history));
  }

  Future<void> getSuggestions(String query) async {
    if (query.isEmpty) {
      state = AsyncValue.data(state.value!.copyWith(suggestions: []));
      return;
    }
    final backend = ref.read(backendServiceProvider);
    final suggestions = await backend.autocomplete(query);
    state = AsyncValue.data(state.value!.copyWith(suggestions: suggestions));
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    final currentState = state.value ?? const SearchState();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, suggestions: []),
    );

    await _saveHistory(query);

    final result = await AsyncValue.guard(() async {
      final service = ref.read(smartSearchServiceProvider);
      return await service.search(query);
    });

    result.when(
      data: (data) {
        state = AsyncValue.data(
          state.value!.copyWith(results: data.results, truncated: data.truncated, isLoading: false, error: null),
        );
      },
      error: (err, stack) {
        state = AsyncValue.data(
          state.value!.copyWith(isLoading: false, error: err.toString()),
        );
      },
      loading: () => {},
    );
  }
}
