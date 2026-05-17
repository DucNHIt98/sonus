import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/network/backend_service.dart';

part 'download_remote_data_source.g.dart';

@riverpod
DownloadRemoteDataSource downloadRemoteDataSource(
  DownloadRemoteDataSourceRef ref,
) {
  return DownloadRemoteDataSourceImpl(ref.read(backendServiceProvider));
}

abstract class DownloadRemoteDataSource {
  Future<Map<String, dynamic>> getDownloads({
    int offset = 0,
    int limit = 20,
    bool returnTotal = false,
  });
  Future<Map<String, dynamic>?> markDownloaded({
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

class DownloadRemoteDataSourceImpl implements DownloadRemoteDataSource {
  final BackendService _backend;

  DownloadRemoteDataSourceImpl(this._backend);

  @override
  Future<Map<String, dynamic>> getDownloads({
    int offset = 0,
    int limit = 20,
    bool returnTotal = false,
  }) async {
    return _backend.getDownloads(
      offset: offset,
      limit: limit,
      returnTotal: returnTotal,
    );
  }

  @override
  Future<Map<String, dynamic>?> markDownloaded({
    required String songId,
    String title = '',
    String subtitle = '',
    String imageUrl = '',
    String audioUrl = '',
    int? duration,
    String source = '',
  }) async {
    return _backend.downloadSong(
      songId,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      duration: duration,
      source: source,
    );
  }

  @override
  Future<bool> removeDownload(String songId) async {
    return _backend.removeDownload(songId);
  }

  @override
  Future<Map<String, dynamic>?> getQuota() async {
    return _backend.getDownloadQuota();
  }
}
