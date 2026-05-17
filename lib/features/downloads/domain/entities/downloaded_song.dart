import 'package:sonus/features/home/domain/entities/home.dart';

class DownloadedSong {
  final DateTime downloadedAt;
  final Home song;

  const DownloadedSong({required this.downloadedAt, required this.song});
}
