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

  /// 获取所有动作（按优先级排序）
  /// 优先级 = 遗忘因子 × 熟练度权重
  /// 遗忘因子 = 1 / (1 + log(距上次练习天数 + 1))
  /// 熟练度权重 = 1 - (mastery_level / 100)
  Future<List<DanceMove>> getAllOrderedByPriority() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dayInMillis = 24 * 60 * 60 * 1000;

    // 获取所有动作
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceMoves,
    );

    final moves = maps.map((json) => DanceMove.fromJson(json)).toList();

    // 计算优先级并排序
    moves.sort((a, b) {
      final priorityA = _calculatePriority(a, now, dayInMillis);
      final priorityB = _calculatePriority(b, now, dayInMillis);
      return priorityB.compareTo(priorityA); // 降序
    });

    return moves;
  }

  /// 计算动作优先级
  double _calculatePriority(DanceMove move, int now, int dayInMillis) {
    final daysSincePractice = (now - move.lastPracticedAt) / dayInMillis;

    // 遗忘因子：越久未练，因子越大
    final forgettingFactor = 1 / (1 + _log(daysSincePractice + 1));

    // 熟练度权重：熟练度越低，权重越大
    final masteryWeight = 1 - (move.masteryLevel / 100);

    return forgettingFactor * masteryWeight;
  }

  /// 简单的对数函数实现
  double _log(double x) {
    if (x <= 0) return 0;
    return x.isFinite ? (x > 1 ? x.toString().length - 1.0 : 0) : 0;
  }

  /// 选取指定数量的动作用于训练（按优先级）
  Future<List<DanceMove>> getMovesForTraining({int count = 10}) async {
    final orderedMoves = await getAllOrderedByPriority();
    return orderedMoves.take(count).toList();
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
}
