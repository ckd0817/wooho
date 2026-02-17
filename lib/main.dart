import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化后台音频服务 (如果失败则继续，后台播放功能将不可用)
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.danceloop.app.audio',
      androidNotificationChannelName: 'DanceLoop Audio',
      androidNotificationOngoing: true,
    );
  } catch (e) {
    debugPrint('后台音频初始化失败: $e');
  }

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
