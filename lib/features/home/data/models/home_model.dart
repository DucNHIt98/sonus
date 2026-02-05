import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sonus/features/home/domain/entities/home.dart';
import 'package:json_annotation/json_annotation.dart';

part 'home_model.freezed.dart';
part 'home_model.g.dart';

@freezed
class HomeModel with _$HomeModel {
  const HomeModel._();

  const factory HomeModel({
    required String id,
    required String title,
    @Default('') String subtitle,
    @Default('') String imageUrl,
    @JsonKey(name: 'audio_url') @Default('') String audioUrl,
    @Default('youtube') String source,
    @JsonKey(name: 'youtube_id') String? youtubeId,
    @JsonKey(name: 'duration_ms') int? durationMs,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);

  Home toEntity() => Home(
    id: id,
    title: title,
    subtitle: subtitle,
    imageUrl: imageUrl,
    audioUrl: audioUrl,
    source: source,
    youtubeId: youtubeId,
    duration: durationMs != null ? Duration(milliseconds: durationMs!) : null,
  );
}
