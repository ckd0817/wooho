import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 注意: 暂时禁用后台音频服务，因为它在某些设备上有兼容性问题
  // 如需启用后台播放，需要正确配置 AndroidManifest.xml 和 MainActivity

  runApp(
    const ProviderScope(
      child: DanceLoopApp(),
    ),
  );
}

class DanceLoopApp extends StatelessWidget {
  const DanceLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DanceLoop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}
