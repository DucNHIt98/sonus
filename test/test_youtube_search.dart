import 'package:sonus/features/search/data/services/youtube_service.dart';

void main() async {
  final service = YoutubeService();
  print('Searching for "Son Tung MTP"...');

  final results = await service.searchSongs('Son Tung MTP');

  if (results.isEmpty) {
    print('No results found.');
  } else {
    print('Found ${results.length} results:');
    for (var video in results.take(5)) {
      print('- ${video.title} (ID: ${video.id}) - Duration: ${video.duration}');
    }
  }

  service.dispose();
}
