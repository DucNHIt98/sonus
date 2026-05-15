import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/backend_service.dart';

class FavoritesListPage extends ConsumerStatefulWidget {
  const FavoritesListPage({super.key});

  @override
  ConsumerState<FavoritesListPage> createState() => _FavoritesListPageState();
}

class _FavoritesListPageState extends ConsumerState<FavoritesListPage> {
  final List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = false;
  bool _hasMore = true;
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
    final batch = await backend.getFavorites(offset: _offset, limit: _pageSize);
    if (batch.length < _pageSize) _hasMore = false;
    setState(() {
      _favorites.addAll(batch);
      _offset += batch.length;
      _isLoading = false;
    });
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
        title: Text('Favorites', style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold)),
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
          child: _favorites.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, color: Colors.white24, size: 64.r),
                    SizedBox(height: 16.h),
                    Text('No favorites yet', style: TextStyle(color: Colors.white54, fontSize: 16.sp)),
                    SizedBox(height: 8.h),
                    Text('Like songs to add them here', style: TextStyle(color: Colors.white38, fontSize: 14.sp)),
                  ],
                ),
              )
            : NotificationListener<ScrollNotification>(
                onNotification: (scroll) {
                  if (scroll is ScrollEndNotification && scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
                    _loadMore();
                  }
                  return false;
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: _favorites.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _favorites.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Center(child: CircularProgressIndicator(color: Colors.red, strokeWidth: 2)),
                      );
                    }
                    final item = _favorites[index];
                    final song = item['song'] as Map<String, dynamic>? ?? {};
                    return ListTile(
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
                      subtitle: Text(song['subtitle'] ?? '', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                ),
              ),
        ),
      ),
    );
  }
}
