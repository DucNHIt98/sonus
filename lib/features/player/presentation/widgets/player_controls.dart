import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 14.r),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.2),
          ),
          child: Slider(value: 0.3, onChanged: (value) {}),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1:24',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12.sp,
                ),
              ),
              Text(
                '3:52',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Buttons
        Row(
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
              onPressed: () {},
            ),
            Container(
              width: 72.w,
              height: 72.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pause_rounded, size: 40.r, color: Colors.black),
            ),
            IconButton(
              icon: Icon(Icons.skip_next_rounded, size: 36.r),
              color: Colors.white,
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.repeat, size: 28.r),
              color: Colors.white,
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}
