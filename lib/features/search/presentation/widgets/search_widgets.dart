import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white.withOpacity(0.6), size: 24.r),
          SizedBox(width: 12.w),
          Text(
            'Search song, playlist, artist...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryTabs extends StatefulWidget {
  const CategoryTabs({super.key});

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int _selectedIndex = 0;
  final List<String> _categories = [
    'Recent',
    'Top 50',
    'Chill',
    'R&B',
    'Festival',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      fontSize: 16.sp,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      height: 3.h,
                      width: 20.w,
                      decoration: BoxDecoration(
                        color: Colors.purpleAccent,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final Color dummyColor;

  const FeaturedCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.dummyColor = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        width: 260.w,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          image: imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: imageUrl.isEmpty ? dummyColor : null,
        ),
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 16.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final String duration;
  final String imageUrl;

  const SongTile({
    super.key,
    required this.title,
    required this.artist,
    required this.duration,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/player'),
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[800],
              ),
              child: imageUrl.isEmpty
                  ? Icon(Icons.music_note, color: Colors.white, size: 30.r)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    artist,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              duration,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
