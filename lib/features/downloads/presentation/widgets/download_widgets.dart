import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sonus/core/presentation/widgets/cached_artwork.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

class DownloadedSongTile extends StatelessWidget {
  final Home song;
  final String downloadedAt;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const DownloadedSongTile({
    super.key,
    required this.song,
    required this.downloadedAt,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey[800],
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedArtwork(
                imageUrl: song.imageUrl,
                fallback: _placeholder(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    song.subtitle.isNotEmpty ? song.subtitle : 'Downloaded',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.white54,
                  size: 20.r,
                ),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Icon(Icons.music_note, color: Colors.white54, size: 24.r);
  }
}
