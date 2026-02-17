import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/dance_move.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reviewProvider.notifier).loadDueMoves();
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
            '复习 (${state.completedCount}/${state.totalCount})',
          ),
          orElse: () => const Text('复习'),
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
    if (state.isComplete) {
      return _buildCompleteScreen(context, ref, state);
    }

    final currentMove = state.currentMove;
    if (currentMove == null) {
      return _buildCompleteScreen(context, ref, state);
    }

    // 加载视频
    _loadVideo(currentMove);

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
          child: _buildVideoPlayer(currentMove),
        ),

        // 动作名称和分类
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                currentMove.name,
                style: AppTextStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                currentMove.category,
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
  Widget _buildVideoPlayer(DanceMove move) {
    if (_isVideoLoading) {
      return const Center(child: CircularProgressIndicator());
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
              description: '1天后复习',
              onPressed: () => _submitFeedback(context, ref, FeedbackType.again),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeedbackButton(
              label: '认识',
              color: AppColors.feedbackHard,
              description: '1.2倍间隔',
              onPressed: () => _submitFeedback(context, ref, FeedbackType.hard),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FeedbackButton(
              label: '熟练',
              color: AppColors.feedbackEasy,
              description: '2.5倍间隔',
              onPressed: () => _submitFeedback(context, ref, FeedbackType.easy),
            ),
          ),
        ],
      ),
    );
  }

  /// 完成页面
  Widget _buildCompleteScreen(
    BuildContext context,
    WidgetRef ref,
    ReviewState state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            Text(
              '复习完成!',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '已完成 ${state.completedCount} 个动作的复习',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state.completedCount > 0
                    ? () => _startDrill(context, ref)
                    : null,
                child: const Text('开始串联训练'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }

  /// 加载视频
  Future<void> _loadVideo(DanceMove move) async {
    if (_videoController != null) return;

    setState(() => _isVideoLoading = true);

    try {
      _videoController = VideoPlayerController.asset(move.videoUri);
      await _videoController!.initialize();

      // 设置播放区间
      _videoController!.addListener(() {
        if (_videoController!.value.position.inMilliseconds >= move.trimEnd) {
          _videoController!.seekTo(Duration(milliseconds: move.trimStart));
        }
      });

      // 循环播放
      _videoController!.setLooping(true);
      await _videoController!.seekTo(Duration(milliseconds: move.trimStart));
      await _videoController!.play();

      setState(() => _isVideoLoading = false);
    } catch (e) {
      setState(() => _isVideoLoading = false);
      // 视频加载失败，显示错误
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
    _videoController = null;

    // 提交评分
    await ref.read(reviewProvider.notifier).submitFeedback(feedback);
  }

  /// 开始串联训练
  void _startDrill(BuildContext context, WidgetRef ref) {
    final completedMoves =
        ref.read(reviewProvider.notifier).getCompletedMoves();
    final moveIds = completedMoves.map((m) => m.id).toList();
    context.push('/drill', extra: moveIds);
  }

  /// 确认退出
  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出复习?'),
        content: const Text('当前进度将会丢失'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('继续复习'),
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
