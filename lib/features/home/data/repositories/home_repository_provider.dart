import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/core/network/backend_service.dart';
import 'package:sonus/features/home/data/repositories/home_repository_impl.dart';
import 'package:sonus/features/home/domain/repositories/home_repository.dart';

part 'home_repository_provider.g.dart';

@riverpod
HomeRepository homeRepository(HomeRepositoryRef ref) {
  final backend = ref.read(backendServiceProvider);
  return HomeRepositoryImpl(backend);
}
