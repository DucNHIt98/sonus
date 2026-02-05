import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final song = playerState.currentSong;

    if (song == null) return const SizedBox.shrink();

    final playerController = ref.watch(playerControllerProvider.notifier);
    final player = playerController.audioPlayer;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: 60.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(0xFF400503).withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              // Album Art
              Container(
                width: 44.w,
                height: 44.h,
                margin: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6.r),
                  image: DecorationImage(
                    image: NetworkImage(song.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 4.w),

              // Title & Artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      song.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Controls
              StreamBuilder<bool>(
                stream: player.playingStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30.r,
                    ),
                    onPressed: () => playerController.togglePlay(),
                  );
                },
              ),
              SizedBox(width: 8.w),
            ],
          ),
        ),
      ),
    );
  }
}
