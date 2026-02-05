import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/splash_repository_provider.dart';

part 'splash_provider.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  FutureOr<bool> build() async {
    final repository = ref.read(splashRepositoryProvider);
    // Simulate splash delay (aesthetic choice)
    await Future.delayed(const Duration(seconds: 2));

    return await repository.checkAuthStatus();
  }
}
