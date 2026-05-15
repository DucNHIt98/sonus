import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/login/presentation/providers/login_provider.dart';
import 'package:sonus/features/premium/presentation/providers/premium_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Settings', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingTile(context, Icons.person, 'Profile', subtitle: 'Edit your profile', onTap: () => context.push('/profile')),
          _buildSettingTile(context, Icons.stars, 'Premium', subtitle: premiumAsync.when(
            data: (s) => s.isPremium ? 'Active' : 'Upgrade to Premium',
            loading: () => 'Loading...',
            error: (_, __) => 'Upgrade to Premium',
          ), onTap: () => context.push('/premium')),
          Divider(color: Colors.white12, height: 32.h),

          _buildSectionHeader('Preferences'),
          _buildSettingTile(context, Icons.favorite, 'Favorites', subtitle: 'View your liked songs', onTap: () => context.push('/favorites')),
          _buildSettingTile(context, Icons.history, 'Recently Played', subtitle: 'Your listening history', onTap: () => context.push('/recently-played')),
          _buildSettingTile(context, Icons.language, 'Language', subtitle: 'English', enabled: false),
          Divider(color: Colors.white12, height: 32.h),

          _buildSectionHeader('Audio'),
          _buildSettingTile(context, Icons.volume_up, 'Audio Quality', subtitle: 'Standard', enabled: false),
          _buildSettingTile(context, Icons.equalizer, 'Equalizer', enabled: false),
          Divider(color: Colors.white12, height: 32.h),

          _buildSectionHeader('About'),
          _buildSettingTile(context, Icons.info_outline, 'Version', subtitle: '1.0.0'),
          SizedBox(height: 24.h),

          Center(
            child: TextButton.icon(
              onPressed: () async {
                await ref.read(loginControllerProvider.notifier).logout();
                if (context.mounted) context.go('/sign-in');
              },
              icon: Icon(Icons.logout, color: Colors.red, size: 18.r),
              label: Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
      child: Text(title, style: TextStyle(color: Colors.grey[400], fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1)),
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title, {String? subtitle, bool enabled = true, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70, size: 22.r),
      title: Text(title, style: TextStyle(color: enabled ? Colors.white : Colors.white38, fontSize: 15.sp)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 13.sp)) : null,
      trailing: enabled ? Icon(Icons.chevron_right, color: Colors.white38, size: 20.r) : null,
      onTap: enabled ? onTap : null,
    );
  }
}
