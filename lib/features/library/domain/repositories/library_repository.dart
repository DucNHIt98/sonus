import 'package:sonus/features/home/domain/entities/home.dart';

abstract class LibraryRepository {
  Future<List<Home>> getUserPlaylists();
}
