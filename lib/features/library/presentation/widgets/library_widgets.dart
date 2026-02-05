import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LibraryHeader extends StatelessWidget {
  const LibraryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.pinkAccent,
          child: Text(
            'D',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          'Your Library',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.search, color: Colors.white, size: 28.r),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.add, color: Colors.white, size: 28.r),
          onPressed: () {},
        ),
      ],
    );
  }
}

class LibraryFilterChips extends StatelessWidget {
  const LibraryFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('Playlists'),
          _buildChip('Artists'),
          _buildChip('Albums'),
          _buildChip('Podcasts & Shows'),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class LibraryListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isPinned;

  const LibraryListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isPinned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              color: Colors.grey[800],
            ),
            child: imageUrl.isEmpty
                ? Icon(Icons.music_note, color: Colors.white54, size: 30.r)
                : null,
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
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (isPinned) ...[
                      Transform.rotate(
                        angle: 0.7,
                        child: Icon(
                          Icons.push_pin,
                          color: Colors.green[400],
                          size: 14.r,
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
