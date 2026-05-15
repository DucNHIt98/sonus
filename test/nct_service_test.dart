import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:sonus/core/network/nct_service.dart';
import 'package:sonus/core/models/music_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockDio extends Mock implements Dio {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder {}

void main() {
  late NctService nctService;
  late MockDio mockDio;
  late MockSupabaseClient mockSupabaseClient;

  setUp(() {
    mockDio = MockDio();
    mockSupabaseClient = MockSupabaseClient();
    nctService = NctService(mockDio, mockSupabaseClient);
  });

  test('fetchNCTSong returns MusicModel when valid URL provided', () async {
    // Mock HTML response
    when(() => mockDio.get(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data:
            '<html>... player.peConfig.xmlURL = "https://example.com/xml" ...</html>',
        statusCode: 200,
      ),
    );

    // Mock XML response
    const xmlContent = '''
    <track>
      <title>Test Song</title>
      <creator>Test Artist</creator>
      <bgimage>https://example.com/image.jpg</bgimage>
      <location>https://example.com/song.mp3</location>
      <key>12345</key>
    </track>
    ''';

    when(() => mockDio.get('https://example.com/xml')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: xmlContent,
        statusCode: 200,
      ),
    );

    final result = await nctService.fetchNCTSong(
      'https://nhaccuatui.com/bai-hat/test.html',
    );

    expect(result, isNotNull);
    expect(result!.title, 'Test Song');
    expect(result.artist, 'Test Artist');
    expect(result.audioUrl, 'https://example.com/song.mp3');
    expect(result.id, '12345');
  });

  test('fetchNCTSong returns null when XML URL not found', () async {
    when(() => mockDio.get(any())).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: ''),
        data: '<html>... no xml url ...</html>',
        statusCode: 200,
      ),
    );

    final result = await nctService.fetchNCTSong(
      'https://nhaccuatui.com/bai-hat/test.html',
    );

    expect(result, isNull);
  });
}
