import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/features/player/presentation/controllers/player_controller.dart';
import 'package:sonus/core/network/supabase_repository.dart';

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
        child: song.albumArt.isNotEmpty
            ? Image.network(
                song.albumArt,
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50.w,
                  height: 50.w,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
              )
            : Container(
                width: 50.w,
                height: 50.w,
                color: Colors.grey[800],
                child: const Icon(Icons.music_note, color: Colors.white54),
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
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp),
      ),
      trailing: Text(
        song.duration != null
            ? '${song.duration!.inMinutes}:${(song.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
            : '',
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp),
      ),
      onTap: () async {
        if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
          // Play the song using PlayerController
          await ref
              .read(playerControllerProvider.notifier)
              .playMusicModel(song, contextQueue: contextQueue);

          // Navigation to player screen
          if (context.mounted) {
            context.pushNamed('player');
          }

          // Background sync to Supabase
          ref.read(supabaseRepositoryProvider).saveSongToLibrary(song);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Audio URL not available for this track.'),
            ),
          );
        }
      },
    );
  }
}
