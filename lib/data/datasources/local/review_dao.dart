import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

/// 复习记录数据模型
class ReviewRecord {
  final int? id;
  final String moveId;
  final String feedback;
  final int reviewedAt;
  final int previousInterval;
  final int newInterval;

  ReviewRecord({
    this.id,
    required this.moveId,
    required this.feedback,
    required this.reviewedAt,
    required this.previousInterval,
    required this.newInterval,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'move_id': moveId,
        'feedback': feedback,
        'reviewed_at': reviewedAt,
        'previous_interval': previousInterval,
        'new_interval': newInterval,
      };

  factory ReviewRecord.fromJson(Map<String, dynamic> json) => ReviewRecord(
        id: json['id'] as int?,
        moveId: json['move_id'] as String,
        feedback: json['feedback'] as String,
        reviewedAt: json['reviewed_at'] as int,
        previousInterval: json['previous_interval'] as int,
        newInterval: json['new_interval'] as int,
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

  /// 获取某动作的所有复习记录
  Future<List<ReviewRecord>> getByMoveId(String moveId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableReviewRecords,
      where: 'move_id = ?',
      whereArgs: [moveId],
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

  /// 删除某动作的所有复习记录
  Future<void> deleteByMoveId(String moveId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableReviewRecords,
      where: 'move_id = ?',
      whereArgs: [moveId],
    );
  }
}
