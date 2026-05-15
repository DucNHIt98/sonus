import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/backend_service.dart';

final recentlyPlayedProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final backend = ref.read(backendServiceProvider);
  return backend.getPlayHistory(limit: 50);
});

class RecentlyPlayedPage extends ConsumerWidget {
  const RecentlyPlayedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentlyPlayedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Recently Played', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
          child: historyAsync.when(
            data: (history) {
              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: Colors.white24, size: 64.r),
                      SizedBox(height: 16.h),
                      Text('No listening history yet', style: TextStyle(color: Colors.white54, fontSize: 16.sp)),
                      SizedBox(height: 8.h),
                      Text('Play some songs to see them here', style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final song = item['song'] as Map<String, dynamic>? ?? {};
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () => context.push('/player'),
                    leading: Container(
                      width: 50.w,
                      height: 50.h,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Colors.grey[800],
                        image: (song['image_url'] as String? ?? '').isNotEmpty
                          ? DecorationImage(image: NetworkImage(song['image_url']), fit: BoxFit.cover)
                          : null,
                      ),
                      child: (song['image_url'] as String? ?? '').isEmpty
                          ? Icon(Icons.music_note, color: Colors.white54, size: 24.r)
                          : null,
                    ),
                    title: Text(song['title'] ?? '', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${song['subtitle'] ?? ''}  •  ${item['count'] ?? 0} plays', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.red)),
            error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
          ),
        ),
      ),
    );
  }
}
