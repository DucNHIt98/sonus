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

      return Login(
        id: response.user['id']?.toString() ?? '',
        email: response.user['email']?.toString() ?? '',
        name: response.user['display_name']?.toString() ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Login?> signInWithGoogle() async {
    try {
      final response = await _authService.signInWithGoogle();

      if (response != null) {
        return Login(
          id: response.user['id']?.toString() ?? '',
          email: response.user['email']?.toString() ?? '',
          name: response.user['display_name']?.toString() ?? '',
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
