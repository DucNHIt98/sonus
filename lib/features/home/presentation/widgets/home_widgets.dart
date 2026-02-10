import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class HomeShortcutCard extends ConsumerWidget {
  final Home item;
  const HomeShortcutCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(playerControllerProvider.notifier).playSong(item);
        context.push('/player');
      },
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

class SupermixCard extends ConsumerWidget {
  const SupermixCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(playerControllerProvider.notifier).generateMySupermix();
        context.push('/player');
      },
      child: Container(
        width: double.infinity,
        height: 180.h,
        margin: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF301934), // Deep Purple
              Color(0xFF7B1FA2), // Medium Purple
              Color(0xFFFFD700), // Gold
            ],
            stops: [0.0, 0.4, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20.w,
              top: -20.h,
              child: CircleAvatar(
                radius: 60.r,
                backgroundColor: Colors.white.withOpacity(0.1),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: const Color(0xFF301934),
                      size: 32.r,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'My Supermix',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Giai điệu dành riêng cho bạn',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom abstract shape
            Positioned(
              right: 24.w,
              bottom: 24.h,
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.5),
                size: 40.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
