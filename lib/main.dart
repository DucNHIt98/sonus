import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router/router.dart';

// Khai báo provider cho Isar để dùng ở các layer khác
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

void main() async {
  // 1. Đảm bảo Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  // 3. Initialize Supabase
  // TODO: Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://fxeirztjkgmydwnmsonb.supabase.co',
    anonKey: 'sb_publishable_bTiasBbKJ13_d03V45LaJg_UNYP-G8C',
  );

  // 3. Khởi tạo Local Database (Isar) (Disabled temporarily)
  // final dir = await getApplicationDocumentsDirectory();
  // final isar = await Isar.open(
  //   [],
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
