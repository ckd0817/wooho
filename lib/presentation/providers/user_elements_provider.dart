import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/dance_element.dart';
import '../../data/repositories/dance_element_repository.dart';
import '../../domain/services/srs_algorithm_service.dart';

/// 元素仓库 Provider
final danceElementRepositoryProvider = Provider<DanceElementRepository>((ref) {
  return DanceElementRepository();
});

/// 所有元素列表 Provider
final allElementsProvider = FutureProvider<List<DanceElement>>((ref) async {
  final repository = ref.watch(danceElementRepositoryProvider);
  return await repository.getAllElements();
});

/// 训练元素列表 Provider（按优先级排序，选取前 N 个）
final trainingElementsProvider = FutureProvider<List<DanceElement>>((ref) async {
  final repository = ref.watch(danceElementRepositoryProvider);
  return await repository.getTrainingElements(count: 10);
});

/// 元素总数 Provider
final elementCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(danceElementRepositoryProvider);
  return await repository.getElementCount();
});

/// 所有分类 Provider
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(danceElementRepositoryProvider);
  return await repository.getAllCategories();
});

/// 元素管理 Notifier
class DanceElementsNotifier extends StateNotifier<AsyncValue<void>> {
  final DanceElementRepository _repository;
  final Ref _ref;

  DanceElementsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  /// 添加元素
  Future<void> addElement(DanceElement element) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.addElement(element);
      _refreshProviders();
    });
  }

  /// 更新元素
  Future<void> updateElement(DanceElement element) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateElement(element);
      _refreshProviders();
    });
  }

  /// 删除元素
  Future<void> deleteElement(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteElement(id);
      _refreshProviders();
    });
  }

  /// 判断元素是否已添加到个人库
  Future<bool> isElementAdded(String categoryName, String elementName) async {
    final allElements = await _repository.getAllElements();
    return allElements.any((e) =>
      e.category == categoryName && e.name == elementName
    );
  }

  /// 从官方元素库快速添加到个人库
  Future<bool> quickAddFromOfficial(
    String categoryName,
    String elementName,
    MasteryLevel masteryLevel,
  ) async {
    // 先检查是否已添加
    final isAdded = await isElementAdded(categoryName, elementName);
    if (isAdded) {
      return false;
    }

    final srsAlgorithm = SrsAlgorithmService();
    final initialMastery = srsAlgorithm.getInitialMasteryLevel(masteryLevel);
    final now = DateTime.now().millisecondsSinceEpoch;

    final element = DanceElement(
      id: const Uuid().v4(),
      name: elementName,
      category: categoryName,
      videoSourceType: VideoSourceType.none,
      videoUri: '',
      trimStart: 0,
      trimEnd: 0,
      status: ElementStatus.new_,
      masteryLevel: initialMastery,
      lastPracticedAt: now, // 使用当前时间作为初始值
      createdAt: now,
    );

    await _repository.addElement(element);
    _refreshProviders();
    return true;
  }

  /// 记录训练反馈
  Future<void> recordFeedback(String elementId, FeedbackType feedback) async {
    final element = await _repository.getElementById(elementId);
    if (element == null) return;

    final srsAlgorithm = SrsAlgorithmService();
    final newMastery = srsAlgorithm.calculateNewMastery(element.masteryLevel, feedback);
    final newStatusString = srsAlgorithm.getElementStatus(newMastery);
    final newStatus = newStatusString == 'new' ? ElementStatus.new_ :
                      newStatusString == 'learning' ? ElementStatus.learning :
                      ElementStatus.reviewing;
    final now = DateTime.now().millisecondsSinceEpoch;

    final updatedElement = element.copyWith(
      masteryLevel: newMastery,
      status: newStatus,
      lastPracticedAt: now,
      updatedAt: now,
    );

    await _repository.updateElement(updatedElement);
    _refreshProviders();
  }

  /// 刷新相关 Providers
  void _refreshProviders() {
    _ref.invalidate(allElementsProvider);
    _ref.invalidate(trainingElementsProvider);
    _ref.invalidate(elementCountProvider);
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(addedElementsSetProvider);
  }
}

/// 元素管理 Provider
final danceElementsNotifierProvider =
    StateNotifierProvider<DanceElementsNotifier, AsyncValue<void>>((ref) {
  return DanceElementsNotifier(ref.watch(danceElementRepositoryProvider), ref);
});

/// 检查元素是否已添加的 Provider（同步版本）
/// 返回一个 Set，包含所有已添加的元素 (格式: "category|name")
final addedElementsSetProvider = FutureProvider<Set<String>>((ref) async {
  final repository = ref.watch(danceElementRepositoryProvider);
  final elements = await repository.getAllElements();
  return elements.map((e) => '${e.category}|${e.name}').toSet();
});
