import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 50.h),
                SvgPicture.asset(
                  'assets/logo/logo_sonus_no_background_red_text.svg',
                  height: 120.h,
                ),
                Text(
                  "Let's get you in",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32.h),
                _SocialButton(
                  asset: 'assets/icons/google.svg',
                  label: 'Continue with Google',
                  onTap: () {},
                ),
                SizedBox(height: 16.h),
                _SocialButton(
                  asset: 'assets/icons/facebook.svg',
                  label: 'Continue with Facebook',
                  onTap: () {},
                ),
                SizedBox(height: 16.h),
                _SocialButton(
                  asset: 'assets/icons/apple.svg',
                  label: 'Continue with Apple',
                  onTap: () {},
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'or',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB91C1C),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 56.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    elevation: 8,
                    shadowColor: const Color(0xFFB91C1C).withOpacity(0.5),
                  ),
                  child: Text(
                    'Log in with a password',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: const Color(0xFFB91C1C),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.asset,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 12.w),
              SvgPicture.asset(
                asset,
                height: 24.r,
                width: 24.r,
                colorFilter: asset.contains('apple')
                    ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                    : null,
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
