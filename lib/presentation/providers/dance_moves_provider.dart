import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dance_move.dart';
import '../../data/repositories/dance_move_repository.dart';

/// 动作仓库 Provider
final danceMoveRepositoryProvider = Provider<DanceMoveRepository>((ref) {
  return DanceMoveRepository();
});

/// 所有动作列表 Provider
final allMovesProvider = FutureProvider<List<DanceMove>>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getAllMoves();
});

/// 今日待复习动作 Provider
final dueMovesProvider = FutureProvider<List<DanceMove>>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getDueMoves();
});

/// 待复习动作数量 Provider
final dueCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getDueCount();
});

/// 所有分类 Provider
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getAllCategories();
});

/// 动作管理 Notifier
class DanceMovesNotifier extends StateNotifier<AsyncValue<void>> {
  final DanceMoveRepository _repository;
  final Ref _ref;

  DanceMovesNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// 添加动作
  Future<void> addMove(DanceMove move) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addMove(move);
      _refreshProviders();
    });
  }

  /// 更新动作
  Future<void> updateMove(DanceMove move) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateMove(move);
      _refreshProviders();
    });
  }

  /// 删除动作
  Future<void> deleteMove(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteMove(id);
      _refreshProviders();
    });
  }

  /// 刷新相关 Providers
  void _refreshProviders() {
    _ref.invalidate(allMovesProvider);
    _ref.invalidate(dueMovesProvider);
    _ref.invalidate(dueCountProvider);
    _ref.invalidate(categoriesProvider);
  }
}

/// 动作管理 Provider
final danceMovesNotifierProvider =
    StateNotifierProvider<DanceMovesNotifier, AsyncValue<void>>((ref) {
  return DanceMovesNotifier(ref.watch(danceMoveRepositoryProvider), ref);
});
