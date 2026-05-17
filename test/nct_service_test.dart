import 'package:flutter_test/flutter_test.dart';
import 'package:sonus/core/models/music_model.dart';

void main() {
  test('MusicModel detects NCT source from URL-like id', () {
    final model = MusicModel.fromSupabase({
      'id': 'https://www.nhaccuatui.com/bai-hat/sample.html',
      'title': 'Sample',
      'subtitle': 'Artist',
      'source': 'youtube',
    });

    expect(model.source, MusicSource.nct);
  });
}
