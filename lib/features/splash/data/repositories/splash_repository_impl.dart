import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/splash_repository.dart';

class SplashRepositoryImpl implements SplashRepository {
  static const String _isLoggedInKey = 'is_logged_in';

  @override
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Default to false if not set
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  @override
  Future<void> setAuthStatus(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }
}
