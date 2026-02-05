import 'package:sonus/features/home/domain/entities/home.dart';

abstract class PlaylistRepository {
  Future<List<Home>> getPlaylistSongs(String playlistId);
}
