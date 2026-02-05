import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/search/presentation/widgets/search_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/features/search/presentation/controllers/search_controller.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchControllerProvider);

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
            child: CustomScrollView(
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
                        onSubmitted: (query) {
                          ref
                              .read(searchControllerProvider.notifier)
                              .search(query);
                        },
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),

                // 2. Tabs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: const CategoryTabs(),
                  ),
                ),

                // 3. Search Results or Featured Content
                ...searchState.when(
                  data: (videos) {
                    if (videos.isEmpty) {
                      // Show Featured Content if no search results yet (or empty)
                      // Ideally we check if query was empty, but for now this works as initial state
                      // But wait, initial state is empty list.
                      // Let's assume empty list means "show default content".
                      // If user searched and found nothing, we might want to show "No results".
                      // For simplicity, let's keep showing featured content if empty for now,
                      // or checking additional state.
                      // Let's just overlay results if they exist.

                      return [
                        // 3. Featured Horizontal List
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

                        // 4. "Your Favourites" Label
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

                        // 5. Default List
                        SliverList(
                          delegate: SliverChildListDelegate([
                            const SongTile(
                              title: 'Bye Bye',
                              artist: 'Marshmello, Juice WRLD',
                              duration: '2:09',
                              imageUrl:
                                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80',
                            ),
                            // ... other static items
                            SizedBox(height: 180.h),
                          ]),
                        ),
                      ];
                    }

                    // Display Search Results
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
                          final video = videos[index];
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
                              duration:
                                  video.duration?.toString().split('.').first ??
                                  '',
                              imageUrl: video.thumbnails.mediumResUrl,
                            ),
                          );
                        }, childCount: videos.length),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 180.h)),
                    ];
                  },
                  loading: () => [
                    const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                  error: (err, stack) => [
                    SliverToBoxAdapter(
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
