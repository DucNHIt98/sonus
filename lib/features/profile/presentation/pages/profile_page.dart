import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/features/profile/presentation/controllers/profile_controller.dart';
import 'package:sonus/core/auth/auth_service.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/features/profile/presentation/widgets/edit_profile_sheet.dart';

/// Helper to parse avatar URL: supports both HTTP URLs and base64 data URIs
ImageProvider? parseAvatarImage(String url) {
  if (url.startsWith('data:')) {
    try {
      final base64Str = url.split(',').last;
      final bytes = base64Decode(base64Str);
      return MemoryImage(Uint8List.fromList(bytes));
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(url);
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Dark Mode base
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              // Logout logic
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            icon: Icon(Icons.logout, color: Colors.white, size: 24.r),
            tooltip: 'Đăng xuất',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: profileState.when(
        data: (state) {
          final user = state.userProfile;
          if (user == null) {
            return Center(
              child: Text(
                'Không tìm thấy thông tin',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          }

          final rawName = user['full_name'] as String?;
          final displayName = (rawName != null && rawName.isNotEmpty)
              ? rawName
              : 'User';
          final username = user['username'] ?? 'username';
          final avatarUrl = user['avatar_url'] ?? '';

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 100.h, bottom: 40.h),
            child: Column(
              children: [
                // 1. Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ), // Gold border
                        ),
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.grey[800],
                          backgroundImage:
                              (avatarUrl is String && avatarUrl.isNotEmpty)
                              ? parseAvatarImage(avatarUrl)
                              : null,
                          child: (avatarUrl is String && avatarUrl.isEmpty)
                              ? Text(
                                  displayName.isNotEmpty
                                      ? displayName[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontSize: 40.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        displayName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '@$username',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      OutlinedButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) =>
                                EditProfileSheet(userProfile: user),
                          );
                        },
                        icon: Icon(Icons.edit, size: 16.r, color: Colors.red),
                        label: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 8.h,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // 2. Statistics Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Đã nghe',
                        state.playHistoryCount.toString(),
                      ),
                      _buildStatItem(
                        'Yêu thích',
                        state.favoritesCount.toString(),
                      ),
                      _buildStatItem(
                        'Playlists',
                        state.playlistsCount.toString(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // 3. Top Tracks Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Tracks - Bài hát hay nghe',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      if (state.topTracks.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Text(
                              'Chưa có bài hát nào trong top',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.topTracks.length,
                          itemBuilder: (context, index) {
                            final song = state.topTracks[index];
                            return _buildTopTrackItem(
                              context,
                              song,
                              index,
                              ref,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.red)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Đã xảy ra lỗi tải Profile',
                style: const TextStyle(color: Colors.red),
              ),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
              TextButton(
                onPressed: () => ref.refresh(profileControllerProvider),
                child: const Text(
                  'Thử lại',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildTopTrackItem(
    BuildContext context,
    Home song,
    int index,
    WidgetRef ref,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () {
        // Play song logic
        ref
            .read(playerControllerProvider.notifier)
            .playSelectedSongWithMetadata(song);
        context.push('/player');
      },
      leading: Container(
        width: 50.w,
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          image: song.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(song.imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey[800],
        ),
        child: song.imageUrl.isEmpty
            ? Icon(Icons.music_note, color: Colors.white54, size: 24.r)
            : null,
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.subtitle,
        style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          '#${index + 1}',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
