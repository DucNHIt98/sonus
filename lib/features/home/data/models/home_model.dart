import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

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
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);

  Home toEntity() =>
      Home(id: id, title: title, subtitle: subtitle, imageUrl: imageUrl);
}
