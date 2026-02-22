import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/routine_record.dart';

/// 舞段训练记录数据访问对象
class RoutineRecordDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 插入训练记录
  Future<int> insert(RoutineRecord record) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableRoutineRecords,
      record.toJson(),
    );
  }

  /// 获取某舞段的所有训练记录
  Future<List<RoutineRecord>> getByRoutineId(String routineId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutineRecords,
      where: 'routine_id = ?',
      whereArgs: [routineId],
      orderBy: 'reviewed_at DESC',
    );
    return maps.map((json) => RoutineRecord.fromJson(json)).toList();
  }

  /// 获取某日期范围内的训练记录
  Future<List<RoutineRecord>> getByDateRange(
    int startTimestamp,
    int endTimestamp,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutineRecords,
      where: 'reviewed_at >= ? AND reviewed_at <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: 'reviewed_at DESC',
    );
    return maps.map((json) => RoutineRecord.fromJson(json)).toList();
  }

  /// 获取今日训练次数
  Future<int> getTodayReviewCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableRoutineRecords} WHERE reviewed_at >= ? AND reviewed_at < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 删除某舞段的所有训练记录
  Future<void> deleteByRoutineId(String routineId) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableRoutineRecords,
      where: 'routine_id = ?',
      whereArgs: [routineId],
    );
  }

  /// 获取本周训练次数
  Future<int> getWeekReviewCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek = DateTime(monday.year, monday.month, monday.day);

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableRoutineRecords} WHERE reviewed_at >= ?',
      [startOfWeek.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取连续打卡天数
  Future<int> getStreakDays() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final startOfDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableRoutineRecords} WHERE reviewed_at >= ? AND reviewed_at < ?',
        [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      );

      final count = Sqflite.firstIntValue(result) ?? 0;

      if (count > 0) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return streak;
  }

  /// 获取最近的训练记录
  Future<List<RoutineRecord>> getRecentRecords({int limit = 5}) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutineRecords,
      orderBy: 'reviewed_at DESC',
      limit: limit,
    );
    return maps.map((json) => RoutineRecord.fromJson(json)).toList();
  }
}
