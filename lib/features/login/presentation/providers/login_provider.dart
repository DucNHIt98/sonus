import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/login.dart';
import '../../data/repositories/login_repository_impl.dart';
import 'package:sonus/features/splash/data/repositories/splash_repository_provider.dart';

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
      await ref.read(splashRepositoryProvider).setAuthStatus(true);
      state = AsyncData(result);
      return true;
    } else {
      state = AsyncError('Login failed', StackTrace.current);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final result = await ref.read(loginRepositoryProvider).signInWithGoogle();
      if (result != null) {
        await ref.read(splashRepositoryProvider).setAuthStatus(true);
        state = AsyncData(result);
        return true;
      } else {
        state = const AsyncData(null); // User canceled
        return false;
      }
    } catch (e, stack) {
      state = AsyncError(e.toString(), stack);
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(loginRepositoryProvider).logout();
    await ref.read(splashRepositoryProvider).setAuthStatus(false);
    state = const AsyncData(null);
  }
}
