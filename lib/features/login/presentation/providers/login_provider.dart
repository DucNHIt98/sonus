import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/login.dart';
import '../../data/repositories/login_repository_impl.dart';

part 'login_provider.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<Login?> build() async {
    return null;
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref
        .read(loginRepositoryProvider)
        .login(email, password);
    if (result != null) {
      state = AsyncData(result);
      return true;
    } else {
      state = AsyncError('Login failed', StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(loginRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}
