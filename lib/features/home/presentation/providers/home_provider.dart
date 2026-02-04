import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sonus/features/home/data/repositories/home_repository_provider.dart';
import 'package:sonus/features/home/domain/entities/home.dart';

part 'home_provider.g.dart';

@riverpod
class HomeController extends _$HomeController {
  @override
  FutureOr<Map<String, List<Home>>> build() async {
    final repository = ref.read(homeRepositoryProvider);
    return repository.getHomeData();
  }
}
