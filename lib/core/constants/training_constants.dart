/// 训练相关常量
class TrainingConstants {
  TrainingConstants._();

  // ============ 默认训练数量 ============
  /// 默认每次训练元素数量
  static const int defaultElementCount = 5;

  /// 默认每次训练舞段数量
  static const int defaultRoutineCount = 2;

  /// 最小训练数量
  static const int minTrainingCount = 1;

  /// 最大训练数量
  static const int maxTrainingCount = 20;

  // ============ 元素切换拍数 ============
  /// 默认每次元素切换拍数
  static const int defaultBeatsPerSwitch = 8;

  /// 可选的元素切换拍数列表
  static const List<int> availableBeatsPerSwitch = [2, 4, 8, 16];

  /// 元素切换拍数选项的显示名称
  static const Map<int, String> beatsPerSwitchLabels = {
    2: '2拍',
    4: '4拍',
    8: '8拍',
    16: '16拍',
  };

  // ============ SharedPreferences 键名 ============
  /// 每次训练元素数量的存储键
  static const String keyElementCount = 'training_element_count';

  /// 每次训练舞段数量的存储键
  static const String keyRoutineCount = 'training_routine_count';

  /// 自定义元素顺序的存储键
  static const String keyCustomElementOrder = 'custom_element_order';

  /// 自定义舞段顺序的存储键
  static const String keyCustomRoutineOrder = 'custom_routine_order';

  /// 元素切换拍数的存储键
  static const String keyBeatsPerSwitch = 'beats_per_switch';
}
