import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/features/library/presentation/widgets/library_widgets.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Same gradient as Home & Search
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomScrollView(
              slivers: [
                // 1. Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const LibraryHeader(),
                  ),
                ),

                // 2. Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: const LibraryFilterChips(),
                  ),
                ),

                // 3. Sort Row (Mock)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.white, size: 18.r),
                        SizedBox(width: 8.w),
                        Text(
                          'Recents',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.grid_view, color: Colors.white, size: 18.r),
                      ],
                    ),
                  ),
                ),

                // 4. Library List
                SliverList(
                  delegate: SliverChildListDelegate([
                    const LibraryListTile(
                      title: 'Liked Songs',
                      subtitle: 'Playlist • 430 songs',
                      imageUrl:
                          'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=150&q=80',
                      isPinned: true,
                    ),
                    const LibraryListTile(
                      title: 'My Top 2023',
                      subtitle: 'Playlist • Spotify',
                      imageUrl:
                          'https://images.unsplash.com/photo-1514525253440-b393452e8d26?auto=format&fit=crop&w=150&q=80',
                      isPinned: true,
                    ),
                    const LibraryListTile(
                      title: 'The Weeknd',
                      subtitle: 'Artist',
                      imageUrl:
                          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=150&q=80',
                    ),
                    const LibraryListTile(
                      title: 'Rock Classics',
                      subtitle: 'Playlist • Sonus',
                      imageUrl:
                          'https://images.unsplash.com/photo-1550291652-6ea9114a47b1?auto=format&fit=crop&w=150&q=80',
                    ),
                    const LibraryListTile(
                      title: 'Chill Lofi Study',
                      subtitle: 'Playlist • Lofi Girl',
                      imageUrl:
                          'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=150&q=80',
                    ),
                    const LibraryListTile(
                      title: 'Imagine Dragons',
                      subtitle: 'Artist',
                      imageUrl:
                          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?auto=format&fit=crop&w=150&q=80',
                    ),
                    const LibraryListTile(
                      title: 'Dua Lipa',
                      subtitle: 'Artist',
                      imageUrl:
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
                    ),
                    // Extra space
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
