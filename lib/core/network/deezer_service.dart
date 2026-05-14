import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/dio_client.dart';

part 'deezer_service.g.dart';

@Riverpod(keepAlive: true)
DeezerService deezerService(DeezerServiceRef ref) {
  return DeezerService(ref.read(dioClientProvider));
}

class DeezerService {
  final Dio _dio;

  DeezerService(this._dio);

  Future<List<MusicModel>> getTrendingMusic() async {
    try {
      final response = await _dio.get('https://api.deezer.com/chart');
      if (response.statusCode == 200) {
        final List<dynamic> tracks = response.data['tracks']['data'];
        return tracks.map((track) => MusicModel.fromDeezer(track)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<MusicModel>> getPlaylistTracks(String playlistId) async {
    try {
      final response = await _dio.get(
        'https://api.deezer.com/playlist/$playlistId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> tracks = response.data['tracks']['data'];
        int rank = 1;
        return tracks
            .map((track) => MusicModel.fromDeezer(track, rank: rank++))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
