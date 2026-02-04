import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/presentation/providers/home_provider.dart';
import 'package:sonus/features/home/presentation/widgets/home_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeControllerProvider);

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
              final recentlyPlayed = sections['Recently Played'] ?? [];
              // Other sections
              final otherSections = Map<String, List<Home>>.from(sections)
                ..remove('Recently Played');

              return CustomScrollView(
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
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.settings, size: 24.r),
                            color: Colors.white,
                            onPressed: () {},
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8.h,
                          crossAxisSpacing: 8.w,
                          childAspectRatio: 3.0,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return HomeShortcutCard(item: recentlyPlayed[index]);
                        }, childCount: recentlyPlayed.length),
                      ),
                    ),

                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),

                  // Horizontal Sections
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final title = otherSections.keys.elementAt(index);
                      final items = otherSections[title]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeSectionHeader(title: title),
                          SizedBox(
                            height:
                                220.h, // Increased height to prevent overflow
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

                  SliverToBoxAdapter(child: SizedBox(height: 180.h)),
                ],
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
