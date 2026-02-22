import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// 复习记录数据模型
class ReviewRecord {
  final int? id;
  final String elementId;
  final String feedback;
  final int reviewedAt;
  final int previousMastery;
  final int newMastery;

  ReviewRecord({
    this.id,
    required this.elementId,
    required this.feedback,
    required this.reviewedAt,
    required this.previousMastery,
    required this.newMastery,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'element_id': elementId,
        'feedback': feedback,
        'reviewed_at': reviewedAt,
        'previous_mastery': previousMastery,
        'new_mastery': newMastery,
      };

  factory ReviewRecord.fromJson(Map<String, dynamic> json) => ReviewRecord(
        id: json['id'] as int?,
        elementId: json['element_id'] as String,
        feedback: json['feedback'] as String,
        reviewedAt: json['reviewed_at'] as int,
        previousMastery: json['previous_mastery'] as int,
        newMastery: json['new_mastery'] as int,
      );
}

/// 复习记录数据访问对象
class ReviewDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 插入复习记录
  Future<int> insert(ReviewRecord record) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableReviewRecords,
      record.toJson(),
    );
  }

  /// 获取某元素的所有复习记录
  Future<List<ReviewRecord>> getByElementId(String elementId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableReviewRecords,
      where: 'element_id = ?',
      whereArgs: [elementId],
      orderBy: 'reviewed_at DESC',
    );
    return maps.map((json) => ReviewRecord.fromJson(json)).toList();
  }

  /// 获取某日期范围内的复习记录
  Future<List<ReviewRecord>> getByDateRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableReviewRecords,
      where: 'reviewed_at >= ? AND reviewed_at <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'reviewed_at DESC',
    );
    return maps.map((json) => ReviewRecord.fromJson(json)).toList();
  }

  /// 获取今日复习次数
  Future<int> getTodayReviewCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableReviewRecords} WHERE reviewed_at >= ? AND reviewed_at < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 删除某元素的所有复习记录
  Future<void> deleteByElementId(String elementId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableReviewRecords,
      where: 'element_id = ?',
      whereArgs: [elementId],
    );
  }

  /// 获取本周复习次数
  Future<int> getWeekReviewCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    // 获取本周一 00:00:00
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableReviewRecords} WHERE reviewed_at >= ?',
      [startOfWeek.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取连续打卡天数
  Future<int> getStreakDays() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    int streak = 0;

    // 从今天开始往前检查
    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableReviewRecords} WHERE reviewed_at >= ? AND reviewed_at < ?',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;

      if (count > 0) {
        streak++;
      } else if (i > 0) {
        // 如果不是今天且没有复习记录，连续天数中断
        break;
      }
      // 如果是今天且没有复习记录，继续检查昨天
    }

    return streak;
  }

  /// 获取某天的复习记录数
  Future<int> getReviewCountForDate(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableReviewRecords} WHERE reviewed_at >= ? AND reviewed_at < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取最近的复习记录
  Future<List<ReviewRecord>> getRecentRecords({int limit = 5}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableReviewRecords,
      orderBy: 'reviewed_at DESC',
      limit: limit,
    );
    return maps.map((json) => ReviewRecord.fromJson(json)).toList();
  }
}
