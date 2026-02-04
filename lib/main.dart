import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router/router.dart';

// Khai báo provider cho Isar để dùng ở các layer khác
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

void main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Local Database (Isar)
  // Disable temporarily until we have schemas
  // final dir = await getApplicationDocumentsDirectory();
  // final isar = await Isar.open(
  //   [], // Schema cũ đã bị xóa, hiện tại chưa có schema nào
  //   directory: dir.path,
  // );

  runApp(
    // 3. ProviderScope: Nơi lưu trữ toàn bộ State của ứng dụng
    const ProviderScope(
      overrides: [
        // Inject instance isar vào provider để các Repository có thể dùng
        // isarProvider.overrideWithValue(isar),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy config router từ provider
    final router = ref.watch(routerProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // Standard iPhone dimension
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Sonus Music App',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF7f0000), // Deep Red
            brightness: Brightness.dark,
          ),
          debugShowCheckedModeBanner: false,
          routerConfig: router, // Kết nối GoRouter vào App
        );
      },
    );
  }
}
