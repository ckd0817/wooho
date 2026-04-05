import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_routine.dart';
import '../../data/repositories/dance_routine_repository.dart';

/// 舞段仓库 Provider
final danceRoutineRepositoryProvider = Provider<DanceRoutineRepository>((ref) {
  return DanceRoutineRepository();
});

/// 所有舞段 Provider
final allRoutinesProvider = FutureProvider<List<DanceRoutine>>((ref) async {
  final repository = ref.watch(danceRoutineRepositoryProvider);
  return await repository.getAllRoutines();
});

/// 舞段总数 Provider
final routineCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(danceRoutineRepositoryProvider);
  return await repository.getRoutineCount();
});

/// 舞段分类 Provider
final routineCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(danceRoutineRepositoryProvider);
  return await repository.getAllCategories();
});

/// 根据 ID 获取舞段 Provider
final routineByIdProvider = FutureProvider.family<DanceRoutine?, String>((ref, id) async {
  final repository = ref.watch(danceRoutineRepositoryProvider);
  return await repository.getRoutineById(id);
});

/// 训练舞段列表 Provider
final trainingRoutinesProvider = FutureProvider<List<DanceRoutine>>((ref) async {
  final repository = ref.watch(danceRoutineRepositoryProvider);
  return await repository.getTrainingRoutines(count: 10);
});

/// 舞段管理 Notifier
class RoutineNotifier extends StateNotifier<AsyncValue<List<DanceRoutine>>> {
  final DanceRoutineRepository _repository;
  final Ref _ref;

  RoutineNotifier(this._repository, this._ref) : super(const AsyncValue.loading());

  /// 加载所有舞段
  Future<void> loadRoutines() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await _repository.getAllRoutines();
    });
  }

  /// 添加舞段
  Future<void> addRoutine(DanceRoutine routine) async {
    await _repository.addRoutine(routine);
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(routineCountProvider);
    _ref.invalidate(routineCategoriesProvider);
    _ref.invalidate(trainingRoutinesProvider);
    await loadRoutines();
  }

  /// 更新舞段
  Future<void> updateRoutine(DanceRoutine routine) async {
    await _repository.updateRoutine(routine);
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(routineCategoriesProvider);
    _ref.invalidate(trainingRoutinesProvider);
    await loadRoutines();
  }

  /// 删除舞段
  Future<void> deleteRoutine(String id) async {
    await _repository.deleteRoutine(id);
    _ref.invalidate(allRoutinesProvider);
    _ref.invalidate(routineCountProvider);
    _ref.invalidate(routineCategoriesProvider);
    _ref.invalidate(trainingRoutinesProvider);
    _ref.invalidate(routineByIdProvider);
    await loadRoutines();
  }
}

/// 舞段管理 Provider
final routineNotifierProvider =
    StateNotifierProvider<RoutineNotifier, AsyncValue<List<DanceRoutine>>>((ref) {
  return RoutineNotifier(ref.watch(danceRoutineRepositoryProvider), ref);
});
