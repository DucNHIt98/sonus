import '../entities/{{name.snakeCase()}}.dart';

abstract class {{name.pascalCase()}}Repository {
  Future<List<{{name.pascalCase()}}>> get{{name.pascalCase()}}s();
}