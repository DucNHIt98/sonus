import 'package:sonus/features/home/domain/entities/home.dart';

abstract class HomeRepository {
  Future<Map<String, List<Home>>> getHomeData();
  Future<void> addToRecentlyPlayed(Home song);
}
