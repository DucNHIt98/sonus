import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/downloads/presentation/providers/download_provider.dart';
import 'package:sonus/features/downloads/presentation/widgets/download_widgets.dart';

class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadsAsync = ref.watch(downloadControllerProvider);
    final quotaAsync = ref.watch(downloadQuotaControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Downloads',
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
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 20.r),
            onPressed: () => ref.read(downloadControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildQuotaBanner(context, ref, quotaAsync),
          Expanded(
            child: downloadsAsync.when(
              data: (downloads) {
                if (downloads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_outlined, color: Colors.grey[600], size: 64.r),
                        SizedBox(height: 16.h),
                        Text(
                          'No downloads yet',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Download songs to listen offline',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: downloads.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[800], height: 1.h),
                  itemBuilder: (context, index) {
                    final d = downloads[index];
                    return DownloadedSongTile(
                      song: d.song,
                      downloadedAt: _formatDate(d.downloadedAt),
                      onTap: () {
                        context.push('/player', extra: d.song);
                      },
                      onRemove: () => _confirmRemove(context, ref, d.song.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
              error: (err, _) => Center(
                child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotaBanner(BuildContext context, WidgetRef ref, AsyncValue<Map<String, dynamic>> quotaAsync) {
    return quotaAsync.when(
      data: (quota) {
        final isPremium = quota['is_premium'] as bool? ?? false;
        final used = quota['downloads_used'] as int? ?? 0;
        final limit = quota['downloads_limit'] as int?;

        if (isPremium) {
          return Container(
            margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade700, Colors.amber.shade500],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.white, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  'Premium — Unlimited downloads',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }

        final remaining = limit != null ? limit - used : 0;
        return Container(
          margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_download_outlined, color: Colors.white54, size: 20.r),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '$used / $limit downloads used',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                ),
              ),
              if (remaining <= 5 && remaining > 0)
                Text(
                  '$remaining left',
                  style: TextStyle(color: Colors.orange, fontSize: 12.sp, fontWeight: FontWeight.w600),
                ),
              if (remaining <= 0)
                GestureDetector(
                  onTap: () => context.push('/premium'),
                  child: Text(
                    'Upgrade',
                    style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref, String songId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Remove download', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will remove the download. You can download it again later.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(downloadControllerProvider.notifier).removeDownload(songId);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
