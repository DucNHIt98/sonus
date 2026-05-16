import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/presentation/providers/home_provider.dart';
import 'package:sonus/features/home/presentation/widgets/home_widgets.dart';
import 'package:sonus/features/home/presentation/widgets/chart_widgets.dart';
import 'package:sonus/features/home/presentation/providers/chart_provider.dart';
import 'package:sonus/features/premium/presentation/providers/premium_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);
    final premiumAsync = ref.watch(premiumControllerProvider);
    final isPremium = premiumAsync.valueOrNull?.isPremium ?? false;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Spotify-like deep gradient
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: homeState.when(
            data: (sections) {
              // Extract "Recently Played" for the top grid
              final recentlyPlayed = (sections['Recently Played'] ?? [])
                  .take(6)
                  .toList();
              // Other sections
              final otherSections = Map<String, List<Home>>.from(sections)
                ..remove('Recently Played')
                ..removeWhere((_, items) => items.isEmpty);

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh all charts
                  final regions = [
                    'V-Pop',
                    'K-Pop',
                    'US-UK',
                    'V-Rap',
                    'Billboard',
                  ];
                  for (final region in regions) {
                    await ref
                        .read(chartControllerProvider(region).notifier)
                        .refresh(region);
                  }
                  // Also refresh home sections if needed
                  // ref.refresh(homeControllerProvider);
                },
                color: Colors.red,
                backgroundColor: Colors.grey[900],
                child: CustomScrollView(
                  slivers: [
                    // App Bar / Greeting
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Good Morning',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.notifications_none, size: 24.r),
                              color: Colors.white,
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(Icons.history, size: 24.r),
                              color: Colors.white,
                              onPressed: () => context.push('/recently-played'),
                            ),
                            IconButton(
                              icon: Icon(Icons.person, size: 24.r),
                              color: Colors.white,
                              onPressed: () {
                                context.push('/profile');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recently Played Grid (2 columns)
                    if (recentlyPlayed.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8.h,
                                crossAxisSpacing: 8.w,
                                childAspectRatio: 3.0,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return HomeShortcutCard(
                              item: recentlyPlayed[index],
                            );
                          }, childCount: recentlyPlayed.length),
                        ),
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: 12.h)),

                    // Genre Grid (2 columns)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Genres',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            SizedBox(
                              height: 120.h,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 8,
                                itemBuilder: (context, index) {
                                  final genres = [
                                    'Pop',
                                    'Rock',
                                    'Jazz',
                                    'Lofi',
                                    'hiphop',
                                    'Electronic',
                                    'Country',
                                    'Chillout',
                                  ];
                                  final genre = genres[index];
                                  return Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: _GenreCard(genre: genre),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    if (isPremium)
                      // Supermix Card
                      const SliverToBoxAdapter(child: SupermixCard()),

                    if (otherSections.isNotEmpty)
                      // Horizontal Sections returned by the home feed.
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final title = otherSections.keys.elementAt(index);
                          final items = otherSections[title]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HomeSectionHeader(title: title),
                              SizedBox(
                                height: 220
                                    .h, // Increased height to prevent overflow
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: items.length,
                                  itemBuilder: (context, i) {
                                    return HomeHorizontalCard(item: items[i]);
                                  },
                                ),
                              ),
                            ],
                          );
                        }, childCount: otherSections.length),
                      ),

                    SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                    if (isPremium) ...[
                      // Regional Charts
                      const SliverToBoxAdapter(
                        child: ChartSection(
                          title: 'Top V-Pop',
                          region: 'V-Pop',
                          playlistId: 'PL4fGSI1pDJn5nSvnBmqp6Yrk6z8WpI9lY',
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: ChartSection(
                          title: 'K-Pop Rising',
                          region: 'K-Pop',
                          playlistId: 'PL4fGSI1pDJn6jXS_Tv_N9B8Z0HTRVJE0m',
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: ChartSection(
                          title: 'US-UK Hits',
                          region: 'US-UK',
                          playlistId: 'PL4fGSI1pDJn5kI81J1fYxTz8uUXpZAzp1',
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: ChartSection(
                          title: 'Top 50 V-Rap',
                          region: 'V-Rap',
                          playlistId: 'NCT_V_Rap',
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: ChartSection(
                          title: 'Top 50 Billboard Global',
                          region: 'Billboard',
                          playlistId: 'NCT_Billboard',
                        ),
                      ),
                    ],

                    SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                  ],
                ),
              );
            },
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenreCard extends ConsumerWidget {
  final String genre;

  const _GenreCard({required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () =>
          context.pushNamed('genre-detail', pathParameters: {'name': genre}),
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              _buildGradientBackground(),

              // Genre Name
              Padding(
                padding: EdgeInsets.all(12.r),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    genre == 'hiphop' ? 'Hip Hop' : genre,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getGenreColor(genre),
            _getGenreColor(genre).withOpacity(0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.3,
              child: Icon(Icons.music_note, size: 60.r, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Pop':
        return Colors.pink;
      case 'Rock':
        return Colors.red;
      case 'Jazz':
        return Colors.orange;
      case 'Lofi':
        return Colors.deepPurple;
      case 'Hip Hop':
      case 'hiphop':
        return Colors.blue;
      case 'Electronic':
        return Colors.cyan;
      case 'Country':
        return Colors.brown;
      case 'Chillout':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
