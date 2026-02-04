import 'package:sonus/features/home/data/models/home_model.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<Map<String, List<Home>>> getHomeData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final recent = [
      const HomeModel(
        id: '1',
        title: 'Liked Songs',
        imageUrl:
            'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Playlist',
      ),
      const HomeModel(
        id: '2',
        title: 'Discover Weekly',
        imageUrl:
            'https://images.unsplash.com/photo-1459749411177-8c275d8421c4?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Music to discover',
      ),
      const HomeModel(
        id: '3',
        title: 'Daily Mix 1',
        imageUrl:
            'https://images.unsplash.com/photo-1514525253440-b393452e8d26?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Made for you',
      ),
      const HomeModel(
        id: '4',
        title: 'Rock Classics',
        imageUrl:
            'https://images.unsplash.com/photo-1550291652-6ea9114a47b1?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Playlist',
      ),
      const HomeModel(
        id: '5',
        title: 'Mega Hit Mix',
        imageUrl:
            'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Mixed for you',
      ),
      const HomeModel(
        id: '6',
        title: 'Chill Vibes',
        imageUrl:
            'https://images.unsplash.com/photo-1507838153414-b4b713384ebd?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Relaxing music',
      ),
    ].map((e) => e.toEntity()).toList();

    final madeForYou = [
      const HomeModel(
        id: '7',
        title: 'Release Radar',
        imageUrl:
            'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=300&q=80',
        subtitle: 'New music',
      ),
      const HomeModel(
        id: '8',
        title: 'On Repeat',
        imageUrl:
            'https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Songs you love',
      ),
    ].map((e) => e.toEntity()).toList();

    final jumpBackIn = [
      const HomeModel(
        id: '9',
        title: 'Indie Pop',
        imageUrl:
            'https://images.unsplash.com/photo-1619983081563-430f63602796?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Genre',
      ),
      const HomeModel(
        id: '10',
        title: 'Focus Flow',
        imageUrl:
            'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?auto=format&fit=crop&w=300&q=80',
        subtitle: 'Playlist',
      ),
    ].map((e) => e.toEntity()).toList();

    return {
      'Recently Played': recent,
      'To get you started': madeForYou,
      'Jump back in': jumpBackIn,
    };
  }
}
