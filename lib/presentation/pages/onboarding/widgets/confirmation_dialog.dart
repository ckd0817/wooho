import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ConfirmationDialog extends StatelessWidget {
  final int selectedCount;
  final int totalElements;

  const ConfirmationDialog({
    super.key,
    required this.selectedCount,
    required this.totalElements,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int selectedCount,
    required int totalElements,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmationDialog(
        selectedCount: selectedCount,
        totalElements: totalElements,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: AppColors.surface,
      title: Text(
        '添加到元素库？',
        style: AppTextStyles.heading3,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '你选择了 $selectedCount 个舞种，包含 $totalElements 个元素。',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '是否将这些元素添加到你的个人元素库？',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '初始熟练度将设为 0（新手状态）',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            '暂不添加',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
          ),
          child: const Text('添加'),
        ),
      ],
    );
  }
}
