import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/onboarding_provider.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';

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

class DanceLoopApp extends ConsumerWidget {
  const DanceLoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shouldShowOnboarding = ref.watch(shouldShowOnboardingProvider);

    return MaterialApp.router(
      title: 'Wooho',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _createRouter(shouldShowOnboarding),
    );
  }

  GoRouter _createRouter(AsyncValue<bool> shouldShowOnboarding) {
    final showOnboarding = shouldShowOnboarding.maybeWhen(
      data: (show) => show,
      orElse: () => false,
    );

    return GoRouter(
      initialLocation: showOnboarding ? '/onboarding' : '/',
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingPage(),
        ),
        ...AppRouter.routes,
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('页面未找到: ${state.error}'),
        ),
      ),
    );
  }
}
