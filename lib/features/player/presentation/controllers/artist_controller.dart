import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/search/data/services/youtube_service.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// NOTE: Run `flutter pub run build_runner build` to generate .g.dart and .freezed.dart files
part 'artist_controller.g.dart';
part 'artist_controller.freezed.dart';

@freezed
class ArtistData with _$ArtistData {
  const factory ArtistData({Channel? channel, @Default([]) List<Video> songs}) =
      _ArtistData;
}

@riverpod
Future<ArtistData> artistController(
  ArtistControllerRef ref,
  String videoId,
) async {
  final youtubeService = ref.read(youtubeServiceProvider);

  // 1. Get video details to find channelId
  final video = await youtubeService.getVideoDetails(videoId);
  if (video == null) {
    throw Exception('Video not found');
  }

  // 2. Parallel fetch: Channel details + Channel songs
  final results = await Future.wait([
    youtubeService.getChannelDetails(video.channelId.value),
    youtubeService.getSongsFromChannel(
      videoId,
    ), // This already uses channelId internally but takes videoId convenience
  ]);

  return ArtistData(
    channel: results[0] as Channel?,
    songs: results[1] as List<Video>,
  );
}
