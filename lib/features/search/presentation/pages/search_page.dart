import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/search/presentation/widgets/search_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/features/search/presentation/controllers/search_controller.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
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
                                'Welcome back!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'What do you feel like today?',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              CustomSearchBar(
                                controller: _searchController,
                                focusNode: _focusNode,
                                onChanged: (value) {
                                  ref
                                      .read(searchControllerProvider.notifier)
                                      .getSuggestions(value);
                                  setState(() {
                                    _isSearching = value.isNotEmpty;
                                  });
                                },
                                onSubmitted: (query) {
                                  ref
                                      .read(searchControllerProvider.notifier)
                                      .search(query);
                                  _focusNode.unfocus();
                                  setState(() {
                                    _isSearching = false;
                                  });
                                },
                              ),
                              SizedBox(height: 32.h),
                            ],
                          ),
                        ),

                        // Nếu đang có kết quả search thì hiện kết quả
                        if (searchState.results.isNotEmpty && !_isSearching)
                          ..._buildSearchResults(searchState)
                        else
                          ..._buildDefaultContent(),
                      ],
                    ),

                    // Overlay gợi ý hoặc lịch sử
                    if (_focusNode.hasFocus) _buildOverlay(searchState),
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
              color: Colors.black.withOpacity(0.5),
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
                ref.read(searchControllerProvider.notifier).search(item);
                _focusNode.unfocus();
                setState(() {
                  _isSearching = false;
                });
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults(SearchState searchState) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Text(
            'Search Results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final video = searchState.results[index];
          return InkWell(
            onTap: () async {
              final songMetadata = Home(
                id: video.id.value,
                title: video.title,
                subtitle: video.author,
                imageUrl: video.thumbnails.highResUrl,
                source: 'youtube',
                youtubeId: video.id.value,
                duration: video.duration,
              );

              ref
                  .read(playerControllerProvider.notifier)
                  .playSelectedSongWithMetadata(songMetadata);

              if (context.mounted) {
                context.pushNamed('player');
              }
            },
            child: SongTile(
              title: video.title,
              artist: video.author,
              duration: video.duration?.toString().split('.').first ?? '',
              imageUrl: video.thumbnails.mediumResUrl,
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
          padding: EdgeInsets.only(bottom: 24.h),
          child: const CategoryTabs(),
        ),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 240.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              FeaturedCard(
                title: 'R&B Playlist',
                subtitle: 'Chill your mind',
                imageUrl:
                    'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=600&q=80',
                dummyColor: Colors.purple,
              ),
              FeaturedCard(
                title: 'Daily Mix 2',
                subtitle: 'Made for you',
                imageUrl:
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80',
                dummyColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 32.h, bottom: 16.h),
          child: Text(
            'Your favourites',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate([
          const SongTile(
            title: 'Bye Bye',
            artist: 'Marshmello, Juice WRLD',
            duration: '2:09',
            imageUrl:
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
          ),
          SizedBox(height: 180.h),
        ]),
      ),
    ];
  }
}
