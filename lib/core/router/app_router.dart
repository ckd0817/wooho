import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/main_shell_page.dart';
import '../../presentation/pages/home/home_page.dart';
import '../../presentation/pages/library/library_page.dart';
import '../../presentation/pages/library/add_move_page.dart';
import '../../presentation/pages/library/edit_element_page.dart';
import '../../presentation/pages/review/review_page.dart';
import '../../presentation/pages/drill/drill_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/settings/training_settings_page.dart';
import '../../presentation/pages/routine/routine_page.dart';
import '../../presentation/pages/routine/add_routine_page.dart';
import '../../presentation/pages/routine/edit_routine_page.dart';
import '../../presentation/pages/routine/routine_review_page.dart';
import '../../presentation/pages/queue/queue_page.dart';

/// 路由路径常量
class Routes {
  Routes._();

  // Shell 路由（底部导航）
  static const String home = '/';
  static const String library = '/library';
  static const String addElement = '/library/add';
  static const String editElement = '/library/edit/:id';
  static const String routines = '/routines';
  static const String addRoutine = '/routines/add';
  static const String editRoutine = '/routines/edit/:id';
  static const String queue = '/queue';

  // 全屏页面
  static const String review = '/review';
  static const String drill = '/drill';
  static const String routineReview = '/routines/review';
  static const String settings = '/settings';
  static const String trainingSettings = '/settings/training';
  static const String onboarding = '/onboarding';
}

/// 应用路由配置
class AppRouter {
  AppRouter._();

  /// 主要路由列表（供 main.dart 使用）
  static final List<RouteBase> routes = [
    // 主 Shell 路由（带底部导航栏）
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellPage(navigationShell: navigationShell);
      },
      branches: [
        // Branch 0: 首页
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Branch 1: 元素库
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.library,
              name: 'library',
              builder: (context, state) => const LibraryPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'addElement',
                  builder: (context, state) => const AddMovePage(),
                ),
                GoRoute(
                  path: 'edit/:id',
                  name: 'editElement',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return EditElementPage(elementId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 2: 舞段库
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.routines,
              name: 'routines',
              builder: (context, state) => const RoutinePage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'addRoutine',
                  builder: (context, state) => const AddRoutinePage(),
                ),
                GoRoute(
                  path: 'edit/:id',
                  name: 'editRoutine',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return EditRoutinePage(routineId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        // Branch 3: 训练队列
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.queue,
              name: 'queue',
              builder: (context, state) => const QueuePage(),
            ),
          ],
        ),
      ],
    ),
    // 全屏页面（无底部导航栏）
    GoRoute(
      path: Routes.review,
      name: 'review',
      builder: (context, state) => const ReviewPage(),
    ),
    GoRoute(
      path: Routes.drill,
      name: 'drill',
      builder: (context, state) {
        final elementIds = state.extra as List<String>?;
        return DrillPage(elementIds: elementIds ?? []);
      },
    ),
    GoRoute(
      path: Routes.routineReview,
      name: 'routineReview',
      builder: (context, state) => const RoutineReviewPage(),
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: Routes.trainingSettings,
      name: 'trainingSettings',
      builder: (context, state) => const TrainingSettingsPage(),
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
