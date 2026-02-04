import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  @override
  Future<bool> checkAuthStatus() async {
    // Simulate API call or local DB check
    await Future.delayed(const Duration(seconds: 2));
    // Return true to simulate logged in, false for not logged in
    // For now, hardcode to false (navigate to Auth)
    return false;
  }
}
