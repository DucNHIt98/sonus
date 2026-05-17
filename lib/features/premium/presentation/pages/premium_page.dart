import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sonus/features/premium/presentation/providers/premium_provider.dart';

class PremiumPage extends ConsumerWidget {
  const PremiumPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(premiumControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Premium',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: statusAsync.when(
        data: (status) {
          if (status.isPremium) {
            return _buildPremiumActiveView(context, ref, status);
          }
          return _buildSubscribeView(context, ref);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (err, _) => _buildSubscribeView(context, ref),
      ),
    );
  }

  Widget _buildPremiumActiveView(BuildContext context, WidgetRef ref, status) {
    final untilStr = status.premiumUntil != null
        ? '${status.premiumUntil!.day}/${status.premiumUntil!.month}/${status.premiumUntil!.year}'
        : 'N/A';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, color: Colors.amber, size: 80.r),
          SizedBox(height: 24.h),
          Text(
            'You are Premium!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Premium until $untilStr',
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          ),
          if (status.cancelAtPeriodEnd) ...[
            SizedBox(height: 8.h),
            Text(
              'Your subscription will cancel at the end of the billing period.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange, fontSize: 13.sp),
            ),
          ],
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: status.cancelAtPeriodEnd
                  ? null
                  : () => _confirmCancel(context, ref),
              icon: Icon(Icons.cancel_outlined, size: 18.r),
              label: Text(
                status.cancelAtPeriodEnd
                    ? 'Cancelling...'
                    : 'Cancel Subscription',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribeView(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),
            Icon(Icons.stars, color: Colors.amber, size: 64.r),
            SizedBox(height: 16.h),
            Text(
              'Upgrade to Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unlock all features for the best experience',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
            ),
            SizedBox(height: 32.h),
            _buildFeatureItem(
              Icons.download,
              'Offline Downloads',
              'Download up to 20 songs or go unlimited',
            ),
            _buildFeatureItem(
              Icons.favorite,
              'Unlimited Favorites',
              'Save all your favorite songs',
            ),
            _buildFeatureItem(
              Icons.playlist_add,
              'Unlimited Playlists',
              'Create as many playlists as you want',
            ),
            _buildFeatureItem(
              Icons.history,
              'Full Listening History',
              'Go beyond the last 7 days',
            ),
            _buildFeatureItem(
              Icons.search,
              'More Search Results',
              'See all results, not just the first 10',
            ),
            _buildFeatureItem(
              Icons.explore,
              'Full Home Feed',
              'Charts, trending, and AI recommendations',
            ),
            SizedBox(height: 40.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade800, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  Text(
                    'Premium Monthly',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '\$9.99 / month',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Cancel anytime',
                    style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startCheckout(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Subscribe Now',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Payment is processed securely via Stripe.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.red, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startCheckout(BuildContext context, WidgetRef ref) async {
    const successUrl = 'sonus://premium/success';
    const cancelUrl = 'sonus://premium/cancel';

    final url = await ref
        .read(premiumControllerProvider.notifier)
        .createCheckout(successUrl: successUrl, cancelUrl: cancelUrl);

    if (url == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment is not available yet. Please configure Stripe keys.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Stripe checkout.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Cancel Subscription',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Your premium features will remain active until the end of the billing period.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep Premium', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(premiumControllerProvider.notifier)
          .cancel();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Subscription cancelled' : 'Failed to cancel',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
