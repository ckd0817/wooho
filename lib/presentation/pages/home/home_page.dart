import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/dance_moves_provider.dart';

/// 首页
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dueCountAsync = ref.watch(dueCountProvider);
    final allMovesAsync = ref.watch(allMovesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DanceLoop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 设置页面
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 今日待办卡片
            _buildTodayCard(context, ref, dueCountAsync),
            const SizedBox(height: 24),

            // 快捷操作
            Text(
              '快捷操作',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context, ref),

            const Spacer(),

            // 统计信息
            _buildStats(context, allMovesAsync),
          ],
        ),
      ),
    );
  }

  /// 今日待办卡片
  Widget _buildTodayCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> dueCountAsync,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '今日待复习',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              dueCountAsync.when(
                data: (count) => Text(
                  '$count',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 48,
                  ),
                ),
                loading: () => const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: AppColors.textPrimary,
                    strokeWidth: 2,
                  ),
                ),
                error: (_, __) => Text(
                  '-',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '个动作',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: dueCountAsync.maybeWhen(
                data: (count) => count > 0
                    ? () => _startReview(context, ref)
                    : null,
                orElse: () => null,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.primary,
              ),
              child: const Text('开始训练'),
            ),
          ),
        ],
      ),
    );
  }

  /// 快捷操作
  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.library_music_outlined,
            title: '动作库',
            onTap: () => context.push('/library'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _ActionCard(
            icon: Icons.add_box_outlined,
            title: '添加动作',
            onTap: () => context.push('/library/add'),
          ),
        ),
      ],
    );
  }

  /// 统计信息
  Widget _buildStats(BuildContext context, AsyncValue<List> allMovesAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: '总动作',
            value: allMovesAsync.maybeWhen(
              data: (moves) => moves.length.toString(),
              orElse: () => '-',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.surfaceLight,
          ),
          _StatItem(
            label: '本周复习',
            value: '-', // TODO: 统计本周复习次数
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.surfaceLight,
          ),
          _StatItem(
            label: '连续打卡',
            value: '-', // TODO: 统计连续打卡天数
          ),
        ],
      ),
    );
  }

  /// 开始复习
  void _startReview(BuildContext context, WidgetRef ref) {
    context.push('/review');
  }
}

/// 快捷操作卡片
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceLight),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
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

/// 统计项
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
