import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_routine.dart';
import '../../providers/routine_provider.dart';

/// 舞段库页面
class RoutinePage extends ConsumerStatefulWidget {
  const RoutinePage({super.key});

  @override
  ConsumerState<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends ConsumerState<RoutinePage> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allRoutinesAsync = ref.watch(allRoutinesProvider);
    final categoriesAsync = ref.watch(routineCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('舞段库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/routines/add'),
          ),
        ],
      ),
      body: Column(
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

          // 舞段列表
          Expanded(
            child: allRoutinesAsync.when(
              data: (routines) => _buildRoutineList(routines),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Text('加载失败: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/routines/add'),
        child: const Icon(Icons.add),
      ),
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

  /// 舞段列表
  Widget _buildRoutineList(List<DanceRoutine> routines) {
    // 筛选
    final filteredRoutines = _selectedCategory != null
        ? routines.where((r) => r.category == _selectedCategory).toList()
        : routines;

    if (filteredRoutines.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRoutines.length,
      itemBuilder: (context, index) {
        final routine = filteredRoutines[index];
        return _RoutineCard(routine: routine);
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
            Icons.music_note_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有添加舞段',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右上角 + 添加你的第一个舞段',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/routines/add'),
            icon: const Icon(Icons.add),
            label: const Text('添加舞段'),
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

/// 舞段卡片
class _RoutineCard extends ConsumerWidget {
  final DanceRoutine routine;

  const _RoutineCard({required this.routine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final didChange = await context.push<bool>(
          '/routines/edit/${routine.id}',
        );
        if (didChange == true) {
          ref.invalidate(allRoutinesProvider);
          ref.invalidate(routineCountProvider);
          ref.invalidate(routineCategoriesProvider);
          ref.invalidate(trainingRoutinesProvider);
        }
      },
      child: Container(
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

          // 舞段信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routine.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  routine.category,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                if (routine.notes != null && routine.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    routine.notes!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 熟练度信息
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: routine.masteryLevel / 100,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_getMasteryColor()),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '熟练度 ${routine.masteryLevel}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  Color _getStatusColor() {
    switch (routine.status) {
      case RoutineStatus.new_:
        return AppColors.warning;
      case RoutineStatus.learning:
        return AppColors.info;
      case RoutineStatus.reviewing:
        return AppColors.success;
    }
  }

  Color _getMasteryColor() {
    if (routine.masteryLevel < 30) {
      return AppColors.warning;
    } else if (routine.masteryLevel < 70) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }
}
