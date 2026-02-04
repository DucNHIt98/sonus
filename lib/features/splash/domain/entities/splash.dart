import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash.freezed.dart';
part 'splash.g.dart';

@freezed
class Splash with _$Splash {
  const factory Splash({required String status}) = _Splash;

  factory Splash.fromJson(Map<String, dynamic> json) => _$SplashFromJson(json);
}
