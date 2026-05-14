import '../entities/login.dart';

abstract class LoginRepository {
  Future<Login?> login(String email, String password);
  Future<Login?> signInWithGoogle();
  Future<void> logout();
}
