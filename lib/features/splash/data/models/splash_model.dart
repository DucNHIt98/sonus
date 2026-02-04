import 'package:freezed_annotation/freezed_annotation.dart';

part 'splash_model.freezed.dart';
part 'splash_model.g.dart';

@freezed
class SplashModel with _$SplashModel {
  const factory SplashModel({required String status}) = _SplashModel;

  factory SplashModel.fromJson(Map<String, dynamic> json) =>
      _$SplashModelFromJson(json);
}
