import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:sonus/core/network/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'nct_service.g.dart';

@Riverpod(keepAlive: true)
NctService nctService(NctServiceRef ref) {
  return NctService(Dio(), ref.read(supabaseClientProvider));
}

class NctService {
  final Dio _dio;
  final SupabaseClient _supabaseClient; // Inject SupabaseClient

  NctService(this._dio, this._supabaseClient);

  Future<MusicModel?> fetchNCTSong(String nctUrl) async {
    try {
      // 1. Tải HTML
      final response = await _dio.get(nctUrl);
      final html = response.data.toString();

      // 2. Extract Metadata from JSON-LD
      String title = '';
      String artist = 'Unknown';
      String image = '';
      String audioUrl = '';

      final jsonLdRegex = RegExp(
        r'<script type="application/ld\+json">(.*?)</script>',
        dotAll: true,
      );
      final jsonLdMatch = jsonLdRegex.firstMatch(html);

      if (jsonLdMatch != null) {
        try {
          final jsonLdContent = jsonLdMatch.group(1)!;
          final Map<String, dynamic> jsonLd = jsonDecode(jsonLdContent);

          if (jsonLd['@type'] == 'MusicRecording') {
            title = jsonLd['name'] ?? '';
            image = jsonLd['image'] ?? '';

            final byArtist = jsonLd['byArtist'];
            if (byArtist is List) {
              artist = byArtist.map((a) => a['name']).join(', ');
            }
          }
        } catch (e) {
          debugPrint('NCTService: Error parsing JSON-LD: $e');
        }
      }

      // 3. Regex find Audio URL
      // Pattern: https://...stream.nct.vn...mp3...
      final audioRegex = RegExp(
        r'https://[^"]*?stream\.nct\.vn[^"]*?\.mp3[^"]*',
      );
      final matches = audioRegex.allMatches(html);

      if (matches.isNotEmpty) {
        // Prefer HQ if available
        final hqMatch = matches.firstWhere(
          (m) => m.group(0)!.contains('_hq') || m.group(0)!.contains('320kbps'),
          orElse: () => matches.first,
        );
        audioUrl = hqMatch.group(0)!;
      }

      if (audioUrl.isEmpty) {
        debugPrint('NCTService: No audio URL found via Regex');
        return null;
      }

      final key = nctUrl; // Use URL as ID if no other ID found

      return MusicModel(
        id: key,
        title: title.isEmpty ? "Unknown Song" : title,
        artist: artist,
        albumArt: image,
        audioUrl: audioUrl,
        source: MusicSource.nct,
      );
    } catch (e) {
      debugPrint('NCTService Error: $e');
      return null;
    }
  }

  Future<void> syncNCTToSupabase(MusicModel song) async {
    try {
      // Kiểm tra xem bài hát đã tồn tại chưa
      final existing = await _supabaseClient
          .from('songs')
          .select('id')
          .eq('id', song.id)
          .maybeSingle();

      if (existing == null) {
        // Chưa tồn tại -> Upsert
        // Map MusicModel field to Supabase columns
        // Assuming columns: id, title, subtitle, image_url, audio_url, source
        await _supabaseClient.from('songs').upsert({
          'id': song.id,
          'title': song.title,
          'subtitle': song.artist,
          'image_url': song.albumArt,
          'audio_url': song.audioUrl,
          'source': 'nct',
          // 'duration': song.duration?.inSeconds, // Duration might not be available from XML directly unless parsed
        });
        debugPrint('NCTService: Synced song ${song.title} to Supabase');
      } else {
        debugPrint('NCTService: Song ${song.title} already exists in Supabase');
      }
    } catch (e) {
      debugPrint('NCTService Sync Error: $e');
    }
  }

  Future<List<MusicModel>> searchSongs(String query) async {
    try {
      // Use internal AJAX API which returns JSON
      final url =
          'https://www.nhaccuatui.com/ajax/search?q=${Uri.encodeComponent(query)}';

      final response = await _dio.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      // Response content-type might be text/html or application/json depending on headers,
      // but body is JSON string.
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (data['error_message'] != 'Success') {
        return [];
      }

      final songList = data['data']['song'] as List<dynamic>?;
      if (songList == null || songList.isEmpty) {
        return [];
      }

      return songList.map((item) {
        final singers =
            (item['singer'] as List<dynamic>?)
                ?.map((s) => s['name'].toString())
                .join(', ') ??
            'Unknown';

        return MusicModel(
          id: item['url'], // Use URL as ID for consistency with fetchNCTSong
          title: item['name'],
          artist: singers,
          albumArt:
              '', // AJAX API doesn't return song thumb, UI should handle this
          source: MusicSource.nct,
          audioUrl: '', // Lazy load
        );
      }).toList();
    } catch (e) {
      debugPrint('NCTService Search Error: $e');
      return [];
    }
  }

  Future<List<MusicModel>> fetchTopSongs(String region) async {
    try {
      String url = '';
      switch (region) {
        case 'V-Pop':
          // Verified: Contains "Hôn Lễ Của Em" as of Feb 2026
          url = 'https://www.nhaccuatui.com/chart/1-5-d43-2026';
          break;
        case 'US-UK':
          // Verified: Top 50 Âu Mỹ
          url = 'https://www.nhaccuatui.com/chart/1-2-d43-2026';
          break;
        case 'K-Pop':
          // Verified: Top 50 Nhạc Hàn
          url = 'https://www.nhaccuatui.com/chart/1-3-d43-2026';
          break;
        case 'V-Rap':
          // Verified: Top 50 Nhạc Rap Việt
          url = 'https://www.nhaccuatui.com/chart/1-15-d43-2026';
          break;
        case 'Billboard':
          // Verified: Top 50 Billboard Global
          url = 'https://www.nhaccuatui.com/chart/1-9-d43-2026';
          break;
        default:
          url = 'https://www.nhaccuatui.com/chart/1-5-d43-2026';
      }

      print('NCTService: Fetching Top 50 for $region from $url');
      final response = await _dio.get(url);
      final html = response.data.toString();

      // 1. Parse JSON-LD for Titles and URLs (Order is reliable)
      final jsonLdRegex = RegExp(
        r'<script type="application/ld\+json">(.*?)</script>',
        dotAll: true,
      );
      final jsonLdMatch = jsonLdRegex.firstMatch(html);

      if (jsonLdMatch == null) {
        print('NCTService: Could not find JSON-LD');
        return [];
      }

      final jsonLdContent = jsonLdMatch.group(1)!;
      final Map<String, dynamic> jsonLd = jsonDecode(jsonLdContent);

      final List<dynamic> tracks = jsonLd['track'] ?? [];
      if (tracks.isEmpty) {
        print('NCTService: No tracks in JSON-LD');
        return [];
      }

      // 2. Parse HTML for Artists (Order matches JSON-LD)
      // Split by "song-item" to separate blocks
      final songItems = html.split('class="song-item');
      // Remove the first chunk which is before the first song
      if (songItems.isNotEmpty) songItems.removeAt(0);

      List<MusicModel> songs = [];

      for (int i = 0; i < tracks.length; i++) {
        final track = tracks[i];
        final pageUrl = track['url'] as String;
        final title = track['name'] as String;

        // Default artist
        String artist = "Unknown";

        // Try to find artist in corresponding HTML block
        if (i < songItems.length) {
          final itemHtml = songItems[i];
          // Find matches for artist name-text spans
          // Use simpler regex to avoid issues with attributes order
          final artistRegex = RegExp(r'class="name-text[^>]*>([^<]+)</span>');
          final artistMatches = artistRegex.allMatches(itemHtml);

          if (artistMatches.isNotEmpty) {
            // Filter out empty or irrelevant matches if needed
            artist = artistMatches.map((m) => m.group(1)!).join(', ');
          }
        }

        songs.add(
          MusicModel(
            id: pageUrl, // Use Page URL as ID for lazy loading
            title: title,
            artist: artist,
            albumArt: '', // Will be fetched lazily
            source: MusicSource.nct,
            audioUrl: '', // Lazy load later
            region: region,
          ),
        );
      }

      print('NCTService: Found ${songs.length} songs for $region');
      return songs;
    } catch (e) {
      debugPrint('NCTService Error fetching Top 20: $e');
      return [];
    }
  }
}
