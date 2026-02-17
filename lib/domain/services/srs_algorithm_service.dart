/// 用户反馈类型
enum FeedbackType {
  /// 模糊 - 间隔重置为1天
  again,
  /// 认识 - 间隔 x 1.2
  hard,
  /// 熟练 - 间隔 x 2.5
  easy,
}

/// 初始熟练度等级
enum MasteryLevel {
  /// 新动作 - 1天后复习
  new_,
  /// 学习中 - 3天后复习
  learning,
  /// 已掌握 - 7天后复习
  mastered,
}

/// SRS 复习算法服务
/// 基于简化的艾宾浩斯遗忘曲线
class SrsAlgorithmService {
  // 间隔乘数常量
  static const double _hardMultiplier = 1.2;
  static const double _easyMultiplier = 2.5;

  // 最小/最大间隔天数
  static const int minIntervalDays = 1;
  static const int maxIntervalDays = 365;

  /// 根据用户反馈计算新的间隔天数
  int calculateNewInterval(int currentInterval, FeedbackType feedback) {
    switch (feedback) {
      case FeedbackType.again:
        return minIntervalDays;
      case FeedbackType.hard:
        final newInterval = (currentInterval * _hardMultiplier).round();
        return newInterval.clamp(minIntervalDays, maxIntervalDays);
      case FeedbackType.easy:
        final newInterval = (currentInterval * _easyMultiplier).round();
        return newInterval.clamp(minIntervalDays, maxIntervalDays);
    }
  }

  /// 计算下次复习日期
  DateTime calculateNextReviewDate(int newInterval) {
    return DateTime.now().add(Duration(days: newInterval));
  }

  /// 根据初始熟练度计算首次复习日期
  DateTime calculateInitialReviewDate(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return DateTime.now().add(const Duration(days: 1));
      case MasteryLevel.learning:
        return DateTime.now().add(const Duration(days: 3));
      case MasteryLevel.mastered:
        return DateTime.now().add(const Duration(days: 7));
    }
  }

  /// 根据初始熟练度计算首次间隔天数
  int calculateInitialInterval(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return 1;
      case MasteryLevel.learning:
        return 3;
      case MasteryLevel.mastered:
        return 7;
    }
  }

  /// 判断某日期是否是今天或之前
  bool isDue(DateTime reviewDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDateOnly = DateTime(
      reviewDate.year,
      reviewDate.month,
      reviewDate.day,
    );
    return !reviewDateOnly.isAfter(today);
  }

  /// 格式化下次复习时间为可读字符串
  String formatNextReviewDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate == today) {
      return '今天';
    } else if (targetDate == tomorrow) {
      return '明天';
    } else {
      final difference = targetDate.difference(today).inDays;
      if (difference < 7) {
        return '$difference 天后';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return '$weeks 周后';
      } else {
        final months = (difference / 30).floor();
        return '$months 个月后';
      }
    }
  }
}
