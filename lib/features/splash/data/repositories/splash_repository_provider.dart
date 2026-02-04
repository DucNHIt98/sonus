import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/splash_repository.dart';
import 'splash_repository_impl.dart';

part 'splash_repository_provider.g.dart';

@riverpod
SplashRepository splashRepository(SplashRepositoryRef ref) {
  return SplashRepositoryImpl();
}
