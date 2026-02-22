import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../settings/training_settings_page.dart' show allElementsQueueProvider, allRoutinesQueueProvider;

/// 训练队列页面
class QueuePage extends ConsumerWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('训练队列'),
          actions: [
            TextButton(
              onPressed: () => context.push('/settings/training'),
              child: Text(
                '详细设置',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: '元素队列'),
              Tab(text: '舞段队列'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ElementQueueTab(),
            _RoutineQueueTab(),
          ],
        ),
      ),
    );
  }
}

/// 元素队列 Tab
class _ElementQueueTab extends ConsumerWidget {
  const _ElementQueueTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(allElementsQueueProvider);

    return queueAsync.when(
      data: (elements) {
        if (elements.isEmpty) {
          return _buildEmptyState(
            context,
            '暂无待训练元素',
            '请先在元素库中添加元素',
            () => context.go('/library'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: elements.length,
          itemBuilder: (context, index) {
            final element = elements[index];
            return _buildQueueItem(
              index: index,
              name: element.name,
              subtitle: element.category,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => _buildEmptyState(
        context,
        '加载失败',
        error.toString(),
        null,
      ),
    );
  }
}

/// 舞段队列 Tab
class _RoutineQueueTab extends ConsumerWidget {
  const _RoutineQueueTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(allRoutinesQueueProvider);

    return queueAsync.when(
      data: (routines) {
        if (routines.isEmpty) {
          return _buildEmptyState(
            context,
            '暂无待训练舞段',
            '请先在舞段库中添加舞段',
            () => context.go('/routines'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routines.length,
          itemBuilder: (context, index) {
            final routine = routines[index];
            return _buildQueueItem(
              index: index,
              name: routine.name,
              subtitle: routine.category,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, _) => _buildEmptyState(
        context,
        '加载失败',
        error.toString(),
        null,
      ),
    );
  }
}

/// 队列项
Widget _buildQueueItem({
  required int index,
  required String name,
  required String subtitle,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${index + 1}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// 空状态组件
Widget _buildEmptyState(
  BuildContext context,
  String title,
  String subtitle,
  VoidCallback? onTap,
) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onTap != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('前往添加'),
            ),
          ],
        ],
      ),
    ),
  );
}
