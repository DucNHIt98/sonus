import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/presentation/widgets/glass_bottom_bar.dart';

import 'package:sonus/features/player/presentation/widgets/mini_player.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  const ScaffoldWithNavbar({required this.navigationShell, super.key});

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Default background
      body: Stack(
        children: [
          // The page body
          navigationShell,

          // Mini Player (Floating above Bottom Bar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 110.h, // Pushed up above the glass bottom bar
            child: GestureDetector(
              onTap: () => context.push('/player'),
              child: const MiniPlayer(),
            ),
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassBottomBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => _onTap(context, index),
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when switching branches, like in Instagram.
      // If the user taps the item that is already selected, switch to the first
      // location on the branch, initially the start page.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
