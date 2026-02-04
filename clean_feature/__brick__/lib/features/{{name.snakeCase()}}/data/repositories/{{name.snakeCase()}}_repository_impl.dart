import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/{{name.snakeCase()}}_repository.dart';
import '../../domain/entities/{{name.snakeCase()}}.dart';
import '../models/{{name.snakeCase()}}_model.dart';

part '{{name.snakeCase()}}_repository_impl.g.dart';

class {{name.pascalCase()}}RepositoryImpl implements {{name.pascalCase()}}Repository {
  @override
  Future<List<{{name.pascalCase()}}>> get{{name.pascalCase()}}s() async {
    // TODO: Implement API call or Database fetch
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Example: empty list
    final List<{{name.pascalCase()}}Model> models = [];

    // Map content to {{name.pascalCase()}}Model then to Entity
    return models.map((model) => model.toEntity()).toList();
  }
}

// Provider để inject repository
@riverpod
{{name.pascalCase()}}Repository {{name.camelCase()}}Repository({{name.pascalCase()}}RepositoryRef ref) {
  return {{name.pascalCase()}}RepositoryImpl();
}
