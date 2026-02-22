import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/user_elements_provider.dart';
import '../../providers/dance_elements_provider.dart';
import '../../widgets/add_move_dialog.dart';

/// 预置元素库 Tab
class OfficialLibraryTab extends ConsumerStatefulWidget {
  const OfficialLibraryTab({super.key});

  @override
  ConsumerState<OfficialLibraryTab> createState() => _OfficialLibraryTabState();
}

class _OfficialLibraryTabState extends ConsumerState<OfficialLibraryTab> {
  String? _selectedCategoryId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(presetElementsLibraryProvider);
    final addedElementsAsync = ref.watch(addedElementsSetProvider);

    return Column(
      children: [
        // 搜索框
        _buildSearchBar(),

        // 分类选择
        libraryAsync.when(
          data: (library) => _buildCategoryFilter(library),
          loading: () => const SizedBox(height: 50),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // 元素列表
        Expanded(
          child: libraryAsync.when(
            data: (library) => addedElementsAsync.when(
              data: (addedElements) => _buildElementsList(library, addedElements),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildElementsList(library, {}),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text('加载失败: $error'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 搜索框
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: '搜索元素...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  /// 分类筛选
  Widget _buildCategoryFilter(PresetElementsLibrary library) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: '全部',
            isSelected: _selectedCategoryId == null,
            onTap: () => setState(() => _selectedCategoryId = null),
          ),
          const SizedBox(width: 8),
          ...library.categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: category.name,
                  isSelected: _selectedCategoryId == category.id,
                  onTap: () => setState(() => _selectedCategoryId = category.id),
                ),
              )),
        ],
      ),
    );
  }

  /// 元素列表
  Widget _buildElementsList(
    PresetElementsLibrary library,
    Set<String> addedElements,
  ) {
    // 获取要显示的元素
    List<(PresetCategory, PresetElement)> elementsToShow;

    if (_searchQuery.isNotEmpty) {
      // 搜索模式
      elementsToShow = library.searchElements(_searchQuery);
    } else if (_selectedCategoryId != null) {
      // 选择分类模式
      final category = library.categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => library.categories.first,
      );
      elementsToShow = category.elements.map((e) => (category, e)).toList();
    } else {
      // 全部分类模式 - 按分类分组显示
      return _buildGroupedElementsList(library, addedElements);
    }

    if (elementsToShow.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: elementsToShow.length,
      itemBuilder: (context, index) {
        final (category, element) = elementsToShow[index];
        final isAdded = addedElements.contains('${category.name}|${element.name}');
        return _ElementCard(
          category: category,
          element: element,
          isAdded: isAdded,
          onAdd: () => _handleAdd(category, element),
        );
      },
    );
  }

  /// 分组显示的元素列表（全部模式）
  Widget _buildGroupedElementsList(
    PresetElementsLibrary library,
    Set<String> addedElements,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: library.categories.length,
      itemBuilder: (context, index) {
        final category = library.categories[index];
        return _CategorySection(
          category: category,
          addedElements: addedElements,
          onAdd: (element) => _handleAdd(category, element),
        );
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
            Icons.search_off,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            '没有找到匹配的元素',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 处理添加元素
  Future<void> _handleAdd(
    PresetCategory category,
    PresetElement element,
  ) async {
    final result = await AddMoveDialog.show(
      context,
      moveName: element.name,
      categoryName: category.name,
    );

    if (result != null && mounted) {
      final success = await ref
          .read(danceElementsNotifierProvider.notifier)
          .quickAddFromOfficial(
            category.name,
            element.name,
            result.masteryLevel,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${element.name} 已添加到我的元素库'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('该元素已存在于您的元素库中'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
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

/// 分类区域（用于分组显示）
class _CategorySection extends StatelessWidget {
  final PresetCategory category;
  final Set<String> addedElements;
  final void Function(PresetElement element) onAdd;

  const _CategorySection({
    required this.category,
    required this.addedElements,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标题
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category.name,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${category.elements.length})',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),

        // 元素列表
        ...category.elements.map((element) {
          final isAdded = addedElements.contains('${category.name}|${element.name}');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ElementCard(
              category: category,
              element: element,
              isAdded: isAdded,
              onAdd: () => onAdd(element),
            ),
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }
}

/// 元素卡片
class _ElementCard extends StatelessWidget {
  final PresetCategory category;
  final PresetElement element;
  final bool isAdded;
  final VoidCallback onAdd;

  const _ElementCard({
    required this.category,
    required this.element,
    required this.isAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAdded ? AppColors.success.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // 元素信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  element.name,
                  style: AppTextStyles.body.copyWith(
                    color: isAdded ? AppColors.textSecondary : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 添加按钮 / 状态
          if (isAdded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '已添加',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            TextButton(
              onPressed: onAdd,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('添加'),
            ),
        ],
      ),
    );
  }
}
