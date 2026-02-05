import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/features/player/presentation/widgets/player_controls.dart';
import 'package:sonus/features/player/presentation/widgets/player_progress_bar.dart';

class PlayerPage extends ConsumerWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for errors to show SnackBar
    ref.listen<AsyncValue<Home?>>(playerControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    });

    final playerState = ref.watch(playerControllerProvider);
    print("DEBUG: PlayerPage received state: $playerState");

    // Reusable fallback UI for "No song" or "Hard Error" state
    Widget buildFallbackUI() {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('No song playing', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // Check if we have data (metadata) even if there's an error
    final currentSong = playerState.valueOrNull;

    if (currentSong != null) {
      return _buildPlayerScaffold(context, currentSong);
    }

    return playerState.when(
      data: (song) => buildFallbackUI(), // song is null here (checked above)
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
      error: (error, stack) => buildFallbackUI(),
    );
  }

  Widget _buildPlayerScaffold(BuildContext context, Home currentSong) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF400503).withOpacity(0.8), Colors.black],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;

              // Dynamic sizing: Art is ~45% of screen height, but capped for smaller screens
              final albumArtSize = (screenHeight * 0.45).clamp(200.0, 400.0);

              return Column(
                children: [
                  // 1. Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Column(
                          children: [
                            Text(
                              'PLAYING FROM PLAYLIST',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10.sp,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Favorites',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 2. Artwork
                  SizedBox(
                    width: albumArtSize,
                    height: albumArtSize,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.network(
                          currentSong.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[850],
                            child: Icon(
                              Icons.music_note,
                              size: 80.r,
                              color: Colors.white24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // 3. Title & Artist
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                currentSong.subtitle,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 4. Progress Bar
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: PlayerProgressBar(),
                  ),

                  SizedBox(height: 10.h),

                  // 5. Controls
                  const PlayerControls(),

                  const Spacer(), // More space at bottom
                  // 6. Footer Devices
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 20.h,
                      left: 24.w,
                      right: 24.w,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.devices,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const Icon(
                          Icons.share,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
