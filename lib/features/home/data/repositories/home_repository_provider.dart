import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/data/repositories/home_repository_impl.dart';
import 'package:sonus/features/home/domain/repositories/home_repository.dart';

part 'home_repository_provider.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  return HomeRepositoryImpl();
}
