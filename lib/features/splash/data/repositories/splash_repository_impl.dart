import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonus/core/auth/auth_service.dart';

import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  final AuthService _authService;
  static const String _isLoggedInKey = 'is_logged_in';

  SplashRepositoryImpl(this._authService);

  @override
  Future<bool> checkAuthStatus() async {
    final isValid = await _authService.hasValidSession();
    if (isValid) {
      await setAuthStatus(true);
      return true;
    }

    await setAuthStatus(false);
    return false;
  }

  @override
  Future<void> setAuthStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }
}
