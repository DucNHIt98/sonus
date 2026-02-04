import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

class HomeShortcutCard extends StatelessWidget {
  final Home item;
  const HomeShortcutCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  bottomLeft: Radius.circular(4.r),
                ),
                image: item.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imageUrl.isEmpty
                  ? Icon(Icons.music_note, color: Colors.white54, size: 24.r)
                  : null,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                item.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  final String title;
  const HomeSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HomeHorizontalCard extends StatelessWidget {
  final Home item;
  const HomeHorizontalCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(left: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8.r),
                image: item.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.imageUrl.isEmpty
                  ? Icon(Icons.music_note, size: 50.r, color: Colors.white54)
                  : null,
            ),
            SizedBox(height: 12.h),
            Text(
              item.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            if (item.subtitle.isNotEmpty)
              Text(
                item.subtitle,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
