import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_move.dart';
import '../../data/datasources/local/review_dao.dart';
import '../../data/repositories/dance_move_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/services/srs_algorithm_service.dart';
import 'dance_moves_provider.dart';

/// 复习仓库 Provider
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository();
});

/// SRS 算法服务 Provider
final srsAlgorithmProvider = Provider<SrsAlgorithmService>((ref) {
  return SrsAlgorithmService();
});

/// 复习状态
class ReviewState {
  final List<DanceMove> dueMoves;
  final int currentIndex;
  final Set<String> completedIds;

  const ReviewState({
    this.dueMoves = const [],
    this.currentIndex = 0,
    this.completedIds = const {},
  });

  DanceMove? get currentMove =>
      currentIndex < dueMoves.length ? dueMoves[currentIndex] : null;

  bool get isComplete => currentIndex >= dueMoves.length;

  int get completedCount => completedIds.length;

  int get totalCount => dueMoves.length;

  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  ReviewState copyWith({
    List<DanceMove>? dueMoves,
    int? currentIndex,
    Set<String>? completedIds,
  }) {
    return ReviewState(
      dueMoves: dueMoves ?? this.dueMoves,
      currentIndex: currentIndex ?? this.currentIndex,
      completedIds: completedIds ?? this.completedIds,
    );
  }
}

/// 复习 Notifier
class ReviewNotifier extends StateNotifier<AsyncValue<ReviewState>> {
  final DanceMoveRepository _moveRepository;
  final ReviewRepository _reviewRepository;
  final SrsAlgorithmService _srsAlgorithm;
  final Ref _ref;

  ReviewNotifier(
    this._moveRepository,
    this._reviewRepository,
    this._srsAlgorithm,
    this._ref,
  ) : super(const AsyncValue.data(ReviewState()));

  /// 加载今日待复习动作
  Future<void> loadDueMoves() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final moves = await _moveRepository.getDueMoves();
      return ReviewState(dueMoves: moves);
    });
  }

  /// 提交复习评分
  Future<void> submitFeedback(FeedbackType feedback) async {
    final currentState = state.value;
    if (currentState == null || currentState.currentMove == null) return;

    final move = currentState.currentMove!;
    final previousInterval = move.interval;
    final newInterval = _srsAlgorithm.calculateNewInterval(
      previousInterval,
      feedback,
    );
    final nextReviewDate = _srsAlgorithm.calculateNextReviewDate(newInterval);

    // 更新动作
    final updatedMove = DanceMove(
      id: move.id,
      name: move.name,
      category: move.category,
      videoSourceType: move.videoSourceType,
      videoUri: move.videoUri,
      trimStart: move.trimStart,
      trimEnd: move.trimEnd,
      status: _determineStatus(newInterval),
      interval: newInterval,
      nextReviewDate: nextReviewDate.millisecondsSinceEpoch,
      masteryLevel: _calculateMasteryLevel(newInterval),
      createdAt: move.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _moveRepository.updateMove(updatedMove);

    // 记录复习历史
    await _reviewRepository.addRecord(ReviewRecord(
      moveId: move.id,
      feedback: feedback.name,
      reviewedAt: DateTime.now().millisecondsSinceEpoch,
      previousInterval: previousInterval,
      newInterval: newInterval,
    ));

    // 更新状态
    final newCompletedIds = Set<String>.from(currentState.completedIds);
    newCompletedIds.add(move.id);

    state = AsyncValue.data(currentState.copyWith(
      currentIndex: currentState.currentIndex + 1,
      completedIds: newCompletedIds,
    ));

    // 刷新相关 Providers
    _ref.invalidate(dueMovesProvider);
    _ref.invalidate(dueCountProvider);
  }

  /// 根据间隔确定状态
  MoveStatus _determineStatus(int interval) {
    if (interval <= 1) {
      return MoveStatus.new_;
    } else if (interval <= 7) {
      return MoveStatus.learning;
    } else {
      return MoveStatus.reviewing;
    }
  }

  /// 计算熟练度等级 (0-100)
  int _calculateMasteryLevel(int interval) {
    // 1天 = 0, 7天 = 30, 30天 = 60, 90天+ = 100
    if (interval <= 1) return 0;
    if (interval <= 3) return 10;
    if (interval <= 7) return 30;
    if (interval <= 14) return 45;
    if (interval <= 30) return 60;
    if (interval <= 60) return 75;
    if (interval <= 90) return 90;
    return 100;
  }

  /// 获取已完成的动作列表 (用于串联训练)
  List<DanceMove> getCompletedMoves() {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.dueMoves
        .where((move) => currentState.completedIds.contains(move.id))
        .toList();
  }
}

/// 复习 Provider
final reviewProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<ReviewState>>((ref) {
  return ReviewNotifier(
    ref.watch(danceMoveRepositoryProvider),
    ref.watch(reviewRepositoryProvider),
    ref.watch(srsAlgorithmProvider),
    ref,
  );
});
