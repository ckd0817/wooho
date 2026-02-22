import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/user_elements_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/routine_provider.dart';
import '../../providers/training_settings_provider.dart';
import '../../../data/datasources/local/review_dao.dart';
import '../../../data/datasources/local/routine_record_dao.dart';
import '../../../data/datasources/local/dance_element_dao.dart';
import '../../../data/datasources/local/dance_routine_dao.dart';
import '../../../data/models/dance_element.dart';
import '../../../data/models/dance_routine.dart';

/// 今日元素练习次数 Provider
final todayElementReviewProvider = FutureProvider<int>((ref) async {
  final dao = ReviewDao();
  return await dao.getTodayReviewCount();
});

/// 今日舞段练习次数 Provider
final todayRoutineReviewProvider = FutureProvider<int>((ref) async {
  final dao = RoutineRecordDao();
  return await dao.getTodayReviewCount();
});

/// 首页待训练元素队列 Provider（显示所有元素）
final homeElementQueueProvider = FutureProvider<List<DanceElement>>((ref) async {
  final settings = ref.watch(trainingSettingsProvider);
  final dao = DanceElementDao();
  final allElements = await dao.getAll();
  final elementMap = {for (var e in allElements) e.id: e};

  if (settings.customElementOrder.isNotEmpty) {
    // 按用户设置的完整顺序返回
    return settings.customElementOrder
        .map((id) => elementMap[id])
        .whereType<DanceElement>()
        .toList();
  }

  // 按 SRS 算法排序（优先级）
  final orderedElements = await dao.getAllOrderedByPriority();
  // 缓存顺序到 customElementOrder
  if (orderedElements.isNotEmpty) {
    Future.microtask(() {
      ref.read(trainingSettingsProvider.notifier).setCustomElementOrder(
        orderedElements.map((e) => e.id).toList(),
      );
    });
  }
  return orderedElements;
});

/// 首页待训练舞段队列 Provider（显示所有舞段）
final homeRoutineQueueProvider = FutureProvider<List<DanceRoutine>>((ref) async {
  final settings = ref.watch(trainingSettingsProvider);
  final dao = DanceRoutineDao();
  final allRoutines = await dao.getAll();
  final routineMap = {for (var r in allRoutines) r.id: r};

  if (settings.customRoutineOrder.isNotEmpty) {
    // 按用户设置的完整顺序返回
    return settings.customRoutineOrder
        .map((id) => routineMap[id])
        .whereType<DanceRoutine>()
        .toList();
  }

  // 按 SRS 算法排序（优先级）
  final orderedRoutines = await dao.getAllOrderedByPriority();
  // 缓存顺序到 customRoutineOrder
  if (orderedRoutines.isNotEmpty) {
    Future.microtask(() {
      ref.read(trainingSettingsProvider.notifier).setCustomRoutineOrder(
        orderedRoutines.map((r) => r.id).toList(),
      );
    });
  }
  return orderedRoutines;
});

/// 首页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elementCountAsync = ref.watch(elementCountProvider);
    final routineCountAsync = ref.watch(routineCountProvider);
    final streakAsync = ref.watch(streakDaysProvider);
    final todayElementAsync = ref.watch(todayElementReviewProvider);
    final todayRoutineAsync = ref.watch(todayRoutineReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wooho'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎区域
            _buildWelcomeSection(streakAsync, todayElementAsync, todayRoutineAsync),
            const SizedBox(height: 24),

            // 训练入口卡片
            _buildTrainingCards(context, ref, elementCountAsync, routineCountAsync),
            const SizedBox(height: 24),

            // 快捷操作
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  /// 欢迎区域
  Widget _buildWelcomeSection(
    AsyncValue<int> streakAsync,
    AsyncValue<int> todayElementAsync,
    AsyncValue<int> todayRoutineAsync,
  ) {
    final greeting = _getGreeting();
    final todayElements = todayElementAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );
    final todayRoutines = todayRoutineAsync.maybeWhen(
      data: (count) => count,
      orElse: () => 0,
    );
    final streak = streakAsync.maybeWhen(
      data: (days) => days,
      orElse: () => 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                greeting,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.fitness_center_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '今日已练习 $todayElements 个元素、$todayRoutines 个舞段',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.local_fire_department_outlined,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                '连续打卡 $streak 天',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取问候语
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return '早上好';
    } else if (hour < 18) {
      return '下午好';
    } else {
      return '晚上好';
    }
  }

  /// 训练入口卡片
  Widget _buildTrainingCards(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> elementCountAsync,
    AsyncValue<int> routineCountAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _TrainingCard(
            icon: Icons.music_note_outlined,
            title: '元素训练',
            countAsync: elementCountAsync,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => _startElementTraining(context, ref, elementCountAsync),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _TrainingCard(
            icon: Icons.queue_music_outlined,
            title: '舞段训练',
            countAsync: routineCountAsync,
            gradient: const LinearGradient(
              colors: [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => _startRoutineTraining(context, ref, routineCountAsync),
          ),
        ),
      ],
    );
  }

  /// 快捷操作
  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '快捷操作',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // 2x2 网格布局
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.library_music_outlined,
                    title: '元素库',
                    onTap: () => context.push('/library'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.queue_music_outlined,
                    title: '舞段库',
                    onTap: () => context.push('/routines'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.playlist_play,
                    title: '训练队列',
                    onTap: () => context.push('/settings/training'),
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ],
    );
  }

  /// 显示训练队列底部弹窗
  void _showTrainingQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TrainingQueueModal(),
    );
  }

  /// 开始元素训练
  void _startElementTraining(BuildContext context, WidgetRef ref, AsyncValue<int> countAsync) {
    countAsync.maybeWhen(
      data: (count) {
        if (count > 0) {
          context.push('/review');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先添加元素')),
          );
        }
      },
      orElse: () {},
    );
  }

  /// 开始舞段训练
  void _startRoutineTraining(BuildContext context, WidgetRef ref, AsyncValue<int> countAsync) {
    countAsync.maybeWhen(
      data: (count) {
        if (count > 0) {
          context.push('/routines/review');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请先添加舞段')),
          );
        }
      },
      orElse: () {},
    );
  }
}

/// 训练入口卡片
class _TrainingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final AsyncValue<int> countAsync;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _TrainingCard({
    required this.icon,
    required this.title,
    required this.countAsync,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 36,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            countAsync.when(
              data: (count) => Text(
                '$count 个',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
              loading: () => Text(
                '-',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
              error: (_, __) => Text(
                '-',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('开始练习'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 快捷操作卡片
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 训练队列底部弹窗
class _TrainingQueueModal extends ConsumerWidget {
  const _TrainingQueueModal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elementQueueAsync = ref.watch(homeElementQueueProvider);
    final routineQueueAsync = ref.watch(homeRoutineQueueProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖动条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '训练队列',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/settings/training');
                  },
                  child: Text(
                    '编辑',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          // 内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 元素队列
                  Row(
                    children: [
                      Icon(
                        Icons.music_note_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '待训练元素',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  elementQueueAsync.when(
                    data: (elements) {
                      if (elements.isEmpty) {
                        return _buildEmptyQueue('暂无待训练元素');
                      }
                      return _buildQueueList(
                        items: elements.map((e) => _QueueItem(
                              id: e.id,
                              name: e.name,
                              subtitle: e.category,
                            )).toList(),
                        onStart: () {
                          Navigator.pop(context);
                          context.push('/review');
                        },
                        startLabel: '开始元素训练',
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => _buildEmptyQueue('加载失败'),
                  ),

                  const SizedBox(height: 24),

                  // 舞段队列
                  Row(
                    children: [
                      Icon(
                        Icons.queue_music_outlined,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '待训练舞段',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  routineQueueAsync.when(
                    data: (routines) {
                      if (routines.isEmpty) {
                        return _buildEmptyQueue('暂无待训练舞段');
                      }
                      return _buildQueueList(
                        items: routines.map((r) => _QueueItem(
                              id: r.id,
                              name: r.name,
                              subtitle: r.category,
                            )).toList(),
                        onStart: () {
                          Navigator.pop(context);
                          context.push('/routines/review');
                        },
                        startLabel: '开始舞段训练',
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (_, __) => _buildEmptyQueue('加载失败'),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQueue(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
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

  Widget _buildQueueList({
    required List<_QueueItem> items,
    required VoidCallback onStart,
    required String startLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 列表项
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
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
                    item.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: AppColors.surfaceLight,
                  ),
              ],
            );
          }),
          // 开始按钮
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(startLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 队列项数据
class _QueueItem {
  final String id;
  final String name;
  final String subtitle;

  const _QueueItem({
    required this.id,
    required this.name,
    required this.subtitle,
  });
}
