import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerControllerProvider);
    final playerController = ref.watch(playerControllerProvider.notifier);
    final player = playerController.audioPlayer;

    return StreamBuilder<PlayerStateJustAudio>(
      stream: player.playerStateStream.map(
        (state) => PlayerStateJustAudio(state.playing, state.processingState),
      ),
      builder: (context, snapshot) {
        final processingState = snapshot.data?.processingState;
        final playing = snapshot.data?.playing;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                size: 28.r,
                color: playerState.isShuffleModeEnabled
                    ? const Color(0xFF1DB954)
                    : Colors.white,
              ),
              onPressed: () => playerController.toggleShuffle(),
            ),
            IconButton(
              icon: Icon(Icons.skip_previous_rounded, size: 36.r),
              color: Colors.white,
              onPressed: () => playerController.skipPrevious(),
            ),

            // Play/Pause Button
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshotPos) {
                final position = snapshotPos.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: player.bufferedPositionStream,
                  builder: (context, snapshotBuf) {
                    final buffered = snapshotBuf.data ?? Duration.zero;
                    final duration = player.duration ?? Duration.zero;

                    // Custom buffering check:
                    // If playing, and buffer is less than 500ms ahead, and not near end of song.
                    final isBufferingLow =
                        (playing ?? false) &&
                        (buffered - position).inMilliseconds < 500 &&
                        (duration - position).inSeconds > 1;

                    final showLoading =
                        playerState.isLoading ||
                        processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering ||
                        isBufferingLow;

                    return GestureDetector(
                      onTap: () => playerController.togglePlay(),
                      child: Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: showLoading
                            ? const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.black,
                                ),
                              )
                            : Icon(
                                (playing ?? false)
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 40.r,
                                color: Colors.black,
                              ),
                      ),
                    );
                  },
                );
              },
            ),

            IconButton(
              icon: Icon(Icons.skip_next_rounded, size: 36.r),
              color: Colors.white,
              onPressed: () => playerController.skipNext(),
            ),
            IconButton(
              icon: Icon(
                playerState.repeatMode == LoopMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
                size: 28.r,
                color: playerState.repeatMode != LoopMode.off
                    ? const Color(0xFF1DB954)
                    : Colors.white,
              ),
              onPressed: () => playerController.cycleRepeatMode(),
            ),
          ],
        );
      },
    );
  }
}

/// Helper class to avoid name conflict with just_audio's PlayerState
class PlayerStateJustAudio {
  final bool playing;
  final ProcessingState processingState;

  PlayerStateJustAudio(this.playing, this.processingState);
}
