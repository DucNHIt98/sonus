import 'package:sonus/features/downloads/domain/entities/downloaded_song.dart';

abstract class DownloadRepository {
  Future<List<DownloadedSong>> getDownloads({int offset = 0, int limit = 20});
  Future<int> getTotalDownloads();
  Future<bool> markDownloaded({
    required String songId,
    String title = '',
    String subtitle = '',
    String imageUrl = '',
    String audioUrl = '',
    int? duration,
    String source = '',
  });
  Future<bool> removeDownload(String songId);
  Future<Map<String, dynamic>?> getQuota();
}
