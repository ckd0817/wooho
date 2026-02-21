import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/training_constants.dart';
import '../../../data/datasources/local/dance_element_dao.dart';
import '../../../data/datasources/local/dance_routine_dao.dart';
import '../../../data/models/dance_element.dart';
import '../../../data/models/dance_routine.dart';
import '../../providers/training_settings_provider.dart';

/// 所有元素队列 Provider（按优先级排序，不限制数量）
final allElementsQueueProvider = FutureProvider<List<DanceElement>>((ref) async {
  final settings = ref.watch(trainingSettingsProvider);
  final dao = DanceElementDao();

  // 如果有自定义顺序，按自定义顺序获取
  if (settings.customElementOrder.isNotEmpty) {
    final allElements = await dao.getAllOrderedByPriority();
    final orderedElements = <DanceElement>[];
    final addedIds = <String>{};

    // 先按自定义顺序添加
    for (final id in settings.customElementOrder) {
      final element = allElements.where((e) => e.id == id).firstOrNull;
      if (element != null) {
        orderedElements.add(element);
        addedIds.add(id);
      }
    }
    // 补充剩余按优先级排序的元素
    for (final element in allElements) {
      if (!addedIds.contains(element.id)) {
        orderedElements.add(element);
      }
    }
    return orderedElements;
  }

  // 否则按优先级排序
  return await dao.getAllOrderedByPriority();
});

/// 所有舞段队列 Provider（按优先级排序，不限制数量）
final allRoutinesQueueProvider = FutureProvider<List<DanceRoutine>>((ref) async {
  final settings = ref.watch(trainingSettingsProvider);
  final dao = DanceRoutineDao();

  // 如果有自定义顺序，按自定义顺序获取
  if (settings.customRoutineOrder.isNotEmpty) {
    final allRoutines = await dao.getAllOrderedByPriority();
    final orderedRoutines = <DanceRoutine>[];
    final addedIds = <String>{};

    // 先按自定义顺序添加
    for (final id in settings.customRoutineOrder) {
      final routine = allRoutines.where((r) => r.id == id).firstOrNull;
      if (routine != null) {
        orderedRoutines.add(routine);
        addedIds.add(id);
      }
    }
    // 补充剩余按优先级排序的舞段
    for (final routine in allRoutines) {
      if (!addedIds.contains(routine.id)) {
        orderedRoutines.add(routine);
      }
    }
    return orderedRoutines;
  }

  // 否则按优先级排序
  return await dao.getAllOrderedByPriority();
});

/// 训练设置页面
class TrainingSettingsPage extends StatelessWidget {
  const TrainingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('训练设置'),
          actions: [
            TextButton(
              onPressed: () => _showResetDialog(context),
              child: Text(
                '重置',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: '元素设置'),
              Tab(text: '舞段设置'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ElementSettingsTab(),
            _RoutineSettingsTab(),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) => AlertDialog(
          title: const Text('重置设置'),
          content: const Text('确定要重置所有训练设置为默认值吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(trainingSettingsProvider.notifier).resetToDefault();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已重置为默认设置')),
                );
              },
              child: Text(
                '确定',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 元素设置 Tab
class _ElementSettingsTab extends ConsumerWidget {
  const _ElementSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(trainingSettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基础设置
          _buildSectionTitle('基础设置'),
          const SizedBox(height: 12),
          _buildElementCountSlider(context, ref, settings),

          const SizedBox(height: 32),

          // 队列调整
          _buildSectionTitle('队列调整'),
          const SizedBox(height: 8),
          _buildSubtitle('按优先级排列，可拖拽调整'),
          const SizedBox(height: 12),
          _buildElementQueue(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildElementCountSlider(
    BuildContext context,
    WidgetRef ref,
    TrainingSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '每次训练元素数量',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${settings.elementCount} 个',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Slider(
              value: settings.elementCount.toDouble(),
              min: TrainingConstants.minTrainingCount.toDouble(),
              max: TrainingConstants.maxTrainingCount.toDouble(),
              divisions: TrainingConstants.maxTrainingCount -
                  TrainingConstants.minTrainingCount,
              activeColor: AppColors.primary,
              onChanged: (value) {
                ref
                    .read(trainingSettingsProvider.notifier)
                    .setElementCount(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementQueue(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(allElementsQueueProvider);

    return queueAsync.when(
      data: (elements) {
        if (elements.isEmpty) {
          return _buildEmptyState('暂无元素');
        }
        return _ElementQueueList(
          elements: elements,
          onReorder: (oldIndex, newIndex) {
            // 调整索引
            if (newIndex > oldIndex) newIndex--;
            // 重新排序
            final newOrder = List<DanceElement>.from(elements);
            final item = newOrder.removeAt(oldIndex);
            newOrder.insert(newIndex, item);
            // 保存自定义顺序
            ref
                .read(trainingSettingsProvider.notifier)
                .setCustomElementOrder(newOrder.map((e) => e.id).toList());
          },
          onRemove: (element) {
            // 从队列中移除（从自定义顺序中移除）
            final currentOrder = ref.read(trainingSettingsProvider).customElementOrder;
            final newOrder = currentOrder.where((id) => id != element.id).toList();
            ref
                .read(trainingSettingsProvider.notifier)
                .setCustomElementOrder(newOrder);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => _buildEmptyState('加载失败'),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 舞段设置 Tab
class _RoutineSettingsTab extends ConsumerWidget {
  const _RoutineSettingsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(trainingSettingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基础设置
          _buildSectionTitle('基础设置'),
          const SizedBox(height: 12),
          _buildRoutineCountSlider(context, ref, settings),

          const SizedBox(height: 32),

          // 队列调整
          _buildSectionTitle('队列调整'),
          const SizedBox(height: 8),
          _buildSubtitle('按优先级排列，可拖拽调整'),
          const SizedBox(height: 12),
          _buildRoutineQueue(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildRoutineCountSlider(
    BuildContext context,
    WidgetRef ref,
    TrainingSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '每次训练舞段数量',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${settings.routineCount} 个',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Slider(
              value: settings.routineCount.toDouble(),
              min: TrainingConstants.minTrainingCount.toDouble(),
              max: TrainingConstants.maxTrainingCount.toDouble(),
              divisions: TrainingConstants.maxTrainingCount -
                  TrainingConstants.minTrainingCount,
              activeColor: AppColors.primary,
              onChanged: (value) {
                ref
                    .read(trainingSettingsProvider.notifier)
                    .setRoutineCount(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineQueue(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(allRoutinesQueueProvider);

    return queueAsync.when(
      data: (routines) {
        if (routines.isEmpty) {
          return _buildEmptyState('暂无舞段');
        }
        return _RoutineQueueList(
          routines: routines,
          onReorder: (oldIndex, newIndex) {
            // 调整索引
            if (newIndex > oldIndex) newIndex--;
            // 重新排序
            final newOrder = List<DanceRoutine>.from(routines);
            final item = newOrder.removeAt(oldIndex);
            newOrder.insert(newIndex, item);
            // 保存自定义顺序
            ref
                .read(trainingSettingsProvider.notifier)
                .setCustomRoutineOrder(newOrder.map((r) => r.id).toList());
          },
          onRemove: (routine) {
            // 从队列中移除（从自定义顺序中移除）
            final currentOrder = ref.read(trainingSettingsProvider).customRoutineOrder;
            final newOrder = currentOrder.where((id) => id != routine.id).toList();
            ref
                .read(trainingSettingsProvider.notifier)
                .setCustomRoutineOrder(newOrder);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => _buildEmptyState('加载失败'),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// 元素队列列表（可拖拽排序，可移除）
class _ElementQueueList extends StatelessWidget {
  final List<DanceElement> elements;
  final void Function(int, int) onReorder;
  final void Function(DanceElement) onRemove;

  const _ElementQueueList({
    required this.elements,
    required this.onReorder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        buildDefaultDragHandles: false,
        itemCount: elements.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final element = elements[index];
          return ListTile(
            key: ValueKey(element.id),
            leading: Container(
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
            title: Text(
              element.name,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              element.category,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => onRemove(element),
                  tooltip: '从队列移除',
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 舞段队列列表（可拖拽排序，可移除）
class _RoutineQueueList extends StatelessWidget {
  final List<DanceRoutine> routines;
  final void Function(int, int) onReorder;
  final void Function(DanceRoutine) onRemove;

  const _RoutineQueueList({
    required this.routines,
    required this.onReorder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        buildDefaultDragHandles: false,
        itemCount: routines.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return ListTile(
            key: ValueKey(routine.id),
            leading: Container(
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
            title: Text(
              routine.name,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              routine.category,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => onRemove(routine),
                  tooltip: '从队列移除',
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
