import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sonus/core/network/supabase_provider.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

part 'song_sync_service.g.dart';

@Riverpod(keepAlive: true)
SongSyncService songSyncService(SongSyncServiceRef ref) {
  return SongSyncService(ref.read(supabaseClientProvider));
}

class SongSyncService {
  final SupabaseClient _client;

  SongSyncService(this._client);

  /// Upsert bài hát vào bảng songs trên Supabase
  Future<void> syncSong(Home song) async {
    try {
      final youtubeId = song.youtubeId ?? song.id;

      // Chuẩn bị dữ liệu để upsert
      // Lưu ý: Cấu trúc này cần khớp với schema trên Supabase của bạn
      final songData = {
        'id': youtubeId, // Dùng YouTube Id làm khoá chính
        'title': song.title,
        'image_url': song.imageUrl,
        'duration': song.duration?.inSeconds ?? 0,
        'source': song.source,
        'subtitle': song.subtitle,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('songs')
          .upsert(
            songData,
            onConflict: 'id', // Xử lý nếu ID đã tồn tại
          );

      debugPrint('Supabase: Synced song "${song.title}"');
    } catch (e) {
      debugPrint('Supabase Error syncing song: $e');
      // Không ném lỗi để tránh làm gián đoạn việc phát nhạc
    }
  }
}
