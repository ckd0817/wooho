import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/library/library_page.dart';
import '../../presentation/pages/library/add_move_page.dart';
import '../../presentation/pages/review/review_page.dart';
import '../../presentation/pages/drill/drill_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

/// 路由路径常量
class Routes {
  Routes._();

  static const String onboarding = '/onboarding';
  static const String home = '/';
  static const String library = '/library';
  static const String addElement = '/library/add';
  static const String review = '/review';
  static const String drill = '/drill';
  static const String settings = '/settings';
}

/// 应用路由配置
class AppRouter {
  AppRouter._();

  /// 主要路由列表（不包含 onboarding）
  static final List<RouteBase> routes = [
    GoRoute(
      path: Routes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: Routes.library,
      name: 'library',
      builder: (context, state) => const LibraryPage(),
    ),
    GoRoute(
      path: Routes.addElement,
      name: 'addElement',
      builder: (context, state) => const AddMovePage(),
    ),
    GoRoute(
      path: Routes.review,
      name: 'review',
      builder: (context, state) => const ReviewPage(),
    ),
    GoRoute(
      path: Routes.drill,
      name: 'drill',
      builder: (context, state) {
        // 获取传递的元素列表
        final elementIds = state.extra as List<String>?;
        return DrillPage(elementIds: elementIds ?? []);
      },
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ];

  static final GoRouter router = GoRouter(
    routes: routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面未找到: ${state.error}'),
      ),
    ),
  );
}
