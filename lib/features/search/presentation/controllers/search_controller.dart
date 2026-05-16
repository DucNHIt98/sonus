import 'dart:async';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/search/data/services/smart_search_service.dart';

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
  final Map<String, ({List<MusicModel> results, bool truncated})> _resultCache =
      {};
  final Map<String, List<String>> _suggestionCache = {};
  Timer? _suggestionDebounce;
  int _suggestionRequestId = 0;
  int _searchRequestId = 0;

  @override
  FutureOr<SearchState> build() async {
    ref.onDispose(() => _suggestionDebounce?.cancel());
    final history = await _loadHistory();
    return SearchState(history: history);
  }

  Future<List<String>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historyKey) ?? [];
  }

  Future<void> _saveHistory(String query) async {
    if (query.trim().isEmpty) return;
    final currentState = state.value ?? const SearchState();
    final history = Set<String>.from(currentState.history);
    history.remove(query);
    final newHistory = [query, ...history].take(10).toList();
    state = AsyncValue.data(currentState.copyWith(history: newHistory));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, newHistory);
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
    final normalized = query.trim().toLowerCase();
    _suggestionDebounce?.cancel();

    if (normalized.length < 2) {
      state = AsyncValue.data(state.value!.copyWith(suggestions: []));
      return;
    }

    final cached = _suggestionCache[normalized];
    if (cached != null) {
      state = AsyncValue.data(state.value!.copyWith(suggestions: cached));
      return;
    }

    final requestId = ++_suggestionRequestId;
    _suggestionDebounce = Timer(const Duration(milliseconds: 250), () async {
      final backend = ref.read(backendServiceProvider);
      final suggestions = await backend.autocomplete(normalized);
      if (requestId != _suggestionRequestId) return;
      _suggestionCache[normalized] = suggestions;
      state = AsyncValue.data(state.value!.copyWith(suggestions: suggestions));
    });
  }

  Future<void> search(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return;
    final requestId = ++_searchRequestId;

    final currentState = state.value ?? const SearchState();
    state = AsyncValue.data(
      currentState.copyWith(suggestions: [], isLoading: true, error: null),
    );

    unawaited(_saveHistory(query));

    final cached = _resultCache[normalized];
    if (cached != null) {
      state = AsyncValue.data(
        state.value!.copyWith(
          results: cached.results,
          truncated: cached.truncated,
          isLoading: false,
          error: null,
        ),
      );
      return;
    }

    final result = await AsyncValue.guard(() async {
      final service = ref.read(smartSearchServiceProvider);
      return await service.search(query);
    });

    result.when(
      data: (data) {
        if (requestId != _searchRequestId) return;
        _resultCache[normalized] = data;
        state = AsyncValue.data(
          state.value!.copyWith(
            results: data.results,
            truncated: data.truncated,
            isLoading: false,
            error: null,
          ),
        );
      },
      error: (err, stack) {
        if (requestId != _searchRequestId) return;
        state = AsyncValue.data(
          state.value!.copyWith(isLoading: false, error: err.toString()),
        );
      },
      loading: () => {},
    );
  }
}
