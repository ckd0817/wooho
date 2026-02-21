import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_element.dart';
import '../../data/datasources/local/review_dao.dart';
import '../../data/repositories/dance_element_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/services/srs_algorithm_service.dart';
import 'user_elements_provider.dart';

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
  final List<DanceElement> trainingElements;
  final int currentIndex;
  final Set<String> completedIds;

  const ReviewState({
    this.trainingElements = const [],
    this.currentIndex = 0,
    this.completedIds = const {},
  });

  DanceElement? get currentElement =>
      currentIndex < trainingElements.length ? trainingElements[currentIndex] : null;

  bool get isComplete => currentIndex >= trainingElements.length;

  int get completedCount => completedIds.length;

  int get totalCount => trainingElements.length;

  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  ReviewState copyWith({
    List<DanceElement>? trainingElements,
    int? currentIndex,
    Set<String>? completedIds,
  }) {
    return ReviewState(
      trainingElements: trainingElements ?? this.trainingElements,
      currentIndex: currentIndex ?? this.currentIndex,
      completedIds: completedIds ?? this.completedIds,
    );
  }
}

/// 复习 Notifier
class ReviewNotifier extends StateNotifier<AsyncValue<ReviewState>> {
  final DanceElementRepository _elementRepository;
  final ReviewRepository _reviewRepository;
  final SrsAlgorithmService _srsAlgorithm;
  final Ref _ref;

  ReviewNotifier(
    this._elementRepository,
    this._reviewRepository,
    this._srsAlgorithm,
    this._ref,
  ) : super(const AsyncValue.data(ReviewState()));

  /// 加载训练元素（按优先级排序，选取前 N 个）
  Future<void> loadTrainingElements({int count = 10}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final elements = await _elementRepository.getTrainingElements(count: count);
      return ReviewState(trainingElements: elements);
    });
  }

  /// 提交训练反馈
  Future<void> submitFeedback(FeedbackType feedback) async {
    final currentState = state.value;
    if (currentState == null || currentState.currentElement == null) {
      debugPrint('submitFeedback: state.value=$currentState, currentElement=${currentState?.currentElement}');
      return;
    }

    final element = currentState.currentElement!;
    final previousMastery = element.masteryLevel;
    final newMastery = _srsAlgorithm.calculateNewMastery(previousMastery, feedback);
    final newStatusString = _srsAlgorithm.getElementStatus(newMastery);
    final newStatus = newStatusString == 'new' ? ElementStatus.new_ :
                      newStatusString == 'learning' ? ElementStatus.learning :
                      ElementStatus.reviewing;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 更新元素
    final updatedElement = element.copyWith(
      status: newStatus,
      masteryLevel: newMastery,
      lastPracticedAt: now,
      updatedAt: now,
    );

    await _elementRepository.updateElement(updatedElement);

    // 记录训练历史
    await _reviewRepository.addRecord(ReviewRecord(
      elementId: element.id,
      feedback: feedback.name,
      reviewedAt: now,
      previousMastery: previousMastery,
      newMastery: newMastery,
    ));

    // 更新状态
    final newCompletedIds = Set<String>.from(currentState.completedIds);
    newCompletedIds.add(element.id);

    state = AsyncValue.data(currentState.copyWith(
      currentIndex: currentState.currentIndex + 1,
      completedIds: newCompletedIds,
    ));

    // 刷新相关 Providers
    _ref.invalidate(allElementsProvider);
    _ref.invalidate(trainingElementsProvider);
    _ref.invalidate(elementCountProvider);
  }

  /// 获取已完成的元素列表 (用于串联训练)
  List<DanceElement> getCompletedElements() {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.trainingElements
        .where((element) => currentState.completedIds.contains(element.id))
        .toList();
  }
}

/// 复习 Provider
final reviewProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<ReviewState>>((ref) {
  return ReviewNotifier(
    ref.watch(danceElementRepositoryProvider),
    ref.watch(reviewRepositoryProvider),
    ref.watch(srsAlgorithmProvider),
    ref,
  );
});
