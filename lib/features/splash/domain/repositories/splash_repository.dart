abstract class SplashRepository {
  Future<bool> checkAuthStatus();
  Future<void> setAuthStatus(bool isLoggedIn);
}
