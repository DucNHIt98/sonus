import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/search/presentation/widgets/search_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/features/search/presentation/controllers/search_controller.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/backend_service.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;
  Timer? _searchDebounce;
  bool _isSearching = false;
  String _lastSubmittedQuery = '';

  static const List<String> _quickSearches = [
    'vpop 2026',
    'lofi chill',
    'son tung mtp',
    'indie viet',
    'edm workout',
    'acoustic cafe',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    ref.read(searchControllerProvider.notifier).getSuggestions(value);

    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) _lastSubmittedQuery = '';
    });

    _searchDebounce?.cancel();
    if (query.isEmpty) {
      ref.read(searchControllerProvider.notifier).clearResults();
      return;
    }
    if (query.length < 2) return;

    _searchDebounce = Timer(const Duration(milliseconds: 520), () {
      _runSearch(query, keepFocus: true);
    });
  }

  void _runSearch(String query, {bool keepFocus = false}) {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    setState(() {
      _isSearching = false;
      _lastSubmittedQuery = normalized;
    });

    ref.read(searchControllerProvider.notifier).search(normalized);
    if (!keepFocus) _focusNode.unfocus();
  }

  void _selectQuickSearch(String query) {
    _searchDebounce?.cancel();
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    _runSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: searchAsync.when(
              data: (searchState) {
                return Stack(
                  children: [
                    CustomScrollView(
                      slivers: [
                        // 1. Header & Search Bar
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),
                              Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Find a track, artist, or mood. Results update while you type.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              CustomSearchBar(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onChanged: _onSearchChanged,
                                onSubmitted: _runSearch,
                              ),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),

                        if (searchState.isLoading)
                          ..._buildSearchLoading()
                        else if (searchState.error != null)
                          ..._buildSearchError(searchState.error!)
                        else if (searchState.results.isNotEmpty &&
                            !_isSearching)
                          ..._buildSearchResults(searchState)
                        else if (_lastSubmittedQuery.isNotEmpty)
                          ..._buildEmptySearchResults()
                        else
                          ..._buildDefaultContent(),
                      ],
                    ),

                    // Overlay gợi ý hoặc lịch sử
                    if (_focusNode.hasFocus && !searchState.isLoading)
                      _buildOverlay(searchState),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(SearchState searchState) {
    final showSuggestions = _searchController.text.isNotEmpty;
    final items = showSuggestions
        ? searchState.suggestions
        : searchState.history;

    if (items.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 155.h, // Ngay dưới SearchBar
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(maxHeight: 300.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: Icon(
                showSuggestions ? Icons.search : Icons.history,
                color: Colors.white54,
                size: 20.r,
              ),
              title: Text(
                item,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
              trailing: showSuggestions
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white54,
                        size: 16,
                      ),
                      onPressed: () {
                        ref
                            .read(searchControllerProvider.notifier)
                            .removeFromHistory(item);
                      },
                    ),
              onTap: () {
                _searchController.text = item;
                _searchController.selection = TextSelection.collapsed(
                  offset: item.length,
                );
                _runSearch(item);
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSearchLoading() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Column(
            children: List.generate(
              6,
              (index) => _SearchSkeletonTile(delay: index),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSearchError(String error) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Center(
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSearchResults(SearchState searchState) {
    final resultLabel = _lastSubmittedQuery.isEmpty
        ? 'Search results'
        : 'Results for "$_lastSubmittedQuery"';

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  resultLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${searchState.results.length} tracks',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      if (searchState.truncated)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: GestureDetector(
              onTap: () => context.push('/premium'),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars, color: Colors.amber, size: 20.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'Upgrade to Premium to see all results',
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 14.r,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final song = searchState.results[index];
          return InkWell(
            onTap: () async {
              // Map MusicModel to Home entity
              final songMetadata = Home(
                id: song.id,
                title: song.title,
                subtitle: song.artist,
                imageUrl: song.albumArt,
                source: song.source.name, // 'nct', 'jamendo', 'youtube'
                youtubeId: song.source == MusicSource.youtube ? song.id : null,
                audioUrl: song.audioUrl ?? '',
                duration: song.duration,
              );

              // 1. Play (Single song, let AI generate the rest)
              ref
                  .read(playerControllerProvider.notifier)
                  .playSelectedSongWithMetadata(songMetadata);

              if (context.mounted) {
                context.pushNamed('player');
              }
            },
            onHover: (_) {}, // Dummy to avoid InkWell flicker on mobile
            child: SongTile(
              title: song.title,
              artist: song.artist,
              source: song.source.name,
              duration: song.duration != null
                  ? '${song.duration!.inMinutes}:${(song.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
                  : '',
              imageUrl: song.albumArt,
              trailing: IconButton(
                icon: Icon(
                  Icons.playlist_add,
                  color: Colors.white70,
                  size: 24.r,
                ),
                onPressed: () => _showAddToPlaylistSheet(context, song),
              ),
            ),
          );
        }, childCount: searchState.results.length),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 180.h)),
    ];
  }

  List<Widget> _buildDefaultContent() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            'Start with a mood',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: _quickSearches
              .map(
                (query) => _QuickSearchChip(
                  label: query,
                  onTap: () => _selectQuickSearch(query),
                ),
              )
              .toList(),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 28.h)),
      SliverToBoxAdapter(
        child: _SearchHeroCard(
          onTap: () => _selectQuickSearch('new music friday'),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 28.h, bottom: 14.h),
          child: Text(
            'Search tips',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            _SearchTipRow(
              icon: Icons.graphic_eq,
              title: 'Use mood words',
              subtitle: 'Try "rainy lofi" or "late night r&b".',
            ),
            _SearchTipRow(
              icon: Icons.person_search,
              title: 'Artist + context works best',
              subtitle: 'Search "taylor acoustic" or "den vau chill".',
            ),
            SizedBox(height: 180.h),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildEmptySearchResults() {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 24.h),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.search_off, color: Colors.white70, size: 32.r),
                SizedBox(height: 14.h),
                Text(
                  'No tracks found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Try a shorter query, artist name, or one of the mood searches below.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 13.sp,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: _quickSearches.take(4).map((query) {
                    return _QuickSearchChip(
                      label: query,
                      onTap: () => _selectQuickSearch(query),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(child: SizedBox(height: 180.h)),
    ];
  }

  Future<void> _showAddToPlaylistSheet(
    BuildContext context,
    MusicModel song,
  ) async {
    final backend = ref.read(backendServiceProvider);
    final playlists = await backend.getPlaylists();

    if (!context.mounted) return;

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create a playlist first.')));
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF181818),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    'Add to playlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return ListTile(
                        leading: Container(
                          width: 44.w,
                          height: 44.w,
                          decoration: BoxDecoration(
                            color: Colors.grey[850],
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: const Icon(
                            Icons.queue_music,
                            color: Colors.white70,
                          ),
                        ),
                        title: Text(
                          playlist['title']?.toString() ?? 'Playlist',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          '${playlist['song_count'] ?? 0} songs',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        onTap: () async {
                          final ok = await backend.addSongToPlaylist(
                            playlist['id'].toString(),
                            song.id,
                            song: song,
                          );

                          if (!sheetContext.mounted) return;
                          Navigator.of(sheetContext).pop();

                          if (!mounted) return;
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Added to ${playlist['title'] ?? 'playlist'}'
                                    : 'Could not add song to playlist',
                              ),
                              backgroundColor: ok ? Colors.green : Colors.red,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickSearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSearchChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHeroCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(22.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF65100B), Color(0xFF171010)],
          ),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF65100B).withValues(alpha: 0.24),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New music Friday',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap to search fresh releases across Sonus sources.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 18.w),
            Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 26.r),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SearchTipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: const Color(0xFFB91C1C).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: const Color(0xFFFFA39E), size: 21.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12.sp,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchSkeletonTile extends StatelessWidget {
  final int delay;

  const _SearchSkeletonTile({required this.delay});

  @override
  Widget build(BuildContext context) {
    final opacity = 0.08 + (delay % 3) * 0.025;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.78,
                  child: Container(
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: opacity),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: Container(
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: opacity * 0.8),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
