import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/jamendo_service.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/presentation/widgets/music_tile.dart';

import 'package:sonus/core/network/supabase_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_page.g.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Tự động load thêm khi còn cách cuối danh sách 200px
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(jamendoNotifierProvider.notifier).fetchMoreJamendoSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final jamendoAsync = ref.watch(jamendoNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Discover Jamendo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: jamendoAsync.when(
        data: (paginationState) {
          final songs = paginationState.songs;
          if (songs.isEmpty) {
            return const Center(
              child: Text(
                'No tracks found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: songs.length + (paginationState.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < songs.length) {
                final song = songs[index];
                return MusicTile(song: song, contextQueue: songs);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
class JamendoNotifier extends _$JamendoNotifier {
  int _currentOffset = 0;
  bool _isLoading = false;

  @override
  FutureOr<JamendoPaginationState> build() async {
    final songs = await ref
        .read(jamendoServiceProvider)
        .getDiscoveryMusic(offset: 0);
    _currentOffset = 20;

    _syncToSupabase(songs);

    return JamendoPaginationState(songs: songs);
  }

  Future<void> fetchMoreJamendoSongs() async {
    if (_isLoading) return;

    final currentPaginationState = state.value;
    if (currentPaginationState == null) return;

    _isLoading = true;
    state = AsyncValue.data(
      currentPaginationState.copyWith(isLoadingMore: true),
    );

    try {
      final newSongs = await ref
          .read(jamendoServiceProvider)
          .getDiscoveryMusic(offset: _currentOffset);

      if (newSongs.isNotEmpty) {
        final currentSongs = currentPaginationState.songs;

        // Logic lọc trùng lặp tại local để chắc chắn như yêu cầu
        final uniqueSongs = newSongs
            .where((s) => !currentSongs.any((exist) => exist.id == s.id))
            .toList();

        if (uniqueSongs.isNotEmpty) {
          _currentOffset += 20;
          state = AsyncValue.data(
            JamendoPaginationState(
              songs: [...currentSongs, ...uniqueSongs],
              isLoadingMore: false,
            ),
          );

          _syncToSupabase(uniqueSongs);
        } else {
          state = AsyncValue.data(
            currentPaginationState.copyWith(isLoadingMore: false),
          );
        }
      } else {
        state = AsyncValue.data(
          currentPaginationState.copyWith(isLoadingMore: false),
        );
      }
    } catch (e) {
      debugPrint('Error loading more Jamendo songs: $e');
      state = AsyncValue.data(
        currentPaginationState.copyWith(isLoadingMore: false),
      );
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _syncToSupabase(List<MusicModel> songs) async {
    try {
      final repository = ref.read(supabaseRepositoryProvider);
      for (final song in songs) {
        await repository.saveSongToLibrary(song);
      }
    } catch (e) {
      debugPrint('JamendoNotifier Sync Error: $e');
    }
  }
}

class JamendoPaginationState {
  final List<MusicModel> songs;
  final bool isLoadingMore;

  JamendoPaginationState({required this.songs, this.isLoadingMore = false});

  JamendoPaginationState copyWith({
    List<MusicModel>? songs,
    bool? isLoadingMore,
  }) {
    return JamendoPaginationState(
      songs: songs ?? this.songs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
