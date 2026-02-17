import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/review_repository.dart';

/// 统计数据模型
class StatisticsData {
  final int weekReviewCount;
  final int streakDays;
  final int totalMoves;
  final int dueToday;

  const StatisticsData({
    this.weekReviewCount = 0,
    this.streakDays = 0,
    this.totalMoves = 0,
    this.dueToday = 0,
  });

  StatisticsData copyWith({
    int? weekReviewCount,
    int? streakDays,
    int? totalMoves,
    int? dueToday,
  }) {
    return StatisticsData(
      weekReviewCount: weekReviewCount ?? this.weekReviewCount,
      streakDays: streakDays ?? this.streakDays,
      totalMoves: totalMoves ?? this.totalMoves,
      dueToday: dueToday ?? this.dueToday,
    );
  }
}

/// 统计 Provider
final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final repository = ReviewRepository();

  final weekReviewCount = await repository.getWeekReviewCount();
  final streakDays = await repository.getStreakDays();

  return StatisticsData(
    weekReviewCount: weekReviewCount,
    streakDays: streakDays,
  );
});

/// 本周复习次数 Provider
final weekReviewCountProvider = FutureProvider<int>((ref) async {
  final repository = ReviewRepository();
  return await repository.getWeekReviewCount();
});

/// 连续打卡天数 Provider
final streakDaysProvider = FutureProvider<int>((ref) async {
  final repository = ReviewRepository();
  return await repository.getStreakDays();
});
