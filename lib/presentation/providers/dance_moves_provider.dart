import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/dance_move.dart';
import '../../data/repositories/dance_move_repository.dart';
import '../../domain/services/srs_algorithm_service.dart';

/// 动作仓库 Provider
final danceMoveRepositoryProvider = Provider<DanceMoveRepository>((ref) {
  return DanceMoveRepository();
});

/// 所有动作列表 Provider
final allMovesProvider = FutureProvider<List<DanceMove>>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getAllMoves();
});

/// 训练动作列表 Provider（按优先级排序，选取前 N 个）
final trainingMovesProvider = FutureProvider<List<DanceMove>>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getTrainingMoves(count: 10);
});

/// 动作总数 Provider
final moveCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  return await repository.getMoveCount();
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

  /// 判断动作是否已添加到个人库
  Future<bool> isMoveAdded(String categoryName, String elementName) async {
    final allMoves = await _repository.getAllMoves();
    return allMoves.any((m) =>
      m.category == categoryName && m.name == elementName
    );
  }

  /// 从官方动作库快速添加到个人库
  Future<bool> quickAddFromOfficial(
    String categoryName,
    String elementName,
    MasteryLevel masteryLevel,
  ) async {
    // 先检查是否已添加
    final isAdded = await isMoveAdded(categoryName, elementName);
    if (isAdded) {
      return false;
    }

    final srsAlgorithm = SrsAlgorithmService();
    final initialMastery = srsAlgorithm.getInitialMasteryLevel(masteryLevel);
    final now = DateTime.now().millisecondsSinceEpoch;

    final move = DanceMove(
      id: const Uuid().v4(),
      name: elementName,
      category: categoryName,
      videoSourceType: VideoSourceType.none,
      videoUri: '',
      trimStart: 0,
      trimEnd: 0,
      status: MoveStatus.new_,
      masteryLevel: initialMastery,
      lastPracticedAt: now, // 使用当前时间作为初始值
      createdAt: now,
    );

    await _repository.addMove(move);
    _refreshProviders();
    return true;
  }

  /// 记录训练反馈
  Future<void> recordFeedback(String moveId, FeedbackType feedback) async {
    final move = await _repository.getMoveById(moveId);
    if (move == null) return;

    final srsAlgorithm = SrsAlgorithmService();
    final newMastery = srsAlgorithm.calculateNewMastery(move.masteryLevel, feedback);
    final newStatusString = srsAlgorithm.getMoveStatus(newMastery);
    final newStatus = newStatusString == 'new' ? MoveStatus.new_ :
                      newStatusString == 'learning' ? MoveStatus.learning :
                      MoveStatus.reviewing;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updatedMove = move.copyWith(
      masteryLevel: newMastery,
      status: newStatus,
      lastPracticedAt: now,
      updatedAt: now,
    );

    await _repository.updateMove(updatedMove);
    _refreshProviders();
  }

  /// 刷新相关 Providers
  void _refreshProviders() {
    _ref.invalidate(allMovesProvider);
    _ref.invalidate(trainingMovesProvider);
    _ref.invalidate(moveCountProvider);
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(addedMovesSetProvider);
  }
}

/// 动作管理 Provider
final danceMovesNotifierProvider =
    StateNotifierProvider<DanceMovesNotifier, AsyncValue<void>>((ref) {
  return DanceMovesNotifier(ref.watch(danceMoveRepositoryProvider), ref);
});

/// 检查动作是否已添加的 Provider（同步版本）
/// 返回一个 Set，包含所有已添加的动作 (格式: "category|name")
final addedMovesSetProvider = FutureProvider<Set<String>>((ref) async {
  final repository = ref.watch(danceMoveRepositoryProvider);
  final moves = await repository.getAllMoves();
  return moves.map((m) => '${m.category}|${m.name}').toSet();
});
