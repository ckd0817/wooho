import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_element.dart';
import '../../../domain/services/srs_algorithm_service.dart';
import '../../providers/review_provider.dart';

/// 复习页面
class ReviewPage extends ConsumerStatefulWidget {
  const ReviewPage({super.key});

  @override
  ConsumerState<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends ConsumerState<ReviewPage> {
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;
  bool _hasNoVideo = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewProvider.notifier).loadTrainingElements();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: reviewState.maybeWhen(
          data: (state) => Text(
            '练习 (${state.completedCount}/${state.totalCount})',
          ),
          orElse: () => const Text('练习'),
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

  /// 复习内容
  Widget _buildReviewContent(
    BuildContext context,
    WidgetRef ref,
    ReviewState state,
  ) {
    // 只有当已完成至少一个元素时，才算真正完成练习
    if (state.isComplete && state.completedCount > 0) {
      // 元素练习完成，直接进入串联训练
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startDrill(context, ref);
      });
      // 显示加载中
      return const Center(child: CircularProgressIndicator());
    }

    final currentElement = state.currentElement;
    if (currentElement == null) {
      // 没有可练习的元素
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
              '暂无可练习的元素',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('返回首页'),
            ),
          ],
        ),
      );
    }

    // 加载视频
    _loadVideo(currentElement);

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
          child: _buildVideoPlayer(currentElement),
        ),

        // 元素名称和分类
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                currentElement.name,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                currentElement.category,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),

        // 评分按钮
        _buildFeedbackButtons(context, ref),

        const SizedBox(height: 16),
      ],
    );
  }

  /// 视频播放器
  Widget _buildVideoPlayer(DanceElement element) {
    if (_isVideoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 无视频时显示提示
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
              '此元素暂无视频',
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
  Future<void> _loadVideo(DanceElement element) async {
    // 先释放旧的视频控制器，避免显示上一个元素的视频
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }

    if (!mounted) return;

    // 如果没有视频源，直接返回
    if (element.videoSourceType == VideoSourceType.none) {
      setState(() {
        _hasNoVideo = true;
        _isVideoLoading = false;
      });
      return;
    }

    setState(() => _isVideoLoading = true);

    try {
      switch (element.videoSourceType) {
        case VideoSourceType.localGallery:
          _videoController = VideoPlayerController.file(File(element.videoUri));
          break;
        case VideoSourceType.bundledAsset:
          _videoController = VideoPlayerController.asset(element.videoUri);
          break;
        case VideoSourceType.webUrl:
          _videoController = VideoPlayerController.networkUrl(Uri.parse(element.videoUri));
          break;
        case VideoSourceType.none:
          return;
      }
      await _videoController!.initialize();

      // 设置播放区间
      _videoController!.addListener(() {
        if (_videoController!.value.position.inMilliseconds >= element.trimEnd) {
          _videoController!.seekTo(Duration(milliseconds: element.trimStart));
        }
      });

      // 循环播放
      _videoController!.setLooping(true);
      await _videoController!.seekTo(Duration(milliseconds: element.trimStart));
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
    // 释放当前视频
    await _videoController?.dispose();

    // 重置视频状态
    if (mounted) {
      setState(() {
        _videoController = null;
        _hasNoVideo = false;
        _isVideoLoading = false;
      });
    }

    // 提交评分
    await ref.read(reviewProvider.notifier).submitFeedback(feedback);
  }

  /// 开始串联训练
  void _startDrill(BuildContext context, WidgetRef ref) {
    final completedElements =
        ref.read(reviewProvider.notifier).getCompletedElements();
    final elementIds = completedElements.map((e) => e.id).toList();
    context.push('/drill', extra: elementIds);
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
