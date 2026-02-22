import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/training_constants.dart';
import '../../../data/models/dance_element.dart';
import '../../../data/models/drum_loop.dart';
import '../../../data/repositories/dance_element_repository.dart';
import '../../providers/drill_provider.dart';
import '../../providers/training_settings_provider.dart';

/// 串联训练页面
class DrillPage extends ConsumerStatefulWidget {
  final List<String> elementIds;

  const DrillPage({super.key, required this.elementIds});

  @override
  ConsumerState<DrillPage> createState() => _DrillPageState();
}

class _DrillPageState extends ConsumerState<DrillPage> {
  List<DanceElement>? _elements;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadElements();
  }

  Future<void> _loadElements() async {
    if (widget.elementIds.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final repository = DanceElementRepository();
    final elements = <DanceElement>[];

    for (final id in widget.elementIds) {
      final element = await repository.getElementById(id);
      if (element != null) {
        elements.add(element);
      }
    }

    setState(() {
      _elements = elements;
      _isLoading = false;
    });

    // 准备训练数据（不自动开始，等待用户点击播放）
    if (elements.isNotEmpty) {
      Future.microtask(() {
        ref.read(drillProvider.notifier).prepareDrill(elements);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final drillState = ref.watch(drillProvider);
    final currentBeat = ref.watch(currentBeatProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.drillBackground,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.drillText,
          ),
        ),
      );
    }

    if (_elements == null || _elements!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.drillBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.drillText),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            '没有可训练的元素',
            style: AppTextStyles.body.copyWith(
              color: AppColors.drillText,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.drillBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部控制栏
            _buildTopBar(context, drillState),

            // 主要内容区域
            Expanded(
              child: _buildMainContent(drillState, currentBeat),
            ),

            // 底部控制面板
            _buildBottomControls(drillState),
          ],
        ),
      ),
    );
  }

  /// 顶部控制栏
  Widget _buildTopBar(BuildContext context, DrillState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.drillText),
            onPressed: () => _confirmExit(context),
          ),
          const Spacer(),
          // BPM 显示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${state.bpm} BPM',
              style: AppTextStyles.drillBpm.copyWith(
                color: AppColors.drillText,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // 平衡布局
        ],
      ),
    );
  }

  /// 主要内容
  Widget _buildMainContent(DrillState state, int currentBeat) {
    final currentElement = state.currentElement;
    final nextElement = state.nextElement;

    return GestureDetector(
      onTap: () => _togglePlayPause(state),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 鼓点显示器
            if (state.hasElements)
              _BeatIndicator(
                currentBeat: currentBeat,
                isPlaying: state.isPlaying,
                beatsPerSwitch: state.beatsPerSwitch,
              ),

            const SizedBox(height: 32),

            // 当前元素名称 (大字)
            if (currentElement != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  currentElement.name,
                  style: AppTextStyles.drillMoveName.copyWith(
                    color: AppColors.drillText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 32),

            // 下一个元素预告
            if (nextElement != null && state.isPlaying)
              Column(
                children: [
                  Text(
                    '下一个',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.drillTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    nextElement.name,
                    style: AppTextStyles.drillNextMove.copyWith(
                      color: AppColors.drillTextSecondary,
                    ),
                  ),
                ],
              ),

            // 播放/暂停提示
            if (!state.isPlaying)
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow,
                      color: AppColors.drillText.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '点击屏幕${state.hasElements ? "继续" : "开始"}',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.drillText.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 底部控制面板
  Widget _buildBottomControls(DrillState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 音频选择器
          if (state.availableLoops.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAudioSelector(state),
            ),

          // 元素切换拍数选择器
          _buildBeatsPerSwitchSelector(state),

          const SizedBox(height: 16),

          // BPM 滑块
          Row(
            children: [
              Text(
                '${AppConstants.minBpm}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.drillTextSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.surfaceLight,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: state.bpm.toDouble(),
                    min: AppConstants.minBpm.toDouble(),
                    max: AppConstants.maxBpm.toDouble(),
                    onChanged: (value) {
                      ref.read(drillProvider.notifier).setBpm(value.round());
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${AppConstants.maxBpm}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.drillTextSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 结束训练按钮
              _ControlButton(
                icon: Icons.flag,
                label: '结束',
                onPressed: () => _showCompleteDialog(context, state),
              ),
              const SizedBox(width: 32),
              // 播放/暂停按钮
              _ControlButton(
                icon: state.isPlaying ? Icons.pause : Icons.play_arrow,
                label: state.isPlaying ? '暂停' : '继续',
                isLarge: true,
                onPressed: () => _togglePlayPause(state),
              ),
              const SizedBox(width: 32),
              // 重洗牌按钮
              _ControlButton(
                icon: Icons.shuffle,
                label: '重洗',
                onPressed: () => _reshuffle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 音频选择器
  Widget _buildAudioSelector(DrillState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<DrumLoop>(
          value: state.currentDrumLoop,
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.music_note, color: AppColors.drillTextSecondary),
          style: AppTextStyles.body.copyWith(color: AppColors.drillText),
          hint: Text(
            '选择音乐',
            style: AppTextStyles.body.copyWith(color: AppColors.drillTextSecondary),
          ),
          items: state.availableLoops.map((loop) {
            return DropdownMenuItem(
              value: loop,
              child: Text(
                loop.name,
                style: AppTextStyles.body.copyWith(color: AppColors.drillText),
              ),
            );
          }).toList(),
          onChanged: (loop) {
            if (loop != null) {
              ref.read(drillProvider.notifier).selectDrumLoop(loop);
            }
          },
        ),
      ),
    );
  }

  /// 元素切换拍数选择器
  Widget _buildBeatsPerSwitchSelector(DrillState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '元素切换时机',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.drillTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<int>(
            segments: TrainingConstants.availableBeatsPerSwitch.map((beats) {
              return ButtonSegment<int>(
                value: beats,
                label: Text(
                  TrainingConstants.beatsPerSwitchLabels[beats] ?? '$beats 拍',
                  style: AppTextStyles.bodySmall,
                ),
              );
            }).toList(),
            selected: {state.beatsPerSwitch},
            onSelectionChanged: (Set<int> selection) {
              final newBeats = selection.first;
              ref.read(drillProvider.notifier).setBeatsPerSwitch(newBeats);
              // 同时保存到设置
              ref.read(trainingSettingsProvider.notifier).setBeatsPerSwitch(newBeats);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.surface.withOpacity(0.3);
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.textPrimary;
                }
                return AppColors.drillTextSecondary;
              }),
              side: WidgetStateProperty.all(
                BorderSide(color: AppColors.surfaceLight),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 切换播放/暂停
  void _togglePlayPause(DrillState state) {
    final notifier = ref.read(drillProvider.notifier);
    if (state.isPlaying) {
      notifier.pauseDrill();
    } else {
      debugPrint('_togglePlayPause: hasElements=${state.hasElements}, _elements=${_elements?.length}');
      if (state.hasElements) {
        debugPrint('Calling resumeDrill');
        notifier.resumeDrill();
      } else if (_elements != null && _elements!.isNotEmpty) {
        debugPrint('Calling startDrill');
        notifier.startDrill(_elements!);
      }
    }
  }

  /// 显示训练完成界面
  void _showCompleteDialog(BuildContext context, DrillState state) {
    ref.read(drillProvider.notifier).pauseDrill();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              Text(
                '练习完成!',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '已完成 ${widget.elementIds.length} 个元素的练习',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(drillProvider.notifier).stopDrill();
                    Navigator.of(context).pop(); // 关闭对话框
                    // 返回到首页（跳过 review_page）
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('返回首页'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框，继续训练
                  ref.read(drillProvider.notifier).resumeDrill();
                },
                child: const Text('继续训练'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 重新洗牌
  void _reshuffle() {
    if (_elements != null && _elements!.isNotEmpty) {
      ref.read(drillProvider.notifier).startDrill(_elements!);
    }
  }

  /// 确认退出
  void _confirmExit(BuildContext context) {
    _showCompleteDialog(context, ref.read(drillProvider));
  }
}

/// 控制按钮
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLarge;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isLarge = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = isLarge ? 64.0 : 48.0;
    final iconSize = isLarge ? 32.0 : 24.0;

    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isLarge ? AppColors.primary : AppColors.surface.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: AppColors.drillText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.drillTextSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 鼓点显示器
class _BeatIndicator extends StatelessWidget {
  final int currentBeat;
  final bool isPlaying;
  final int beatsPerSwitch;

  const _BeatIndicator({
    required this.currentBeat,
    required this.isPlaying,
    required this.beatsPerSwitch,
  });

  @override
  Widget build(BuildContext context) {
    // 根据拍数调整圆圈大小和间距
    final circleSize = beatsPerSwitch > 8 ? 28.0 : 36.0;
    final horizontalMargin = beatsPerSwitch > 8 ? 3.0 : 4.0;
    final fontSize = beatsPerSwitch > 8 ? 11.0 : null;

    // 如果拍数超过8，分成两排显示
    if (beatsPerSwitch > 8) {
      final firstHalf = beatsPerSwitch ~/ 2;
      final secondHalf = beatsPerSwitch - firstHalf;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(0, firstHalf, circleSize, horizontalMargin, fontSize),
          const SizedBox(height: 8),
          _buildRow(firstHalf, secondHalf, circleSize, horizontalMargin, fontSize),
        ],
      );
    }

    return _buildRow(0, beatsPerSwitch, circleSize, horizontalMargin, fontSize);
  }

  Widget _buildRow(int startIndex, int count, double circleSize, double horizontalMargin, double? fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final index = startIndex + i;
        final isActive = index == currentBeat && isPlaying;
        final isPast = isPlaying && index < currentBeat;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          transform: Matrix4.translationValues(0, isActive ? -8 : 0, 0),
          child: Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primary
                  : isPast
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.surfaceLight.withValues(alpha: 0.3),
              border: Border.all(
                color: isActive
                    ? AppColors.primaryLight
                    : AppColors.surfaceLight.withValues(alpha: 0.5),
                width: isActive ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive
                      ? AppColors.textPrimary
                      : AppColors.drillTextSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
