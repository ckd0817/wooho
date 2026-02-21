import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../../models/dance_element.dart';

/// 元素数据访问对象
class DanceElementDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// 插入元素
  Future<void> insert(DanceElement element) async {
    final db = await _dbHelper.database;
    await db.insert(
      DatabaseHelper.tableDanceElements,
      element.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 批量插入元素
  Future<void> insertAll(List<DanceElement> elements) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    for (final element in elements) {
      batch.insert(
        DatabaseHelper.tableDanceElements,
        element.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 根据 ID 获取元素
  Future<DanceElement?> getById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceElements,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return DanceElement.fromJson(maps.first);
  }

  /// 获取所有元素
  Future<List<DanceElement>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceElements,
      orderBy: 'created_at DESC',
    );
    return maps.map((json) => DanceElement.fromJson(json)).toList();
  }

  /// 获取所有元素（按优先级排序）
  /// 优先级 = 遗忘因子 × 熟练度权重
  /// 遗忘因子 = 1 / (1 + log(距上次练习天数 + 1))
  /// 熟练度权重 = 1 - (mastery_level / 100)
  Future<List<DanceElement>> getAllOrderedByPriority() async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final dayInMillis = 24 * 60 * 60 * 1000;

    // 获取所有元素
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceElements,
    );

    final elements = maps.map((json) => DanceElement.fromJson(json)).toList();

    // 计算优先级并排序
    elements.sort((a, b) {
      final priorityA = _calculatePriority(a, now, dayInMillis);
      final priorityB = _calculatePriority(b, now, dayInMillis);
      return priorityB.compareTo(priorityA); // 降序
    });

    return elements;
  }

  /// 计算元素优先级
  double _calculatePriority(DanceElement element, int now, int dayInMillis) {
    final daysSincePractice = (now - element.lastPracticedAt) / dayInMillis;

    // 遗忘因子：越久未练，因子越大
    final forgettingFactor = 1 / (1 + _log(daysSincePractice + 1));

    // 熟练度权重：熟练度越低，权重越大
    final masteryWeight = 1 - (element.masteryLevel / 100);

    return forgettingFactor * masteryWeight;
  }

  /// 简单的对数函数实现
  double _log(double x) {
    if (x <= 0) return 0;
    return x.isFinite ? (x > 1 ? x.toString().length - 1.0 : 0) : 0;
  }

  /// 选取指定数量的元素用于训练（按优先级）
  Future<List<DanceElement>> getElementsForTraining({int count = 10}) async {
    final orderedElements = await getAllOrderedByPriority();
    return orderedElements.take(count).toList();
  }

  /// 按分类获取元素
  Future<List<DanceElement>> getByCategory(String category) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.tableDanceElements,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return maps.map((json) => DanceElement.fromJson(json)).toList();
  }

  /// 获取所有分类
  Future<List<String>> getAllCategories() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT category FROM ${DatabaseHelper.tableDanceElements}
      ORDER BY category ASC
    ''');
    return maps.map((map) => map['category'] as String).toList();
  }

  /// 更新元素
  Future<void> update(DanceElement element) async {
    final db = await _dbHelper.database;
    await db.update(
      DatabaseHelper.tableDanceElements,
      element.toJson(),
      where: 'id = ?',
      whereArgs: [element.id],
    );
  }

  /// 删除元素
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      DatabaseHelper.tableDanceElements,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取元素总数
  Future<int> getCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableDanceElements}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
