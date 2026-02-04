import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/player/presentation/widgets/player_controls.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Dynamic gradient based on album art (Mocked here as Red/Black)
            colors: [Color(0xFF7f0000), Colors.black],
            stops: [0.0, 0.8],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final screenHeight = constraints.maxHeight;
              final screenWidth = constraints.maxWidth;

              // Scale album art based on available height (clamp for safety)
              // We use .r for the clamp thresholds to ensure they scale with screen size.
              final albumArtSize = (screenHeight * 0.45).clamp(
                200.r,
                screenWidth - 48.w,
              );

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 32.r,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          'NOW PLAYING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
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

                  // Album Art (Responsive)
                  Container(
                    width: albumArtSize,
                    height: albumArtSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40.r,
                          spreadRadius: 10.r,
                          offset: Offset(0, 20.h),
                        ),
                      ],
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=600&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Song Info
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'On Repeat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Songs you love',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 18.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                            size: 28.r,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Controls
                  const PlayerControls(),

                  const Spacer(flex: 2),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
