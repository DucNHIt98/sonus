import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonus/features/search/data/services/youtube_service.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

part 'search_controller.freezed.dart';
part 'search_controller.g.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<Video> results,
    @Default([]) List<String> suggestions,
    @Default([]) List<String> history,
    @Default(false) bool isLoading,
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
    final service = ref.read(youtubeServiceProvider);
    final suggestions = await service.getSearchSuggestions(query);
    state = AsyncValue.data(state.value!.copyWith(suggestions: suggestions));
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    final currentState = state.value ?? const SearchState();
    state = AsyncValue.data(
      currentState.copyWith(isLoading: true, suggestions: []),
    );

    await _saveHistory(query);

    final results = await AsyncValue.guard(() async {
      final service = ref.read(youtubeServiceProvider);
      final results = await service.searchSongs(query);

      if (results.isNotEmpty) {
        final notifier = ref.read(playerControllerProvider.notifier);
        for (var i = 0; i < (results.length > 3 ? 3 : results.length); i++) {
          notifier.preLoadSong(results[i].id.value);
        }
      }
      return results;
    });

    results.when(
      data: (data) {
        state = AsyncValue.data(
          state.value!.copyWith(results: data, isLoading: false, error: null),
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
