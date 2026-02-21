import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../providers/dance_elements_provider.dart';

class DanceStyleSelector extends StatelessWidget {
  final List<PresetCategory> categories;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectionChanged;

  const DanceStyleSelector({
    super.key,
    required this.categories,
    required this.selectedIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedIds.contains(category.id);

        return _StyleCard(
          category: category,
          isSelected: isSelected,
          onTap: () {
            final newSelection = Set<String>.from(selectedIds);
            if (isSelected) {
              newSelection.remove(category.id);
            } else {
              newSelection.add(category.id);
            }
            onSelectionChanged(newSelection);
          },
        );
      },
    );
  }
}

class _StyleCard extends StatelessWidget {
  final PresetCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: AppTextStyles.heading3.copyWith(
                      color:
                          isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${category.elements.length} 个元素',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    category.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: _CheckMark(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 16,
        color: AppColors.textPrimary,
      ),
    );
  }
}
