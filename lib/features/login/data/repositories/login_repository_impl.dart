import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/login_repository.dart';
import '../../domain/entities/login.dart';
import '../models/login_model.dart';

part 'login_repository_impl.g.dart';

class LoginRepositoryImpl implements LoginRepository {
  @override
  Future<Login?> login(String email, String password) async {
    // Mock login for now
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'admin@gmail.com' && password == 'password') {
      return const Login(id: '1', email: 'admin@gmail.com', name: 'Admin');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

@riverpod
LoginRepository loginRepository(LoginRepositoryRef ref) {
  return LoginRepositoryImpl();
}
