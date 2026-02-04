#!/bin/bash

# 1. Tạo cấu trúc thư mục
mkdir -p lib/core/error lib/core/network/interceptors lib/core/usecases
mkdir -p lib/features/user/data/data_sources/{local,remote}
mkdir -p lib/features/user/data/{models,repositories}
mkdir -p lib/features/user/domain/{entities,repositories,usecases}
mkdir -p lib/features/user/presentation/{providers,pages}

# 2. Tạo file Entity (Dùng 'EOT' để không cần escape $)
cat << 'EOT' > lib/features/user/domain/entities/user.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart'; // Thêm dòng này nếu muốn dùng json_serializable sau này

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
EOT

# 3. Tạo Network Client mẫu
cat << 'EOT' > lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 15),
    ),
  );
}
EOT

echo "✅ Cấu trúc Clean Architecture đã sẵn sàng!"