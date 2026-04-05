import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/dance_routine.dart';

/// 舞段数据访问对象
class DanceRoutineDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 插入舞段
  Future<void> insert(DanceRoutine routine) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableRoutines,
      routine.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 根据 ID 获取舞段
  Future<DanceRoutine?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutines,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DanceRoutine.fromJson(maps.first);
  }

  /// 获取所有舞段
  Future<List<DanceRoutine>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutines,
      orderBy: 'created_at DESC',
    );
    return maps.map((json) => DanceRoutine.fromJson(json)).toList();
  }

  /// 获取所有舞段（按优先级排序）
  /// 优先级 = 遗忘因子 × 熟练度权重
  Future<List<DanceRoutine>> getAllOrderedByPriority() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dayInMillis = 24 * 60 * 60 * 1000;

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutines,
    );

    final routines = maps.map((json) => DanceRoutine.fromJson(json)).toList();

    routines.sort((a, b) {
      final priorityA = _calculatePriority(a, now, dayInMillis);
      final priorityB = _calculatePriority(b, now, dayInMillis);
      return priorityB.compareTo(priorityA);
    });

    return routines;
  }

  /// 计算舞段优先级
  double _calculatePriority(DanceRoutine routine, int now, int dayInMillis) {
    final daysSincePractice = (now - routine.lastPracticedAt) / dayInMillis;
    final forgettingFactor = 1 / (1 + _log(daysSincePractice + 1));
    final masteryWeight = 1 - (routine.masteryLevel / 100);
    return forgettingFactor * masteryWeight;
  }

  double _log(double x) {
    if (x <= 0) return 0;
    return x.isFinite ? (x > 1 ? x.toString().length - 1.0 : 0) : 0;
  }

  /// 选取指定数量的舞段用于训练（按优先级）
  Future<List<DanceRoutine>> getRoutinesForTraining({int count = 10}) async {
    final orderedRoutines = await getAllOrderedByPriority();
    return orderedRoutines.take(count).toList();
  }

  /// 按分类获取舞段
  Future<List<DanceRoutine>> getByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableRoutines,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return maps.map((json) => DanceRoutine.fromJson(json)).toList();
  }

  /// 获取所有分类
  Future<List<String>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT category FROM ${DatabaseHelper.tableRoutines}
      ORDER BY category ASC
    ''');
    return maps.map((map) => map['category'] as String).toList();
  }

  /// 更新舞段
  Future<void> update(DanceRoutine routine) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableRoutines,
      routine.toJson(),
      where: 'id = ?',
      whereArgs: [routine.id],
    );
  }

  /// 删除舞段
  Future<int> delete(String id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableRoutines,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取舞段总数
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableRoutines}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
