import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/library/library_page.dart';
import '../../presentation/pages/library/add_move_page.dart';
import '../../presentation/pages/review/review_page.dart';
import '../../presentation/pages/drill/drill_page.dart';

/// 路由路径常量
class Routes {
  Routes._();

  static const String home = '/';
  static const String library = '/library';
  static const String addMove = '/library/add';
  static const String review = '/review';
  static const String drill = '/drill';
}

/// 应用路由配置
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: [
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
        path: Routes.addMove,
        name: 'addMove',
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
          // 获取传递的动作列表
          final moveIds = state.extra as List<String>?;
          return DrillPage(moveIds: moveIds ?? []);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面未找到: ${state.error}'),
      ),
    ),
  );
}
