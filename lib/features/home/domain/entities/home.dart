import 'package:freezed_annotation/freezed_annotation.dart';

part 'home.freezed.dart';
part 'home.g.dart';

@freezed
class Home with _$Home {
  const factory Home({
    required String id,
    required String title,
    @Default('') String subtitle,
    @Default('') String imageUrl,
    @Default('') String audioUrl,
    @Default('youtube')
    String source, // 'youtube' | 'jamendo' | 'deezer_preview'
    String? youtubeId,
    String? deezerId,
    String? jamendoId,
    String? nctId,
    Duration? duration,
  }) = _Home;

  factory Home.fromJson(Map<String, dynamic> json) => _$HomeFromJson(json);
}
