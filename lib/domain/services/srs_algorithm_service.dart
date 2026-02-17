import 'dart:math';

/// 用户反馈类型
enum FeedbackType {
  /// 模糊 - 熟练度降低 20
  again,
  /// 认识 - 熟练度增加 5
  hard,
  /// 熟练 - 熟练度增加 15
  easy,
}

/// 初始熟练度等级
enum MasteryLevel {
  /// 新动作 - 熟练度 0
  new_,
  /// 学习中 - 熟练度 30
  learning,
  /// 已掌握 - 熟练度 70
  mastered,
}

/// SRS 训练算法服务
/// 基于遗忘曲线和熟练度的按需训练模式
class SrsAlgorithmService {
  // 熟练度变化常量
  static const int _againMasteryChange = -20;
  static const int _hardMasteryChange = 5;
  static const int _easyMasteryChange = 15;

  // 熟练度范围
  static const int minMastery = 0;
  static const int maxMastery = 100;

  /// 根据用户反馈计算新的熟练度
  int calculateNewMastery(int currentMastery, FeedbackType feedback) {
    int change;
    switch (feedback) {
      case FeedbackType.again:
        change = _againMasteryChange;
        break;
      case FeedbackType.hard:
        change = _hardMasteryChange;
        break;
      case FeedbackType.easy:
        change = _easyMasteryChange;
        break;
    }
    return (currentMastery + change).clamp(minMastery, maxMastery);
  }

  /// 根据初始熟练度等级获取初始熟练度值
  int getInitialMasteryLevel(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return 0;
      case MasteryLevel.learning:
        return 30;
      case MasteryLevel.mastered:
        return 70;
    }
  }

  /// 计算动作的优先级分数
  /// 优先级 = 遗忘因子 × 熟练度权重
  double calculatePriority({
    required int masteryLevel,
    required int lastPracticedAt,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSincePractice =
        (now - lastPracticedAt) / (24 * 60 * 60 * 1000);

    // 遗忘因子：越久未练，因子越大
    // 使用自然对数
    final forgettingFactor = 1 / (1 + log(daysSincePractice + 1));

    // 熟练度权重：熟练度越低，权重越大
    final masteryWeight = 1 - (masteryLevel / 100);

    return forgettingFactor * masteryWeight;
  }

  /// 根据熟练度判断动作状态
  String getMoveStatus(int masteryLevel) {
    if (masteryLevel < 30) {
      return 'new';
    } else if (masteryLevel < 70) {
      return 'learning';
    } else {
      return 'reviewing';
    }
  }

  /// 获取反馈对应的熟练度变化描述
  String getFeedbackDescription(FeedbackType feedback) {
    switch (feedback) {
      case FeedbackType.again:
        return '熟练度 -20';
      case FeedbackType.hard:
        return '熟练度 +5';
      case FeedbackType.easy:
        return '熟练度 +15';
    }
  }
}
