import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/datasources/local/dance_element_dao.dart';
import '../../../data/models/dance_element.dart';
import '../../providers/drill_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/training_settings_provider.dart';
import '../home/home_page.dart'; // 为了访问 homeElementQueueProvider

/// 串联训练完成页面
class DrillCompletePage extends ConsumerStatefulWidget {
  final List<DanceElement> elements; // 串联顺序的元素列表

  const DrillCompletePage({super.key, required this.elements});

  @override
  ConsumerState<DrillCompletePage> createState() => _DrillCompletePageState();
}

class _DrillCompletePageState extends ConsumerState<DrillCompletePage>
    with SingleTickerProviderStateMixin {
  final Set<int> _checkedIndices = {}; // 已打勾的索引
  bool _isAnimating = true; // 动画是否正在进行
  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _startCheckAnimation();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  /// 开始自动打勾动画
  void _startCheckAnimation() {
    for (int i = 0; i < widget.elements.length; i++) {
      Future.delayed(Duration(milliseconds: 300 + i * 200), () {
        if (mounted) {
          setState(() {
            _checkedIndices.add(i);
          });
        }
      });
    }
    // 动画结束
    final totalDuration = 300 + widget.elements.length * 200 + 300;
    Future.delayed(Duration(milliseconds: totalDuration), () {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
        _confettiController.forward();
      }
    });
  }

  /// 返回首页并重置状态
  Future<void> _finishAndGoHome() async {
    // 停止串联训练
    ref.read(drillProvider.notifier).stopDrill();
    // 重置 reviewProvider 状态
    ref.read(reviewProvider.notifier).reset();

    // 重新计算队列顺序（SRS 算法）
    final dao = DanceElementDao();
    final newOrder = await dao.getAllOrderedByPriority();
    await ref.read(trainingSettingsProvider.notifier).setCustomElementOrder(
      newOrder.map((e) => e.id).toList(),
    );

    // 刷新首页训练队列
    ref.invalidate(homeElementQueueProvider);
    ref.invalidate(homeRoutineQueueProvider);

    // 返回首页
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 标题
              Text(
                '练习完成！',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              // 副标题
              Text(
                '本次练习了 ${widget.elements.length} 个元素',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // 元素列表
              Expanded(
                child: ListView.builder(
                  itemCount: widget.elements.length,
                  itemBuilder: (context, index) {
                    final element = widget.elements[index];
                    final isChecked = _checkedIndices.contains(index);

                    return _AnimatedCheckItem(
                      element: element,
                      isChecked: isChecked,
                      index: index,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 完成按钮
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnimating ? null : _finishAndGoHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    disabledBackgroundColor: AppColors.surfaceLight,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isAnimating ? '正在记录...' : '完成练习',
                    style: AppTextStyles.button,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// 带动画的打勾列表项
class _AnimatedCheckItem extends StatelessWidget {
  final DanceElement element;
  final bool isChecked;
  final int index;

  const _AnimatedCheckItem({
    required this.element,
    required this.isChecked,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isChecked
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? AppColors.success : AppColors.surfaceLight,
          width: isChecked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 序号
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isChecked ? AppColors.success : AppColors.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isChecked
                  ? const Icon(
                      Icons.check,
                      color: AppColors.textPrimary,
                      size: 18,
                    )
                  : Text(
                      '${index + 1}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          // 元素名称
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTextStyles.body.copyWith(
                color: isChecked ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(element.name),
            ),
          ),

          // 分类标签
          if (element.category.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                element.category,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
