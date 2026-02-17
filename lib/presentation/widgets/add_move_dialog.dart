import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/services/srs_algorithm_service.dart';

/// 快速添加对话框结果
class QuickAddResult {
  final MasteryLevel masteryLevel;

  const QuickAddResult({required this.masteryLevel});
}

/// 快速添加对话框
class AddMoveDialog extends StatefulWidget {
  final String moveName;
  final String categoryName;

  const AddMoveDialog({
    super.key,
    required this.moveName,
    required this.categoryName,
  });

  /// 显示对话框
  static Future<QuickAddResult?> show(
    BuildContext context, {
    required String moveName,
    required String categoryName,
  }) {
    return showDialog<QuickAddResult>(
      context: context,
      builder: (context) => AddMoveDialog(
        moveName: moveName,
        categoryName: categoryName,
      ),
    );
  }

  @override
  State<AddMoveDialog> createState() => _AddMoveDialogState();
}

class _AddMoveDialogState extends State<AddMoveDialog> {
  MasteryLevel _selectedLevel = MasteryLevel.new_;
  bool _isAdding = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text('添加到我的动作库'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 动作信息
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.moveName,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.categoryName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 熟练度选择
          Text(
            '初始熟练度',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: MasteryLevel.values.map((level) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: level != MasteryLevel.mastered ? 8 : 0,
                  ),
                  child: _MasteryOption(
                    level: level,
                    isSelected: _selectedLevel == level,
                    onTap: () => setState(() => _selectedLevel = level),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isAdding ? null : () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _isAdding
              ? null
              : () {
                  Navigator.of(context).pop(
                    QuickAddResult(masteryLevel: _selectedLevel),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
          ),
          child: _isAdding
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textPrimary,
                  ),
                )
              : const Text('添加'),
        ),
      ],
    );
  }
}

/// 熟练度选项
class _MasteryOption extends StatelessWidget {
  final MasteryLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _MasteryOption({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  String get _label {
    switch (level) {
      case MasteryLevel.new_:
        return '新手';
      case MasteryLevel.learning:
        return '学习中';
      case MasteryLevel.mastered:
        return '已掌握';
    }
  }

  String get _interval {
    switch (level) {
      case MasteryLevel.new_:
        return '1天后复习';
      case MasteryLevel.learning:
        return '3天后复习';
      case MasteryLevel.mastered:
        return '7天后复习';
    }
  }

  Color get _color {
    switch (level) {
      case MasteryLevel.new_:
        return AppColors.warning;
      case MasteryLevel.learning:
        return AppColors.info;
      case MasteryLevel.mastered:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? _color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _color : AppColors.surfaceLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              _label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? _color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              _interval,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
