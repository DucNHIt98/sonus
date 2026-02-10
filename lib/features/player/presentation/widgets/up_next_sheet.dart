import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class UpNextSheet extends ConsumerWidget {
  const UpNextSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UpNextSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final playerController = ref.watch(playerControllerProvider.notifier);
    final queue = playerState.queue;
    final currentIndex = playerState.currentIndex;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 12.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiếp theo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // Queue count
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${queue.length} bài hát trong hàng chờ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Content (Queue + AI Recommendations)
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      children: [
                        // Queue section
                        if (queue.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.h),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.queue_music,
                                  size: 60.r,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Hàng chờ trống',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...queue.asMap().entries.map((entry) {
                            final index = entry.key;
                            final song = entry.value;
                            final isCurrentlyPlaying = index == currentIndex;

                            return Dismissible(
                              key: Key('queue_${song.id}_$index'),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) {
                                playerController.removeFromQueue(index);
                              },
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(right: 20.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 28.r,
                                ),
                              ),
                              child: _buildSongTile(
                                context,
                                song,
                                index: index,
                                isCurrentlyPlaying: isCurrentlyPlaying,
                                onTap: () async {
                                  await playerController.seekToIndex(index);
                                  // playerController.audioPlayer.play(); // seekToIndex handles playing if jumping, but if seeking locally we might need to ensure play?
                                  // our seekToIndex implementation for "unloaded" calls play.
                                  // for "loaded" it just seeks.
                                  // best to ensure play here or in controller.
                                  playerController.audioPlayer.play();
                                },
                              ),
                            );
                          }),

                        // AI Recommendations section
                        if (playerState.aiRecommendations.isNotEmpty) ...[
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.purple.shade300,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Gợi ý từ AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Dựa trên bài ${playerState.currentSong?.title ?? "hiện tại"}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          ...playerState.aiRecommendations.asMap().entries.map((
                            entry,
                          ) {
                            final song = entry.value;
                            return _buildSongTile(
                              context,
                              song,
                              showAddButton: true,
                              onTap: () {
                                // Play this AI recommended song
                                playerController.playSelectedSongWithMetadata(
                                  song,
                                );
                                Navigator.pop(context);
                              },
                              onAdd: () {
                                playerController.addToQueue(song);
                              },
                            );
                          }),
                        ],

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildSongTile(
    BuildContext context,
    dynamic song, {
    int? index,
    bool isCurrentlyPlaying = false,
    bool showAddButton = false,
    VoidCallback? onTap,
    VoidCallback? onAdd,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isCurrentlyPlaying
              ? const Color(0xFF400503).withOpacity(0.6)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: isCurrentlyPlaying
              ? Border.all(
                  color: const Color(0xFFFF4444).withOpacity(0.5),
                  width: 1,
                )
              : null,
        ),
        child: Row(
          children: [
            // Index or playing indicator
            if (index != null)
              SizedBox(
                width: 30.w,
                child: Center(
                  child: isCurrentlyPlaying
                      ? Icon(
                          Icons.equalizer,
                          color: const Color(0xFFFF4444),
                          size: 22.r,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14.sp,
                          ),
                        ),
                ),
              ),

            if (index != null) SizedBox(width: 8.w),

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                song.imageUrl,
                width: 48.w,
                height: 48.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48.w,
                  height: 48.h,
                  color: Colors.grey[800],
                  child: Icon(
                    Icons.music_note,
                    color: Colors.white38,
                    size: 24.r,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Title & Artist
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: isCurrentlyPlaying
                          ? const Color(0xFFFF4444)
                          : Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    song.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Duration or Add button
            if (showAddButton && onAdd != null)
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white.withOpacity(0.7),
                  size: 24.r,
                ),
                onPressed: onAdd,
                tooltip: 'Thêm vào hàng chờ',
              )
            else if (song.duration != null)
              Text(
                _formatDuration(song.duration!),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12.sp,
                ),
              ),

            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }
}
