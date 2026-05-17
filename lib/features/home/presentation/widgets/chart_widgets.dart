import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/presentation/widgets/cached_artwork.dart';
import 'package:sonus/features/home/presentation/providers/chart_provider.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:go_router/go_router.dart';

class ChartSection extends ConsumerWidget {
  final String title;
  final String region;
  final String? playlistId;

  const ChartSection({
    super.key,
    required this.title,
    required this.region,
    this.playlistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartAsync = ref.watch(
      chartControllerProvider(region, playlistId: playlistId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/premium'),
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 220.h,
          child: chartAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const Center(
                  child: Text(
                    'No tracks found',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return ChartItemCard(
                    song: songs[index],
                    rank: songs[index].rank ?? (index + 1),
                    contextQueue: songs,
                  );
                },
              );
            },
            loading: () => const ChartShimmer(),
            error: (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}

class ChartItemCard extends ConsumerWidget {
  final MusicModel song;
  final int rank;
  final List<MusicModel> contextQueue;

  const ChartItemCard({
    super.key,
    required this.song,
    required this.rank,
    required this.contextQueue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Direct playback via YouTube direct streaming
        // PlayerController handles fetching stream URL if audioUrl is empty
        ref
            .read(playerControllerProvider.notifier)
            .playMusicModel(song, contextQueue: contextQueue);
        context.pushNamed('player');
      },
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Stack(
                    children: [
                      CachedArtwork(
                        imageUrl: song.albumArt,
                        width: 140.w,
                        height: 140.w,
                        fallback: Container(
                          width: 140.w,
                          height: 140.w,
                          color: Colors.grey[900],
                          child: Icon(
                            Icons.music_note,
                            color: Colors.white24,
                            size: 40.r,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8.r,
                        bottom: 8.r,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8.r,
                  left: 8.r,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              song.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              song.artist,
              style: TextStyle(color: Colors.white54, fontSize: 12.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartShimmer extends StatelessWidget {
  const ChartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 140.w,
          margin: EdgeInsets.only(right: 16.w),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[900]!,
            highlightColor: Colors.grey[800]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(width: 100.w, height: 14.h, color: Colors.black),
                SizedBox(height: 4.h),
                Container(width: 60.w, height: 12.h, color: Colors.black),
              ],
            ),
          ),
        );
      },
    );
  }
}
