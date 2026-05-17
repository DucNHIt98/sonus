import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/login/presentation/providers/login_provider.dart';
import 'package:sonus/features/premium/presentation/providers/premium_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _clearHistory(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Clear History', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete all listening history permanently?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final backend = ref.read(backendServiceProvider);
    final ok = await backend.clearAllHistory();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'History cleared' : 'Failed to clear'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

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
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              SizedBox(height: 16.h),
              _buildSectionHeader('Account'),
              _buildSettingTile(
                context,
                Icons.person,
                'Profile',
                subtitle: 'Edit your profile',
                onTap: () => context.push('/profile'),
              ),
              _buildSettingTile(
                context,
                Icons.stars,
                'Premium',
                subtitle: premiumAsync.when(
                  data: (s) => s.isPremium ? 'Active' : 'Upgrade to Premium',
                  loading: () => 'Loading...',
                  error: (_, __) => 'Upgrade to Premium',
                ),
                onTap: () => context.push('/premium'),
              ),
              Divider(color: Colors.white12, height: 32.h),

              _buildSectionHeader('Library'),
              _buildSettingTile(
                context,
                Icons.favorite,
                'Favorites',
                subtitle: 'View your liked songs',
                onTap: () => context.push('/favorites'),
              ),
              _buildSettingTile(
                context,
                Icons.history,
                'Recently Played',
                subtitle: 'Your listening history',
                onTap: () => context.push('/recently-played'),
              ),
              _buildSettingTile(
                context,
                Icons.delete_sweep,
                'Clear Listening History',
                onTap: () => _clearHistory(context, ref),
              ),
              Divider(color: Colors.white12, height: 32.h),

              _buildSectionHeader('Preferences'),
              _buildSettingTile(
                context,
                Icons.language,
                'Language',
                subtitle: 'English',
                enabled: false,
              ),
              _buildSettingTile(
                context,
                Icons.volume_up,
                'Audio Quality',
                subtitle: 'Standard',
                enabled: false,
              ),
              _buildSettingTile(
                context,
                Icons.equalizer,
                'Equalizer',
                enabled: false,
              ),
              Divider(color: Colors.white12, height: 32.h),

              _buildSectionHeader('About'),
              _buildSettingTile(
                context,
                Icons.info_outline,
                'Version',
                subtitle: '1.0.0',
              ),
              SizedBox(height: 24.h),

              Center(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(loginControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/sign-in');
                  },
                  icon: Icon(Icons.logout, color: Colors.red, size: 18.r),
                  label: Text(
                    'Log Out',
                    style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.r),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.white38,
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
            )
          : null,
      trailing: enabled
          ? Icon(Icons.chevron_right, color: Colors.white24, size: 20.r)
          : null,
      onTap: enabled ? onTap : null,
    );
  }
}
