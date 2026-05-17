import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/core/presentation/widgets/cached_artwork.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class PlaylistPage extends ConsumerStatefulWidget {
  final String playlistId;
  final String? title;
  final String? imageUrl;
  final String? description;

  const PlaylistPage({
    super.key,
    required this.playlistId,
    this.title,
    this.imageUrl,
    this.description,
  });

  @override
  ConsumerState<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends ConsumerState<PlaylistPage> {
  Map<String, dynamic>? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final backend = ref.read(backendServiceProvider);
    final detail = await backend.getPlaylistDetail(widget.playlistId);
    if (mounted) {
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    }
  }

  void _playAll() {
    final songs = _detail?['songs'] as List? ?? [];
    if (songs.isEmpty) return;
    final homeSongs = songs.map((s) {
      final m = s as Map<String, dynamic>;
      return Home(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        subtitle: m['subtitle'] ?? '',
        imageUrl: m['image_url'] ?? '',
        source: m['source'] ?? 'youtube',
        youtubeId: m['id'],
        duration: Duration(seconds: (m['duration'] ?? 0) as int),
      );
    }).toList();
    ref.read(playerControllerProvider.notifier).playSong(homeSongs.first);
    context.push('/player');
  }

  @override
  Widget build(BuildContext context) {
    final songs = (_detail?['songs'] as List?) ?? [];
    final songCount = _detail?['song_count'] as int? ?? songs.length;

    return Scaffold(
      backgroundColor: Colors.black,
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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                centerTitle: true,
                title: Text(
                  'FROM "PLAYLISTS"',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.sp,
                    letterSpacing: 2,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                floating: true,
                pinned: false,
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Container(
                        width: 240.w,
                        height: 240.w,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedArtwork(
                            imageUrl: widget.imageUrl ?? '',
                            width: 240.w,
                            height: 240.w,
                            fallback: Container(
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.music_note,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        widget.title ?? 'Playlist',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      if (widget.description != null &&
                          widget.description!.isNotEmpty)
                        Text(
                          widget.description!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14.sp,
                          ),
                        ),
                      SizedBox(height: 8.h),
                      Text(
                        '$songCount songs',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13.sp,
                        ),
                      ),

                      if (!_isLoading && songs.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _playAll,
                            icon: Icon(Icons.play_arrow, size: 20.r),
                            label: Text(
                              'Play All',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (songs.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No songs yet',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final s = songs[index] as Map<String, dynamic>;
                    final song = Home(
                      id: s['id'] ?? '',
                      title: s['title'] ?? '',
                      subtitle: s['subtitle'] ?? '',
                      imageUrl: s['image_url'] ?? '',
                      source: s['source'] ?? 'youtube',
                      youtubeId: s['id'],
                      duration: Duration(seconds: (s['duration'] ?? 0) as int),
                    );
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedArtwork(
                            imageUrl: song.imageUrl,
                            width: 50.w,
                            height: 50.w,
                            fallback: Container(
                              color: Colors.grey[800],
                              width: 50.w,
                              height: 50.w,
                            ),
                          ),
                        ),
                        title: Text(
                          song.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          song.subtitle,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13.sp,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.grey[400],
                            size: 20.r,
                          ),
                          onPressed: () {},
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                        onTap: () {
                          ref
                              .read(playerControllerProvider.notifier)
                              .playSong(song);
                          context.push('/player');
                        },
                      ),
                    );
                  }, childCount: songs.length),
                ),

              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }
}
