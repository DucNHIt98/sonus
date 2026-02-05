import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class PlayerControls extends ConsumerWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerController = ref.watch(playerControllerProvider.notifier);

    // We need to access the underlying AudioPlayer.
    // Since the controller exposes it, we can use a StreamBuilder.
    return StreamBuilder<PlayerState>(
      stream: playerController.audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.shuffle, size: 28.r),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.skip_previous_rounded, size: 36.r),
              color: Colors.white,
              onPressed: () {}, // TODO: Implement prev
            ),

            // Play/Pause Button
            GestureDetector(
              onTap: playerController.togglePlay,
              child: Container(
                width: 72.w,
                height: 72.h,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child:
                    processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering
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
            ),

            IconButton(
              icon: Icon(Icons.skip_next_rounded, size: 36.r),
              color: Colors.white,
              onPressed: () {}, // TODO: Implement next
            ),
            IconButton(
              icon: Icon(Icons.repeat, size: 28.r),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}
