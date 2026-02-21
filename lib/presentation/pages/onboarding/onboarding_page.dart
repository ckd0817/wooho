import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/dance_elements_provider.dart';
import 'widgets/dance_style_selector.dart';
import 'widgets/confirmation_dialog.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final libraryAsync = ref.watch(danceElementsLibraryProvider);
    final selectedStyles = ref.watch(selectedStylesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: libraryAsync.when(
          data: (library) => _buildContent(library.categories, selectedStyles),
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '加载失败',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<DanceCategory> categories, Set<String> selectedStyles) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题区域
          _buildHeader(),
          const SizedBox(height: 32),

          // 舞种选择区域
          Text(
            '选择你感兴趣的舞种',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '可选择多个，稍后可随时调整',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),

          // 舞种网格
          Expanded(
            child: DanceStyleSelector(
              categories: categories,
              selectedIds: selectedStyles,
              onSelectionChanged: (ids) {
                ref.read(selectedStylesProvider.notifier).state = ids;
              },
            ),
          ),

          // 底部按钮
          const SizedBox(height: 24),
          _buildBottomButtons(selectedStyles),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '欢迎来到',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          'Wooho',
          style: AppTextStyles.heading1.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '让我们开始你的舞蹈学习之旅',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons(Set<String> selectedStyles) {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: _isProcessing ? null : () => _skipAndComplete(),
            child: Text(
              '暂不设置',
              style: TextStyle(
                color: _isProcessing
                    ? AppColors.textHint
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: selectedStyles.isEmpty || _isProcessing
                ? null
                : () => _showConfirmationDialog(selectedStyles),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.textPrimary,
                    ),
                  )
                : const Text('确认选择'),
          ),
        ),
      ],
    );
  }

  Future<void> _showConfirmationDialog(Set<String> selectedStyles) async {
    final library = await ref.read(danceElementsLibraryProvider.future);
    int totalElements = 0;

    for (final categoryId in selectedStyles) {
      final category = library.categories.firstWhere((c) => c.id == categoryId);
      totalElements += category.elements.length;
    }

    if (!mounted) return;
    final result = await ConfirmationDialog.show(
      context,
      selectedCount: selectedStyles.length,
      totalMoves: totalElements,
    );

    if (result == true) {
      await _addMovesAndComplete(selectedStyles);
    } else if (result == false) {
      // 用户选择不添加，直接完成引导
      await _completeOnboarding();
    }
  }

  Future<void> _addMovesAndComplete(Set<String> selectedStyles) async {
    setState(() => _isProcessing = true);

    try {
      await ref
          .read(onboardingNotifierProvider.notifier)
          .addSelectedMoves(selectedStyles);
      await _completeOnboarding();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _skipAndComplete() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }
}
