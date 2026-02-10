import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/auth/auth_service.dart';

part 'sign_up_provider.g.dart';

@riverpod
class SignUpController extends _$SignUpController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    state = const AsyncLoading();

    try {
      await ref
          .read(authServiceProvider)
          .signUpWithUsername(
            email: email,
            password: password,
            username: username,
            fullName: fullName,
          );

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }
}
