import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/premium/presentation/providers/premium_provider.dart';

class RecentlyPlayedPage extends ConsumerStatefulWidget {
  const RecentlyPlayedPage({super.key});

  @override
  ConsumerState<RecentlyPlayedPage> createState() => _RecentlyPlayedPageState();
}

class _RecentlyPlayedPageState extends ConsumerState<RecentlyPlayedPage> {
  final List<Map<String, dynamic>> _entries = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _total = 0;
  int _offset = 0;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    final backend = ref.read(backendServiceProvider);
    final result = await backend.getPlayHistory(offset: _offset, limit: _pageSize,
      returnTotal: true,
    );
    final batch = result['entries'] as List<Map<String, dynamic>>;
    final totalFromApi = result['total'] as int;
    if (batch.length < _pageSize) _hasMore = false;
    if (totalFromApi > 0) _total = totalFromApi;
    setState(() {
      _entries.addAll(batch);
      _offset += batch.length;
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry(String songId) async {
    final backend = ref.read(backendServiceProvider);
    final ok = await backend.deleteHistoryEntry(songId);
    if (ok && mounted) {
      setState(() => _entries.removeWhere(
        (e) => (e['song'] as Map?)?['id'] == songId,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from history'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Clear History', style: TextStyle(color: Colors.white)),
        content: Text('Delete all listening history?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Clear', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    final backend = ref.read(backendServiceProvider);
    final ok = await backend.clearAllHistory();
    if (ok && mounted) {
      setState(() { _entries.clear(); _offset = 0; _hasMore = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('History cleared'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
        actions: _entries.isEmpty ? null : [
          IconButton(
            icon: Icon(Icons.delete_sweep, color: Colors.white54, size: 22.r),
            tooltip: 'Clear all',
            onPressed: _clearAll,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: _entries.isEmpty && !_isLoading
            ? Center(
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
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!(ref.watch(premiumControllerProvider).valueOrNull?.isPremium ?? false))
                    GestureDetector(
                      onTap: () => context.push('/premium'),
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.stars, color: Colors.amber, size: 20.r),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'Showing last 7 days. Upgrade to Premium for full history.',
                                style: TextStyle(color: Colors.white, fontSize: 13.sp),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14.r),
                          ],
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 12.h),
                    child: Text('$_total entries', style: TextStyle(color: Colors.grey[500], fontSize: 12.sp)),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scroll) {
                        if (scroll is ScrollEndNotification && scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                          _loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        itemCount: _entries.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _entries.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)),
                            );
                          }
                          final item = _entries[index];
                          final song = item['song'] as Map<String, dynamic>? ?? {};
                          return Dismissible(
                            key: ValueKey(song['id']),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 16.w),
                              color: Colors.red,
                              child: Icon(Icons.delete_outline, color: Colors.white, size: 24.r),
                            ),
                            onDismissed: (_) => _deleteEntry(song['id'] ?? ''),
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              onTap: () => context.push('/player'),
                              leading: Container(
                                width: 50.w, height: 50.h,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: Colors.grey[800],
                                  image: (song['image_url'] as String? ?? '').isNotEmpty
                                    ? DecorationImage(image: NetworkImage(song['image_url']), fit: BoxFit.cover)
                                    : null,
                                ),
                                child: (song['image_url'] as String? ?? '').isEmpty
                                    ? Icon(Icons.music_note, color: Colors.white54, size: 24.r) : null,
                              ),
                              title: Text(song['title'] ?? '', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                              subtitle: Text('${song['subtitle'] ?? ''}  •  ${item['count'] ?? 0} plays', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
