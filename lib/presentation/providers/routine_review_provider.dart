import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_routine.dart';
import '../../data/models/routine_record.dart';
import '../../data/repositories/dance_routine_repository.dart';
import '../../data/repositories/routine_record_repository.dart';
import '../../domain/services/srs_algorithm_service.dart';
import 'routine_provider.dart';
import 'training_settings_provider.dart';

/// 舞段训练记录仓库 Provider
final routineRecordRepositoryProvider = Provider<RoutineRecordRepository>((ref) {
  return RoutineRecordRepository();
});

/// 舞段训练状态
class RoutineReviewState {
  final List<DanceRoutine> trainingRoutines;
  final int currentIndex;
  final Set<String> completedIds;

  const RoutineReviewState({
    this.trainingRoutines = const [],
    this.currentIndex = 0,
    this.completedIds = const {},
  });

  DanceRoutine? get currentRoutine =>
      currentIndex < trainingRoutines.length ? trainingRoutines[currentIndex] : null;

  bool get isComplete => currentIndex >= trainingRoutines.length;

  int get completedCount => completedIds.length;

  int get totalCount => trainingRoutines.length;

  double get progress =>
      totalCount > 0 ? completedCount / totalCount : 0.0;

  RoutineReviewState copyWith({
    List<DanceRoutine>? trainingRoutines,
    int? currentIndex,
    Set<String>? completedIds,
  }) {
    return RoutineReviewState(
      trainingRoutines: trainingRoutines ?? this.trainingRoutines,
      currentIndex: currentIndex ?? this.currentIndex,
      completedIds: completedIds ?? this.completedIds,
    );
  }
}

/// 舞段训练 Notifier
class RoutineReviewNotifier extends StateNotifier<AsyncValue<RoutineReviewState>> {
  final DanceRoutineRepository _routineRepository;
  final RoutineRecordRepository _recordRepository;
  final SrsAlgorithmService _srsAlgorithm;
  final Ref _ref;

  RoutineReviewNotifier(
    this._routineRepository,
    this._recordRepository,
    this._srsAlgorithm,
    this._ref,
  ) : super(const AsyncValue.data(RoutineReviewState()));

  /// 加载训练舞段（支持自定义顺序）
  Future<void> loadTrainingRoutines({
    int count = 10,
    List<String>? customOrder,
  }) async {
    // 先重置为初始状态，清除旧的训练数据
    state = const AsyncValue.data(RoutineReviewState());
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      List<DanceRoutine> routines;

      if (customOrder != null && customOrder.isNotEmpty) {
        // 按自定义顺序获取舞段
        final allRoutines = await _routineRepository.getAllRoutines();
        final routineMap = {for (var r in allRoutines) r.id: r};

        // 先按自定义顺序添加
        final orderedRoutines = <DanceRoutine>[];
        final addedIds = <String>{};
        for (final id in customOrder) {
          final routine = routineMap[id];
          if (routine != null) {
            orderedRoutines.add(routine);
            addedIds.add(id);
          }
        }
        // 补充剩余按优先级排序的舞段
        final remaining = allRoutines
            .where((r) => !addedIds.contains(r.id))
            .toList();
        orderedRoutines.addAll(remaining);

        routines = orderedRoutines.take(count).toList();

        // 自定义顺序只对本次训练生效，使用后立即清除
        _ref.read(trainingSettingsProvider.notifier).setCustomRoutineOrder([]);
      } else {
        // 按优先级排序
        routines = await _routineRepository.getTrainingRoutines(count: count);
      }

      return RoutineReviewState(trainingRoutines: routines);
    });
  }

  /// 提交训练反馈
  Future<void> submitFeedback(FeedbackType feedback) async {
    final currentState = state.value;
    if (currentState == null || currentState.currentRoutine == null) {
      debugPrint('submitFeedback: state.value=$currentState, currentRoutine=${currentState?.currentRoutine}');
      return;
    }

    final routine = currentState.currentRoutine!;
    final previousMastery = routine.masteryLevel;
    final newMastery = _srsAlgorithm.calculateNewMastery(previousMastery, feedback);
    final newStatusString = _srsAlgorithm.getElementStatus(newMastery);
    final newStatus = newStatusString == 'new' ? RoutineStatus.new_ :
                      newStatusString == 'learning' ? RoutineStatus.learning :
                      RoutineStatus.reviewing;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 更新舞段
    final updatedRoutine = routine.copyWith(
      status: newStatus,
      masteryLevel: newMastery,
      lastPracticedAt: now,
      updatedAt: now,
    );

    await _routineRepository.updateRoutine(updatedRoutine);

    // 记录训练历史
    await _recordRepository.addRecord(RoutineRecord(
      routineId: routine.id,
      feedback: feedback.name,
      reviewedAt: now,
      previousMastery: previousMastery,
      newMastery: newMastery,
    ));

    // 更新状态
    final newCompletedIds = Set<String>.from(currentState.completedIds);
    newCompletedIds.add(routine.id);

    state = AsyncValue.data(currentState.copyWith(
      currentIndex: currentState.currentIndex + 1,
      completedIds: newCompletedIds,
    ));

    // 刷新相关 Providers
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(trainingRoutinesProvider);
    _ref.invalidate(routineCountProvider);
  }
}

/// 舞段训练 Provider
final routineReviewProvider =
    StateNotifierProvider<RoutineReviewNotifier, AsyncValue<RoutineReviewState>>((ref) {
  return RoutineReviewNotifier(
    ref.watch(danceRoutineRepositoryProvider),
    ref.watch(routineRecordRepositoryProvider),
    ref.watch(srsAlgorithmProvider),
    ref,
  );
});

/// SRS 算法服务 Provider（复用）
final srsAlgorithmProvider = Provider<SrsAlgorithmService>((ref) {
  return SrsAlgorithmService();
});
