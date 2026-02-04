import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/splash_repository_provider.dart';

part 'splash_provider.g.dart';

@riverpod
class SplashController extends _$SplashController {
  @override
  FutureOr<void> build() async {
    final repository = ref.read(splashRepositoryProvider);
    await repository.checkAuthStatus();
    // Logic navigation can be expanded here based on return value
  }
}
