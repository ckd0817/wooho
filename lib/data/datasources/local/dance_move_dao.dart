import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/dance_move.dart';

/// 动作数据访问对象
class DanceMoveDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 插入动作
  Future<void> insert(DanceMove move) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableDanceMoves,
      move.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入动作
  Future<void> insertAll(List<DanceMove> moves) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final move in moves) {
      batch.insert(
        DatabaseHelper.tableDanceMoves,
        move.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 根据 ID 获取动作
  Future<DanceMove?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceMoves,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DanceMove.fromJson(maps.first);
  }

  /// 获取所有动作
  Future<List<DanceMove>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceMoves,
      orderBy: 'created_at DESC',
    );
    return maps.map((json) => DanceMove.fromJson(json)).toList();
  }

  /// 获取今日待复习的动作
  Future<List<DanceMove>> getDueMoves() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTimestamp = today.millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceMoves,
      where: 'next_review_date <= ?',
      whereArgs: [todayTimestamp],
      orderBy: 'next_review_date ASC',
    );
    return maps.map((json) => DanceMove.fromJson(json)).toList();
  }

  /// 按分类获取动作
  Future<List<DanceMove>> getByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceMoves,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return maps.map((json) => DanceMove.fromJson(json)).toList();
  }

  /// 获取所有分类
  Future<List<String>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT category FROM ${DatabaseHelper.tableDanceMoves}
      ORDER BY category ASC
    ''');
    return maps.map((map) => map['category'] as String).toList();
  }

  /// 更新动作
  Future<void> update(DanceMove move) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableDanceMoves,
      move.toJson(),
      where: 'id = ?',
      whereArgs: [move.id],
    );
  }

  /// 删除动作
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableDanceMoves,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取动作总数
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableDanceMoves}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 获取待复习动作数量
  Future<int> getDueCount() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayTimestamp = today.millisecondsSinceEpoch;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableDanceMoves} WHERE next_review_date <= ?',
      [todayTimestamp],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
