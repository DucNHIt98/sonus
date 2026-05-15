import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/downloads/domain/entities/downloaded_song.dart';
import 'package:sonus/features/downloads/data/repositories/download_repository_impl.dart';

part 'download_provider.g.dart';

@Riverpod(keepAlive: true)
class DownloadController extends _$DownloadController {
  @override
  Future<List<DownloadedSong>> build() async {
    final repo = ref.read(downloadRepositoryProvider);
    return repo.getDownloads();
  }

  Future<bool> downloadSong({
    required String songId,
    String title = '',
    String subtitle = '',
    String imageUrl = '',
    String audioUrl = '',
    int? duration,
    String source = '',
  }) async {
    final repo = ref.read(downloadRepositoryProvider);
    final success = await repo.markDownloaded(
      songId: songId,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      duration: duration,
      source: source,
    );
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  Future<bool> removeDownload(String songId) async {
    final repo = ref.read(downloadRepositoryProvider);
    final success = await repo.removeDownload(songId);
    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@Riverpod(keepAlive: true)
class DownloadQuotaController extends _$DownloadQuotaController {
  @override
  Future<Map<String, dynamic>> build() async {
    final repo = ref.read(downloadRepositoryProvider);
    final quota = await repo.getQuota();
    if (quota == null) {
      return {'is_premium': false, 'downloads_used': 0, 'downloads_limit': 20};
    }
    return quota;
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

final isSongDownloadedProvider = FutureProvider.family<bool, String>((ref, songId) async {
  final downloads = await ref.watch(downloadControllerProvider.future);
  return downloads.any((d) => d.song.id == songId);
});
