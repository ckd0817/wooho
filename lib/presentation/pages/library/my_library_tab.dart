import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_move.dart';
import '../../providers/dance_moves_provider.dart';

/// 我的动作库 Tab
class MyLibraryTab extends ConsumerStatefulWidget {
  const MyLibraryTab({super.key});

  @override
  ConsumerState<MyLibraryTab> createState() => _MyLibraryTabState();
}

class _MyLibraryTabState extends ConsumerState<MyLibraryTab> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allMovesAsync = ref.watch(allMovesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      children: [
        // 分类筛选
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) return const SizedBox.shrink();
            return _buildCategoryFilter(categories);
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // 动作列表
        Expanded(
          child: allMovesAsync.when(
            data: (moves) => _buildMoveList(moves),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Text('加载失败: $error'),
            ),
          ),
        ),
      ],
    );
  }

  /// 分类筛选
  Widget _buildCategoryFilter(List<String> categories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: '全部',
            isSelected: _selectedCategory == null,
            onTap: () => setState(() => _selectedCategory = null),
          ),
          const SizedBox(width: 8),
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
              )),
        ],
      ),
    );
  }

  /// 动作列表
  Widget _buildMoveList(List<DanceMove> moves) {
    // 筛选
    final filteredMoves = _selectedCategory != null
        ? moves.where((m) => m.category == _selectedCategory).toList()
        : moves;

    if (filteredMoves.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMoves.length,
      itemBuilder: (context, index) {
        final move = filteredMoves[index];
        return _MoveCard(move: move);
      },
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有添加动作',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '从官方动作库快速添加，或自定义创建',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  // 切换到官方动作库 Tab
                  DefaultTabController.of(context).animateTo(1);
                },
                icon: const Icon(Icons.explore_outlined),
                label: const Text('浏览官方库'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => context.push('/library/add'),
                icon: const Icon(Icons.add),
                label: const Text('自定义添加'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 分类筛选芯片
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

/// 动作卡片
class _MoveCard extends StatelessWidget {
  final DanceMove move;

  const _MoveCard({required this.move});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 状态指示器
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // 动作信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  move.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  move.category,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // 熟练度信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 熟练度进度条
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: move.masteryLevel / 100,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_getMasteryColor()),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '熟练度 ${move.masteryLevel}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (move.status) {
      case MoveStatus.new_:
        return AppColors.warning;
      case MoveStatus.learning:
        return AppColors.info;
      case MoveStatus.reviewing:
        return AppColors.success;
    }
  }

  Color _getMasteryColor() {
    if (move.masteryLevel < 30) {
      return AppColors.warning;
    } else if (move.masteryLevel < 70) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }
}
