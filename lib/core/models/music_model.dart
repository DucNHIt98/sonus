import 'package:sonus/features/home/domain/entities/home.dart';

enum MusicSource { jamendo, youtube, nct }

class MusicModel {
  final String id;
  final String title;
  final String artist;
  final String albumArt;
  final String? albumName;
  final String?
  audioUrl; // Link MP3 (có đối với Jamendo, null đối với YouTube chờ xử lý)
  final MusicSource source;
  final String? genre;
  final String? region;
  final int? rank;
  final Duration? duration;

  MusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    this.albumName,
    this.audioUrl,
    required this.source,
    this.genre,
    this.region,
    this.rank,
    this.duration,
  });

  // Chuyển đổi từ bảng 'songs' của Supabase
  factory MusicModel.fromSupabase(Map<String, dynamic> json) {
    return MusicModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      artist: json['subtitle'] ?? '',
      albumArt: json['image_url'] ?? '',
      audioUrl: json['audio_url'],
      albumName: json['album_name'],
      source: _resolveSource(json['source'], json['id']),
      genre: json['genre'],
      region: json['region'],
      // rank: json['trending_rank'], // Removed as per user request
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
    );
  }

  // Map để lưu vào Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': artist,
      'image_url': albumArt,
      'album_name': albumName,
      'audio_url': audioUrl,
      'source': source.name,
      'genre': genre,
      'region': region,
      // 'trending_rank': rank, // Removed as per user request
      'duration': duration?.inSeconds,
    };
  }

  // Chuyển đổi sang Home entity (UI)
  Home toEntity() {
    return Home(
      id: id,
      title: title,
      subtitle: artist,
      imageUrl: albumArt,
      audioUrl: audioUrl ?? '',
      source: source.name,
      duration: duration,
      jamendoId: source == MusicSource.jamendo ? id : null,
      nctId: source == MusicSource.nct ? id : null,
    );
  }

  static MusicSource _resolveSource(String? sourceString, dynamic id) {
    // 1. If source is explicitly provided and NOT 'youtube' (default), use it
    if (sourceString != null &&
        sourceString.isNotEmpty &&
        sourceString != 'youtube') {
      try {
        return MusicSource.values.firstWhere((e) => e.name == sourceString);
      } catch (_) {}
    }

    // 2. If source is 'youtube' OR null, double check ID format to be sure
    // (Legacy data might have defaulted to youtube)
    final idStr = id.toString();
    if (idStr.contains('nhaccuatui.com')) return MusicSource.nct;
    if (idStr.contains('jamendo.com')) return MusicSource.jamendo;

    // 3. Default to matches or YouTube
    if (sourceString != null) {
      try {
        return MusicSource.values.firstWhere(
          (e) => e.name == sourceString,
          orElse: () => MusicSource.youtube,
        );
      } catch (_) {
        return MusicSource.youtube;
      }
    }

    return MusicSource.youtube;
  }
}
