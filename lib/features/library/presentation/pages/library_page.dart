import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/library/data/repositories/library_repository_impl.dart';
import 'package:sonus/features/library/presentation/widgets/library_widgets.dart';
import 'package:sonus/features/premium/presentation/providers/premium_provider.dart';


class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch playlists
    final playlistsAsync = ref.watch(userPlaylistsProvider);

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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: CustomScrollView(
              slivers: [
                // 1. Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: const LibraryHeader(),
                  ),
                ),

                // 2. Premium Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _PremiumBanner(),
                  ),
                ),

                // 3. Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: LibraryFilterChips(
                      onDownloadsTap: () => context.push('/downloads'),
                    ),
                  ),
                ),

                // 3. Sort Row (Mock)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.white, size: 18.r),
                        SizedBox(width: 8.w),
                        Text(
                          'Recents',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.grid_view, color: Colors.white, size: 18.r),
                      ],
                    ),
                  ),
                ),

                // 4. Library List (Real Data)
                playlistsAsync.when(
                  data: (playlists) {
                    if (playlists.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No playlists found',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final playlist = playlists[index];
                        return InkWell(
                          onTap: () {
                            context.pushNamed(
                              'playlist-detail',
                              pathParameters: {'id': playlist.id},
                              extra: {
                                'title': playlist.title,
                                'imageUrl': playlist.imageUrl,
                                'description': playlist.subtitle,
                              },
                            );
                          },
                          child: LibraryListTile(
                            title: playlist.title,
                            subtitle: playlist.subtitle.isEmpty
                                ? 'Playlist'
                                : playlist.subtitle,
                            imageUrl: playlist.imageUrl,
                            isPinned: index < 2, // Mock pinning for now
                          ),
                        );
                      }, childCount: playlists.length),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),

                // Extra space
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Provider to fetch user playlists
final userPlaylistsProvider = FutureProvider<List<Home>>((ref) async {
  final repo = ref.read(libraryRepositoryProvider);
  return repo.getUserPlaylists();
});

class _PremiumBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(premiumControllerProvider);

    return statusAsync.when(
      data: (status) {
        if (status.isPremium) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                Icon(Icons.verified, color: Colors.white, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Premium Active',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }
        return GestureDetector(
          onTap: () => context.push('/premium'),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade800, Colors.red.shade600],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.white, size: 20.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Upgrade to Premium',
                    style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14.r),
              ],
            ),
          ),
        );
      },
      loading: () => SizedBox.shrink(),
      error: (_, __) => SizedBox.shrink(),
    );
  }
}
