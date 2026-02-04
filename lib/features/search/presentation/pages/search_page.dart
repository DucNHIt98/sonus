import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/features/search/presentation/widgets/search_widgets.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Same gradient as Home Page
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
                      const CustomSearchBar(),
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
                              'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=600&q=80', // Abstract Smoke/Pink
                          dummyColor: Colors.purple,
                        ),
                        FeaturedCard(
                          title: 'Daily Mix 2',
                          subtitle: 'Made for you',
                          imageUrl:
                              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=600&q=80', // Abstract Landscape
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

                // 5. Vertical List
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SongTile(
                      title: 'Bye Bye',
                      artist: 'Marshmello, Juice WRLD',
                      duration: '2:09',
                      imageUrl:
                          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80', // Portrait 1
                    ),
                    const SongTile(
                      title: 'I Like You',
                      artist: 'Post Malone, Doja Cat',
                      duration: '4:03',
                      imageUrl:
                          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80', // Portrait 2
                    ),
                    const SongTile(
                      title: 'Fountains',
                      artist: 'Drake, Tems',
                      duration: '3:18',
                      imageUrl:
                          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=150&q=80', // Abstract
                    ),
                    const SongTile(
                      title: 'Die For You',
                      artist: 'The Weeknd, Ariana Grande',
                      duration: '3:52',
                      imageUrl:
                          'https://images.unsplash.com/photo-1485206412256-701ccc5b93ca?auto=format&fit=crop&w=150&q=80', // Music mood
                    ),
                    // Extra space for bottom bar
                    SizedBox(height: 180.h),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
