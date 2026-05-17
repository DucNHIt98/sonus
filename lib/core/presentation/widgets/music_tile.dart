import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/presentation/widgets/cached_artwork.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';

class MusicTile extends ConsumerWidget {
  final MusicModel song;
  final List<MusicModel>? contextQueue;

  const MusicTile({super.key, required this.song, this.contextQueue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: CachedArtwork(
          imageUrl: song.albumArt,
          width: 50.w,
          height: 50.w,
          fallback: Container(
            width: 50.w,
            height: 50.w,
            color: Colors.grey[800],
            child: const Icon(Icons.music_note, color: Colors.white54),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12.sp,
        ),
      ),
      trailing: Text(
        song.duration != null
            ? '${song.duration!.inMinutes}:${(song.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
            : '',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12.sp,
        ),
      ),
      onTap: () async {
        await ref
            .read(playerControllerProvider.notifier)
            .playMusicModel(song, contextQueue: contextQueue);

        if (context.mounted) {
          context.pushNamed('player');
        }
      },
    );
  }
}
