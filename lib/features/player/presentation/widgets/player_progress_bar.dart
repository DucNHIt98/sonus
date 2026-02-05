import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class PlayerProgressBar extends ConsumerWidget {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final playerController = ref.watch(playerControllerProvider.notifier);
    final player = playerController.audioPlayer;

    final song = playerState.currentSong;

    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, snapshot) {
        // Priority: 1. Metadata from YouTube API, 2. Duration from Player Stream, 3. Zero
        final duration = song?.duration ?? snapshot.data ?? Duration.zero;

        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, snapshot) {
            var position = snapshot.data ?? Duration.zero;
            // Cap position to duration to avoid overflow if player duration is shorter
            if (duration != Duration.zero && position > duration) {
              position = duration;
            }

            return StreamBuilder<Duration>(
              stream: player.bufferedPositionStream,
              builder: (context, snapshot) {
                final bufferedPosition = snapshot.data ?? Duration.zero;

                return ProgressBar(
                  progress: position,
                  buffered: bufferedPosition,
                  total: duration,
                  progressBarColor: Colors.white,
                  baseBarColor: Colors.white.withOpacity(0.24),
                  bufferedBarColor: Colors.white.withOpacity(0.24),
                  thumbColor: Colors.white,
                  barHeight: 2.h,
                  thumbRadius: 6.r,
                  timeLabelTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  onSeek: (duration) {
                    player.seek(duration);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

// Since Stream.combineWith is not standard dart:async, and writing a Combiner is verbose,
// Nested StreamBuilders is the standard Flutter way without RxDart.
