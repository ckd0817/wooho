import 'package:shared_preferences/shared_preferences.dart';

/// 首次引导服务
/// 管理用户首次引导状态
class OnboardingService {
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  /// 检查是否已完成引导
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  /// 标记引导已完成
  Future<void> markOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingCompleted, true);
  }

  /// 重置引导状态（用于测试或设置页面）
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingCompleted);
  }
}
