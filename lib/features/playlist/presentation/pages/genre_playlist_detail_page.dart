import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/presentation/widgets/music_tile.dart';
import 'package:sonus/features/home/presentation/providers/genre_provider.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class GenrePlaylistDetailPage extends ConsumerWidget {
  final String genre;

  const GenrePlaylistDetailPage({super.key, required this.genre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genreTracksAsync = ref.watch(genreControllerProvider(genre));

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                genre,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _getGenreColor(genre).withOpacity(0.8),
                      Colors.black,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    size: 80.r,
                    color: Colors.white24,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // Play All Button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: genreTracksAsync.maybeWhen(
                      data: (songs) => songs.isNotEmpty
                          ? () {
                              ref
                                  .read(playerControllerProvider.notifier)
                                  .playMusicModel(
                                    songs.first,
                                    contextQueue: songs,
                                  );
                              context.pushNamed('player');
                            }
                          : null,
                      orElse: () => null,
                    ),
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: const Text('Play All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Song List
          genreTracksAsync.when(
            data: (songs) {
              if (songs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No tracks found for $genre',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return MusicTile(song: songs[index], contextQueue: songs);
                  }, childCount: songs.length),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildShimmerTile(),
                  childCount: 10,
                ),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error loading tracks: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  Widget _buildShimmerTile() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[800]!,
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 150.w, height: 14.h, color: Colors.black),
                SizedBox(height: 8.h),
                Container(width: 100.w, height: 12.h, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Pop':
        return Colors.pink;
      case 'Rock':
        return Colors.red;
      case 'Jazz':
        return Colors.orange;
      case 'Lofi':
        return Colors.deepPurple;
      case 'Hip Hop':
        return Colors.blue;
      case 'Electronic':
        return Colors.cyan;
      case 'Country':
        return Colors.brown;
      case 'Chillout':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
