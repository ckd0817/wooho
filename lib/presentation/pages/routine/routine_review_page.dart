import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_element.dart';
import '../../../data/models/dance_routine.dart';
import '../../../domain/services/srs_algorithm_service.dart';
import '../../providers/routine_review_provider.dart';
import '../../providers/training_settings_provider.dart';

/// 舞段训练页面
class RoutineReviewPage extends ConsumerStatefulWidget {
  const RoutineReviewPage({super.key});

  @override
  ConsumerState<RoutineReviewPage> createState() => _RoutineReviewPageState();
}

class _RoutineReviewPageState extends ConsumerState<RoutineReviewPage> {
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;
  bool _hasNoVideo = false;
  String? _loadedRoutineId; // 记录已加载的舞段 ID

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final settings = ref.read(trainingSettingsProvider);
      ref.read(routineReviewProvider.notifier).loadTrainingRoutines(count: settings.routineCount);
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(routineReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: reviewState.maybeWhen(
          data: (state) => Text(
            '舞段练习 (${state.completedCount}/${state.totalCount})',
          ),
          orElse: () => const Text('舞段练习'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context),
        ),
      ),
      body: reviewState.when(
        data: (state) => _buildReviewContent(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  /// 训练内容
  Widget _buildReviewContent(
    BuildContext context,
    WidgetRef ref,
    RoutineReviewState state,
  ) {
    // 训练完成，显示完成界面（不进入串联训练）
    if (state.isComplete && state.completedCount > 0) {
      return _buildCompleteContent(context, state);
    }

    final currentRoutine = state.currentRoutine;
    if (currentRoutine == null) {
      // 没有可练习的舞段
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
              '暂无可练习的舞段',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('返回舞段库'),
            ),
          ],
        ),
      );
    }

    // 只在舞段变化时才加载视频
    if (_loadedRoutineId != currentRoutine.id) {
      _loadVideo(currentRoutine);
    }

    return Column(
      children: [
        // 进度条
        LinearProgressIndicator(
          value: state.progress,
          backgroundColor: AppColors.surfaceLight,
          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
        ),

        // 视频区域
        Expanded(
          child: _buildVideoPlayer(currentRoutine),
        ),

        // 舞段名称和分类
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                currentRoutine.name,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                currentRoutine.category,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              if (currentRoutine.notes != null && currentRoutine.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  currentRoutine.notes!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        // 评分按钮
        _buildFeedbackButtons(context, ref),

        const SizedBox(height: 16),
      ],
    );
  }

  /// 训练完成界面
  Widget _buildCompleteContent(BuildContext context, RoutineReviewState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            Text(
              '练习完成！',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '本次练习了 ${state.completedCount} 个舞段',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('返回舞段库'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 视频播放器
  Widget _buildVideoPlayer(DanceRoutine currentRoutine) {
    if (_isVideoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasNoVideo) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              '此舞段暂无视频',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              '视频加载中...',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }

  /// 评分按钮
  Widget _buildFeedbackButtons(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _FeedbackButton(
              label: '模糊',
              color: AppColors.feedbackAgain,
              description: '熟练度 -20',
              onPressed: () => _submitFeedback(context, ref, FeedbackType.again),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeedbackButton(
              label: '认识',
              color: AppColors.feedbackHard,
              description: '熟练度 +5',
              onPressed: () => _submitFeedback(context, ref, FeedbackType.hard),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeedbackButton(
              label: '熟练',
              color: AppColors.feedbackEasy,
              description: '熟练度 +15',
              onPressed: () => _submitFeedback(context, ref, FeedbackType.easy),
            ),
          ),
        ],
      ),
    );
  }

  /// 加载视频
  Future<void> _loadVideo(DanceRoutine currentRoutine) async {
    // 如果已经在加载这个舞段，跳过
    if (_loadedRoutineId == currentRoutine.id && _isVideoLoading) return;

    // 标记正在加载这个舞段
    _loadedRoutineId = currentRoutine.id;

    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }

    if (!mounted) return;

    if (currentRoutine.videoSourceType == VideoSourceType.none) {
      setState(() {
        _hasNoVideo = true;
        _isVideoLoading = false;
      });
      return;
    }

    setState(() => _isVideoLoading = true);

    try {
      switch (currentRoutine.videoSourceType) {
        case VideoSourceType.localGallery:
          _videoController = VideoPlayerController.file(File(currentRoutine.videoUri));
          break;
        case VideoSourceType.bundledAsset:
          _videoController = VideoPlayerController.asset(currentRoutine.videoUri);
          break;
        case VideoSourceType.webUrl:
          _videoController = VideoPlayerController.networkUrl(Uri.parse(currentRoutine.videoUri));
          break;
        case VideoSourceType.none:
          return;
      }
      await _videoController!.initialize();

      _videoController!.addListener(() {
        if (_videoController!.value.position.inMilliseconds >= currentRoutine.trimEnd) {
          _videoController!.seekTo(Duration(milliseconds: currentRoutine.trimStart));
        }
      });

      _videoController!.setLooping(true);
      await _videoController!.seekTo(Duration(milliseconds: currentRoutine.trimStart));
      await _videoController!.play();

      if (mounted) {
        setState(() => _isVideoLoading = false);
      }
    } catch (e) {
      debugPrint('视频加载失败: $e');
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
          _hasNoVideo = true;
        });
      }
    }
  }

  /// 提交评分
  Future<void> _submitFeedback(
    BuildContext context,
    WidgetRef ref,
    FeedbackType feedback,
  ) async {
    await _videoController?.dispose();

    if (mounted) {
      setState(() {
        _videoController = null;
        _hasNoVideo = false;
        _isVideoLoading = false;
        _loadedRoutineId = null; // 重置已加载的舞段 ID
      });
    }

    await ref.read(routineReviewProvider.notifier).submitFeedback(feedback);
  }

  /// 确认退出
  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出练习?'),
        content: const Text('当前进度将会丢失'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续练习'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

/// 评分按钮
class _FeedbackButton extends StatelessWidget {
  final String label;
  final Color color;
  final String description;
  final VoidCallback onPressed;

  const _FeedbackButton({
    required this.label,
    required this.color,
    required this.description,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.buttonLarge,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
