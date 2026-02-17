import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/dance_move.dart';
import '../../../data/repositories/dance_move_repository.dart';
import '../../providers/drill_provider.dart';

/// 串联训练页面
class DrillPage extends ConsumerStatefulWidget {
  final List<String> moveIds;

  const DrillPage({super.key, required this.moveIds});

  @override
  ConsumerState<DrillPage> createState() => _DrillPageState();
}

class _DrillPageState extends ConsumerState<DrillPage> {
  List<DanceMove>? _moves;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoves();
  }

  Future<void> _loadMoves() async {
    if (widget.moveIds.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final repository = DanceMoveRepository();
    final moves = <DanceMove>[];

    for (final id in widget.moveIds) {
      final move = await repository.getMoveById(id);
      if (move != null) {
        moves.add(move);
      }
    }

    setState(() {
      _moves = moves;
      _isLoading = false;
    });

    // 自动开始训练
    if (moves.isNotEmpty) {
      Future.microtask(() {
        ref.read(drillProvider.notifier).startDrill(moves);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final drillState = ref.watch(drillProvider);

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

    if (_moves == null || _moves!.isEmpty) {
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
            '没有可训练的动作',
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
              child: _buildMainContent(drillState),
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
  Widget _buildMainContent(DrillState state) {
    final currentMove = state.currentMove;
    final nextMove = state.nextMove;

    return GestureDetector(
      onTap: () => _togglePlayPause(state),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 当前动作名称 (大字)
            if (currentMove != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  currentMove.name,
                  style: AppTextStyles.drillMoveName.copyWith(
                    color: AppColors.drillText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 32),

            // 下一个动作预告
            if (nextMove != null && state.isPlaying)
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
                    nextMove.name,
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
                      '点击屏幕${state.hasMoves ? "继续" : "开始"}',
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
              // 停止按钮
              _ControlButton(
                icon: Icons.stop,
                label: '停止',
                onPressed: () => _stopDrill(context),
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

  /// 切换播放/暂停
  void _togglePlayPause(DrillState state) {
    final notifier = ref.read(drillProvider.notifier);
    if (state.isPlaying) {
      notifier.pauseDrill();
    } else {
      if (state.hasMoves) {
        notifier.resumeDrill();
      } else if (_moves != null && _moves!.isNotEmpty) {
        notifier.startDrill(_moves!);
      }
    }
  }

  /// 停止训练
  void _stopDrill(BuildContext context) {
    ref.read(drillProvider.notifier).stopDrill();
    context.pop();
  }

  /// 重新洗牌
  void _reshuffle() {
    if (_moves != null && _moves!.isNotEmpty) {
      ref.read(drillProvider.notifier).startDrill(_moves!);
    }
  }

  /// 确认退出
  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('结束训练?'),
        content: const Text('确定要结束本次串联训练吗?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续训练'),
          ),
          TextButton(
            onPressed: () {
              ref.read(drillProvider.notifier).stopDrill();
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('结束'),
          ),
        ],
      ),
    );
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
