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
import '../../../data/models/routine_record.dart';

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

/// 训练记录项
class _TrainingHistoryItem {
  final String id;
  final String name;
  final String type; // 'element' or 'routine'
  final int timestamp;

  _TrainingHistoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.timestamp,
  });
}

/// 最近训练记录 Provider（autoDispose 确保每次进入首页都刷新）
final recentTrainingHistoryProvider = FutureProvider.autoDispose<List<_TrainingHistoryItem>>((ref) async {
  final elementDao = ReviewDao();
  final routineDao = RoutineRecordDao();
  final elementDataDao = DanceElementDao();
  final routineDataDao = DanceRoutineDao();

  // 获取最近的元素训练记录
  final elementRecords = await elementDao.getRecentRecords(limit: 10);
  // 获取最近的舞段训练记录
  final routineRecords = await routineDao.getRecentRecords(limit: 10);

  // 获取元素名称映射
  final elements = await elementDataDao.getAll();
  final elementMap = {for (var e in elements) e.id: e};

  // 获取舞段名称映射
  final routines = await routineDataDao.getAll();
  final routineMap = {for (var r in routines) r.id: r};

  // 合并并转换为统一格式
  final items = <_TrainingHistoryItem>[];

  for (final record in elementRecords) {
    final element = elementMap[record.elementId];
    if (element != null) {
      items.add(_TrainingHistoryItem(
        id: record.elementId,
        name: element.name,
        type: 'element',
        timestamp: record.reviewedAt,
      ));
    }
  }

  for (final record in routineRecords) {
    final routine = routineMap[record.routineId];
    if (routine != null) {
      items.add(_TrainingHistoryItem(
        id: record.routineId,
        name: routine.name,
        type: 'routine',
        timestamp: record.reviewedAt,
      ));
    }
  }

  // 按时间排序，取最近的 5 条
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return items.take(5).toList();
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

            // 最近训练
            _buildRecentHistory(context, ref),
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

  /// 最近训练记录
  Widget _buildRecentHistory(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentTrainingHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '最近训练',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        historyAsync.when(
          data: (items) {
            if (items.isEmpty) {
              return _buildEmptyHistory();
            }
            return Column(
              children: items.map((item) => _buildHistoryItem(item)).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => _buildEmptyHistory(),
        ),
      ],
    );
  }

  /// 空状态
  Widget _buildEmptyHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '暂无训练记录',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 训练记录项
  Widget _buildHistoryItem(_TrainingHistoryItem item) {
    final timeStr = _formatTime(item.timestamp);
    final isElement = item.type == 'element';

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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isElement ? Icons.music_note : Icons.queue_music,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  isElement ? '元素' : '舞段',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeStr,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化时间
  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}月${dateTime.day}日';
    }
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
