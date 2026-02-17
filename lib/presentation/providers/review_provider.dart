import 'package:flutter/foundation.dart';
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
  final List<DanceMove> trainingMoves;
  final int currentIndex;
  final Set<String> completedIds;

  const ReviewState({
    this.trainingMoves = const [],
    this.currentIndex = 0,
    this.completedIds = const {},
  });

  DanceMove? get currentMove =>
      currentIndex < trainingMoves.length ? trainingMoves[currentIndex] : null;

  bool get isComplete => currentIndex >= trainingMoves.length;

  int get completedCount => completedIds.length;

  int get totalCount => trainingMoves.length;

  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  ReviewState copyWith({
    List<DanceMove>? trainingMoves,
    int? currentIndex,
    Set<String>? completedIds,
  }) {
    return ReviewState(
      trainingMoves: trainingMoves ?? this.trainingMoves,
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

  /// 加载训练动作（按优先级排序，选取前 N 个）
  Future<void> loadTrainingMoves({int count = 10}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final moves = await _moveRepository.getTrainingMoves(count: count);
      return ReviewState(trainingMoves: moves);
    });
  }

  /// 提交训练反馈
  Future<void> submitFeedback(FeedbackType feedback) async {
    final currentState = state.value;
    if (currentState == null || currentState.currentMove == null) {
      debugPrint('submitFeedback: state.value=$currentState, currentMove=${currentState?.currentMove}');
      return;
    }

    final move = currentState.currentMove!;
    final previousMastery = move.masteryLevel;
    final newMastery = _srsAlgorithm.calculateNewMastery(previousMastery, feedback);
    final newStatusString = _srsAlgorithm.getMoveStatus(newMastery);
    final newStatus = newStatusString == 'new' ? MoveStatus.new_ :
                      newStatusString == 'learning' ? MoveStatus.learning :
                      MoveStatus.reviewing;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 更新动作
    final updatedMove = move.copyWith(
      status: newStatus,
      masteryLevel: newMastery,
      lastPracticedAt: now,
      updatedAt: now,
    );

    await _moveRepository.updateMove(updatedMove);

    // 记录训练历史
    await _reviewRepository.addRecord(ReviewRecord(
      moveId: move.id,
      feedback: feedback.name,
      reviewedAt: now,
      previousMastery: previousMastery,
      newMastery: newMastery,
    ));

    // 更新状态
    final newCompletedIds = Set<String>.from(currentState.completedIds);
    newCompletedIds.add(move.id);

    state = AsyncValue.data(currentState.copyWith(
      currentIndex: currentState.currentIndex + 1,
      completedIds: newCompletedIds,
    ));

    // 刷新相关 Providers
    _ref.invalidate(allMovesProvider);
    _ref.invalidate(trainingMovesProvider);
    _ref.invalidate(moveCountProvider);
  }

  /// 获取已完成的动作列表 (用于串联训练)
  List<DanceMove> getCompletedMoves() {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.trainingMoves
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
