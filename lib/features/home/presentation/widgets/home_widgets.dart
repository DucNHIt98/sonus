import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/presentation/widgets/cached_artwork.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/presentation/providers/home_provider.dart';
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
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          children: [
            // Image placeholder
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.r),
                bottomLeft: Radius.circular(4.r),
              ),
              child: CachedArtwork(
                imageUrl: item.imageUrl,
                width: 56.w,
                height: 56.h,
                fallback: Container(
                  width: 56.w,
                  height: 56.h,
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white54,
                    size: 24.r,
                  ),
                ),
              ),
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

class HomeHorizontalCard extends ConsumerWidget {
  final Home item;
  final List<Home> contextQueue;

  const HomeHorizontalCard({
    super.key,
    required this.item,
    this.contextQueue = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref
            .read(playerControllerProvider.notifier)
            .playSong(
              item,
              contextQueue: contextQueue.isEmpty ? null : contextQueue,
            );
        context.push('/player');
      },
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(left: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedArtwork(
                imageUrl: item.imageUrl,
                width: 140.w,
                height: 140.h,
                fallback: Container(
                  width: 140.w,
                  height: 140.h,
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.music_note,
                    size: 50.r,
                    color: Colors.white54,
                  ),
                ),
              ),
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
    final homeDataAsync = ref.watch(homeControllerProvider);

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
          color: const Color(0xFF301934), // Fallback base color
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            children: [
              // Background Thumbnail
              homeDataAsync.when(
                data: (data) {
                  // Try to find an image from any section (Recently Played, Discovery, etc.)
                  String? imageUrl;
                  for (final list in data.values) {
                    final itemWithImage = list.firstWhere(
                      (item) => item.imageUrl.isNotEmpty,
                      orElse: () =>
                          Home(id: '', title: '', imageUrl: '', source: ''),
                    );
                    if (itemWithImage.imageUrl.isNotEmpty) {
                      imageUrl = itemWithImage.imageUrl;
                      break;
                    }
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl != null)
                        CachedArtwork(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          fallback: _buildDefaultGradient(),
                        )
                      else
                        _buildDefaultGradient(),

                      // Dark Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF301934).withValues(alpha: 0.8),
                              const Color(0xFF7B1FA2).withValues(alpha: 0.6),
                              const Color(0xFFFFD700).withValues(alpha: 0.4),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => _buildDefaultGradient(),
                error: (_, __) => _buildDefaultGradient(),
              ),

              // Decorative circles
              Positioned(
                right: -20.w,
                top: -20.h,
                child: CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
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
                            color: Colors.black.withValues(alpha: 0.2),
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
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Giai điệu dành riêng cho bạn',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
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
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 40.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF301934), // Deep Purple
            Color(0xFF7B1FA2), // Medium Purple
            Color(0xFFFFD700), // Gold
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}
