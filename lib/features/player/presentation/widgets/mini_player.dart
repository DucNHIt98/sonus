import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: 60.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: const Color(
              0xFF400503,
            ).withOpacity(0.8), // Deep Red tint compatible with theme
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
                width: 48.w,
                height: 48.h,
                margin: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=150&q=80',
                    ), // Mock Image
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: 8.w),

              // Title & Artist
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'On Repeat',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Songs you love',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Controls
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 24.r,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32.r,
                ),
                onPressed: () {},
              ),
              SizedBox(width: 8.w),
            ],
          ),
        ),
      ),
    );
  }
}
