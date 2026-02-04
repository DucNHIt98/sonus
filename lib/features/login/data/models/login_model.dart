import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/login.dart';

part 'login_model.freezed.dart';
part 'login_model.g.dart';

@freezed
class LoginModel with _$LoginModel {
  const factory LoginModel({required String id, String? email, String? name}) =
      _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
}

extension LoginModelX on LoginModel {
  Login toEntity() {
    return Login(id: id, email: email, name: name);
  }
}
