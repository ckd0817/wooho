import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_element.dart';
import '../../providers/user_elements_provider.dart';

/// 我的元素库 Tab
class MyLibraryTab extends ConsumerStatefulWidget {
  const MyLibraryTab({super.key});

  @override
  ConsumerState<MyLibraryTab> createState() => _MyLibraryTabState();
}

class _MyLibraryTabState extends ConsumerState<MyLibraryTab> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allElementsAsync = ref.watch(allElementsProvider);
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

        // 元素列表
        Expanded(
          child: allElementsAsync.when(
            data: (elements) => _buildElementList(elements),
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

  /// 元素列表
  Widget _buildElementList(List<DanceElement> elements) {
    // 筛选
    final filteredElements = _selectedCategory != null
        ? elements.where((e) => e.category == _selectedCategory).toList()
        : elements;

    if (filteredElements.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredElements.length,
      itemBuilder: (context, index) {
        final element = filteredElements[index];
        return _ElementCard(element: element);
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
            '还没有添加元素',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '从官方元素库快速添加，或自定义创建',
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
                  // 切换到官方元素库 Tab
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

/// 元素卡片
class _ElementCard extends StatelessWidget {
  final DanceElement element;

  const _ElementCard({required this.element});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/library/edit/${element.id}'),
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

          // 元素信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element.name,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  element.category,
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
                    value: element.masteryLevel / 100,
                    backgroundColor: AppColors.surfaceLight,
                    valueColor: AlwaysStoppedAnimation<Color>(_getMasteryColor()),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '熟练度 ${element.masteryLevel}%',
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
    switch (element.status) {
      case ElementStatus.new_:
        return AppColors.warning;
      case ElementStatus.learning:
        return AppColors.info;
      case ElementStatus.reviewing:
        return AppColors.success;
    }
  }

  Color _getMasteryColor() {
    if (element.masteryLevel < 30) {
      return AppColors.warning;
    } else if (element.masteryLevel < 70) {
      return AppColors.info;
    } else {
      return AppColors.success;
    }
  }
}
