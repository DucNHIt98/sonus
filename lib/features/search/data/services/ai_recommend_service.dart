import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:sonus/features/search/data/services/youtube_service.dart';

part 'ai_recommend_service.g.dart';

/// AI-powered song recommendation service using Google Gemini
class AiRecommendService {
  final GenerativeModel _model;

  AiRecommendService({required String apiKey})
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: apiKey,
      );

  /// Get song recommendations based on current song
  /// Returns a list of {title, artist} maps
  Future<List<Map<String, String>>> getRecommendations(
    String title,
    String artist, {
    int count = 10,
  }) async {
    final prompt =
        '''
Dựa trên bài hát "$title" của $artist, hãy gợi ý $count bài hát khác cùng tâm trạng và thể loại nhưng mang phong cách chill/sang trọng. 
Trả về kết quả dưới dạng JSON array thuần túy, mỗi object có key là "title" và "artist". 
QUAN TRỌNG: Chỉ trả về JSON array, không có văn bản thừa, không có markdown code block.
Ví dụ: [{"title": "Song Name", "artist": "Artist Name"}]
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null) {
        print('DEBUG: AI response is null');
        return [];
      }

      String responseText = response.text!.trim();
      print('DEBUG: AI raw response: $responseText');

      // Clean up response - remove markdown code blocks if present
      if (responseText.startsWith('```')) {
        responseText = responseText
            .replaceAll(RegExp(r'^```json?\n?'), '')
            .replaceAll(RegExp(r'\n?```$'), '')
            .trim();
      }

      // Parse JSON
      final List<dynamic> data = jsonDecode(responseText);
      final recommendations = data
          .map(
            (e) => {
              'title': e['title']?.toString() ?? '',
              'artist': e['artist']?.toString() ?? '',
            },
          )
          .where((e) => e['title']!.isNotEmpty)
          .toList();

      print('DEBUG: Parsed ${recommendations.length} AI recommendations');
      return recommendations;
    } catch (e) {
      print('DEBUG: AI recommendation error: $e');
      return [];
    }
  }

  /// Get recommendations and search YouTube for each
  /// Returns a list of Home entities with video metadata
  Future<List<Home>> getRecommendedSongs(
    String title,
    String artist,
    YoutubeService youtubeService, {
    int count = 5,
  }) async {
    final recommendations = await getRecommendations(
      title,
      artist,
      count: count,
    );
    final List<Home> songs = [];

    for (final rec in recommendations) {
      try {
        final query = '${rec['title']} ${rec['artist']}';
        print('DEBUG: Searching YouTube for: $query');

        final searchResults = await youtubeService.searchSongs(query);

        if (searchResults.isNotEmpty) {
          final video = searchResults.first;
          songs.add(
            Home(
              id: video.id.value,
              title: video.title,
              subtitle: video.author,
              imageUrl: video.thumbnails.highResUrl,
              source: 'youtube',
              youtubeId: video.id.value,
              duration: video.duration,
            ),
          );
        }
      } catch (e) {
        print('DEBUG: Error searching for ${rec['title']}: $e');
      }
    }

    print('DEBUG: Found ${songs.length} songs from AI recommendations');
    return songs;
  }
}

/// Provider for AiRecommendService
@Riverpod(keepAlive: true)
AiRecommendService aiRecommendService(ref) {
  return AiRecommendService(apiKey: 'AIzaSyBiuugSYQ1Zc5cs3XytCEItlXYmRdaW79A');
}
