import 'package:flutter_test/flutter_test.dart';
import 'package:sonus/core/models/music_model.dart';

void main() {
  test('MusicModel keeps YouTube source for plain video ids', () {
    final model = MusicModel.fromSupabase({
      'id': 'Y2-QJsbv1WQ',
      'title': 'Sample',
      'subtitle': 'Artist',
      'source': 'youtube',
    });

    expect(model.source, MusicSource.youtube);
  });
}
