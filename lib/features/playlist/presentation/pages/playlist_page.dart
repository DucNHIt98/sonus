import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/features/playlist/data/repositories/playlist_repository_impl.dart';

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
  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(playlistSongsProvider(widget.playlistId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Same gradient as Library/Home
            colors: [Color(0xFF400503), Colors.black],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 1. App Bar (Custom)
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
                    color: Colors.white.withOpacity(0.7),
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

              // 2. Playlist Header (Image, Title, Desc)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // Artwork
                      Container(
                        width: 240.w,
                        height: 240.w,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child:
                              widget.imageUrl != null &&
                                  widget.imageUrl!.isNotEmpty
                              ? Image.network(
                                  widget.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey[850]),
                                )
                              : Container(
                                  color: Colors.grey[900],
                                  child: const Icon(
                                    Icons.music_note,
                                    size: 80,
                                    color: Colors.white24,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Title
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

                      // Description
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
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 32.h)),

              // 3. Song List
              songsAsync.when(
                data: (songs) {
                  if (songs.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'No songs yet',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = songs[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              song.imageUrl,
                              width: 50.w,
                              height: 50.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
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
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                          ),
                          onTap: () {
                            // Play song
                            ref
                                .read(playerControllerProvider.notifier)
                                .playSong(song);
                            context.push('/player');
                          },
                        ),
                      );
                    }, childCount: songs.length),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),

              // Bottom padding
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple provider to fetch songs
final playlistSongsProvider = FutureProvider.family<List<Home>, String>((
  ref,
  playlistId,
) async {
  final repo = ref.read(playlistRepositoryProvider);
  return repo.getPlaylistSongs(playlistId);
});
