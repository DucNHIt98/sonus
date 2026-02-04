import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/{{name.snakeCase()}}.dart';

part '{{name.snakeCase()}}_provider.g.dart';

@riverpod
class {{name.pascalCase()}}Controller extends _${{name.pascalCase()}}Controller {
@override
FutureOr<List<{{name.pascalCase()}}>> build() async {
  return []; // Logic call repository ở đây
  }
}