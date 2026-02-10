import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/entities/login.dart';
import 'package:sonus/core/auth/auth_service.dart';

part 'login_repository_impl.g.dart';

class LoginRepositoryImpl implements LoginRepository {
  final AuthService _authService;

  LoginRepositoryImpl(this._authService);

  @override
  Future<Login?> login(String email, String password) async {
    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return Login(
          id: response.user!.id,
          email: response.user!.email ?? '',
          name: response.user!.userMetadata?['full_name'] ?? '',
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _authService.signOut();
  }
}

@riverpod
LoginRepository loginRepository(LoginRepositoryRef ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginRepositoryImpl(authService);
}
