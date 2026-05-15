import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/presentation/widgets/music_tile.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'discover_page.g.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final trendingAsync = ref.watch(trendingMusicProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Trending'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: trendingAsync.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Text(
                'No tracks found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return MusicTile(song: song, contextQueue: songs);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

@Riverpod(keepAlive: true)
Future<List<MusicModel>> trendingMusic(TrendingMusicRef ref) async {
  final feed = await ref.read(backendServiceProvider).getHomeFeed();
  return feed['trending'] as List<MusicModel>? ?? [];
}
