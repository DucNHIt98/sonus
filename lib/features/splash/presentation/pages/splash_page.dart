import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/splash/presentation/providers/splash_provider.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to trigger side effects or rebuild
    final splashState = ref.watch(splashControllerProvider);

    // Listen to state changes for navigation
    ref.listen(splashControllerProvider, (previous, next) {
      if (next is AsyncData) {
        // Initialization complete, navigate to Auth or Home
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.go('/sign-in');
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFB91C1C),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Spotify-like deep gradient
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/logo/logo_sonus_red_background.svg',
                  height: 80.h,
                  // color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  'SONUS',
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'ARS SONORUM',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 2,
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
                // Show error if failed
                if (splashState is AsyncError) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'Error: ${splashState.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
