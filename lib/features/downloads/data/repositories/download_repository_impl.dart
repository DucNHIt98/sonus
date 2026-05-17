import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/data/models/home_model.dart';
import 'package:sonus/features/downloads/data/datasources/download_remote_data_source.dart';
import 'package:sonus/features/downloads/domain/entities/downloaded_song.dart';
import 'package:sonus/features/downloads/domain/repositories/download_repository.dart';

part 'download_repository_impl.g.dart';

@riverpod
DownloadRepository downloadRepository(DownloadRepositoryRef ref) {
  return DownloadRepositoryImpl(ref.read(downloadRemoteDataSourceProvider));
}

class DownloadRepositoryImpl implements DownloadRepository {
  final DownloadRemoteDataSource _dataSource;

  DownloadRepositoryImpl(this._dataSource);

  @override
  Future<List<DownloadedSong>> getDownloads({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final result = await _dataSource.getDownloads(
        offset: offset,
        limit: limit,
      );
      final list = result['downloads'] as List<dynamic>? ?? [];
      return list.map((json) {
        final songJson = json['song'] as Map<String, dynamic>;
        final homeModel = HomeModel(
          id: songJson['id'] ?? '',
          title: songJson['title'] ?? '',
          subtitle: songJson['subtitle'] ?? '',
          imageUrl: songJson['image_url'] ?? '',
        );
        return DownloadedSong(
          downloadedAt: DateTime.parse(json['downloaded_at'] as String),
          song: homeModel.toEntity(),
        );
      }).toList();
    } catch (e, stack) {
      debugPrint('Error fetching downloads: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  @override
  Future<int> getTotalDownloads() async {
    try {
      final result = await _dataSource.getDownloads(
        offset: 0,
        limit: 1,
        returnTotal: true,
      );
      return result['total'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<bool> markDownloaded({
    required String songId,
    String title = '',
    String subtitle = '',
    String imageUrl = '',
    String audioUrl = '',
    int? duration,
    String source = '',
  }) async {
    final result = await _dataSource.markDownloaded(
      songId: songId,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      duration: duration,
      source: source,
    );
    return result != null;
  }

  @override
  Future<bool> removeDownload(String songId) async {
    return _dataSource.removeDownload(songId);
  }

  @override
  Future<Map<String, dynamic>?> getQuota() async {
    return _dataSource.getQuota();
  }
}
