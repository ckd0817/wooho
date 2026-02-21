import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/onboarding_service.dart';
import '../../domain/services/srs_algorithm_service.dart';
import 'dance_elements_provider.dart';
import 'user_elements_provider.dart';

/// OnboardingService Provider
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

/// 是否需要显示引导
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(onboardingServiceProvider);
  final isCompleted = await service.isOnboardingCompleted();
  return !isCompleted;
});

/// 选中的舞种 ID 列表
final selectedStylesProvider = StateProvider<Set<String>>((ref) => {});

/// 引导状态 Notifier
class OnboardingNotifier extends StateNotifier<AsyncValue<void>> {
  final OnboardingService _service;
  final DanceElementsNotifier _elementsNotifier;
  final Ref _ref;

  OnboardingNotifier(this._service, this._elementsNotifier, this._ref)
      : super(const AsyncValue.data(null));

  /// 批量添加选中舞种的所有元素
  Future<int> addSelectedElements(Set<String> selectedCategoryIds) async {
    final library = await _ref.read(presetElementsLibraryProvider.future);
    int addedCount = 0;

    for (final categoryId in selectedCategoryIds) {
      final category = library.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => throw Exception('Category not found: $categoryId'),
      );

      for (final element in category.elements) {
        final success = await _elementsNotifier.quickAddFromOfficial(
          category.name,
          element.name,
          MasteryLevel.new_, // 初始熟练度为 0
        );
        if (success) addedCount++;
      }
    }

    return addedCount;
  }

  /// 完成引导流程
  Future<void> completeOnboarding() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.markOnboardingCompleted();
    });
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<void>>((ref) {
  return OnboardingNotifier(
    ref.watch(onboardingServiceProvider),
    ref.watch(danceElementsNotifierProvider.notifier),
    ref,
  );
});
