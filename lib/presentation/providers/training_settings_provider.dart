import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/training_constants.dart';

/// 训练设置状态
class TrainingSettings {
  final int elementCount;
  final int routineCount;
  final List<String> customElementOrder;
  final List<String> customRoutineOrder;
  final int beatsPerSwitch;

  const TrainingSettings({
    this.elementCount = TrainingConstants.defaultElementCount,
    this.routineCount = TrainingConstants.defaultRoutineCount,
    this.customElementOrder = const [],
    this.customRoutineOrder = const [],
    this.beatsPerSwitch = TrainingConstants.defaultBeatsPerSwitch,
  });

  TrainingSettings copyWith({
    int? elementCount,
    int? routineCount,
    List<String>? customElementOrder,
    List<String>? customRoutineOrder,
    int? beatsPerSwitch,
  }) {
    return TrainingSettings(
      elementCount: elementCount ?? this.elementCount,
      routineCount: routineCount ?? this.routineCount,
      customElementOrder: customElementOrder ?? this.customElementOrder,
      customRoutineOrder: customRoutineOrder ?? this.customRoutineOrder,
      beatsPerSwitch: beatsPerSwitch ?? this.beatsPerSwitch,
    );
  }
}

/// 训练设置 Notifier
class TrainingSettingsNotifier extends StateNotifier<TrainingSettings> {
  TrainingSettingsNotifier() : super(const TrainingSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final elementCount = prefs.getInt(TrainingConstants.keyElementCount) ??
        TrainingConstants.defaultElementCount;
    final routineCount = prefs.getInt(TrainingConstants.keyRoutineCount) ??
        TrainingConstants.defaultRoutineCount;
    final customElementOrderJson =
        prefs.getString(TrainingConstants.keyCustomElementOrder);
    final customRoutineOrderJson =
        prefs.getString(TrainingConstants.keyCustomRoutineOrder);
    final beatsPerSwitch = prefs.getInt(TrainingConstants.keyBeatsPerSwitch) ??
        TrainingConstants.defaultBeatsPerSwitch;

    List<String> customElementOrder = [];
    List<String> customRoutineOrder = [];

    if (customElementOrderJson != null) {
      customElementOrder =
          List<String>.from(json.decode(customElementOrderJson));
    }
    if (customRoutineOrderJson != null) {
      customRoutineOrder =
          List<String>.from(json.decode(customRoutineOrderJson));
    }

    state = TrainingSettings(
      elementCount: elementCount,
      routineCount: routineCount,
      customElementOrder: customElementOrder,
      customRoutineOrder: customRoutineOrder,
      beatsPerSwitch: beatsPerSwitch,
    );
  }

  /// 设置元素训练数量
  Future<void> setElementCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(TrainingConstants.keyElementCount, count);
    state = state.copyWith(elementCount: count);
  }

  /// 设置舞段训练数量
  Future<void> setRoutineCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(TrainingConstants.keyRoutineCount, count);
    state = state.copyWith(routineCount: count);
  }

  /// 设置自定义元素顺序
  Future<void> setCustomElementOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        TrainingConstants.keyCustomElementOrder, json.encode(order));
    state = state.copyWith(customElementOrder: order);
  }

  /// 设置自定义舞段顺序
  Future<void> setCustomRoutineOrder(List<String> order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        TrainingConstants.keyCustomRoutineOrder, json.encode(order));
    state = state.copyWith(customRoutineOrder: order);
  }

  /// 设置元素切换拍数
  Future<void> setBeatsPerSwitch(int beats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(TrainingConstants.keyBeatsPerSwitch, beats);
    state = state.copyWith(beatsPerSwitch: beats);
  }

  /// 重置为默认设置
  Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(TrainingConstants.keyElementCount);
    await prefs.remove(TrainingConstants.keyRoutineCount);
    await prefs.remove(TrainingConstants.keyCustomElementOrder);
    await prefs.remove(TrainingConstants.keyCustomRoutineOrder);
    await prefs.remove(TrainingConstants.keyBeatsPerSwitch);
    state = const TrainingSettings();
  }
}

/// 训练设置 Provider
final trainingSettingsProvider =
    StateNotifierProvider<TrainingSettingsNotifier, TrainingSettings>(
  (ref) => TrainingSettingsNotifier(),
);
