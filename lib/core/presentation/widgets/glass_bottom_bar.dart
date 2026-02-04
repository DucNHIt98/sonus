import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GlassBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 70.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1), // Glass tint
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2), // Subtle border
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_filled, Icons.home_outlined, 0),
                _buildNavItem(Icons.search, Icons.search_outlined, 1),
                _buildNavItem(
                  Icons.library_music,
                  Icons.library_music_outlined,
                  2,
                ),
                _buildNavItem(Icons.add_circle, Icons.add_circle_outline, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData selectedIcon,
    IconData unselectedIcon,
    int index,
  ) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.all(12.r),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? selectedIcon : unselectedIcon,
            key: ValueKey(isSelected),
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            size: 28.r,
          ),
        ),
      ),
    );
  }
}
