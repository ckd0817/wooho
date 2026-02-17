import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库帮助类
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// 数据库名称
  static const String _databaseName = 'danceloop.db';

  /// 数据库版本
  static const int _databaseVersion = 1;

  /// 表名
  static const String tableDanceMoves = 'dance_moves';
  static const String tableReviewRecords = 'review_records';

  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建表
  Future<void> _onCreate(Database db, int version) async {
    // 创建动作表
    await db.execute('''
      CREATE TABLE $tableDanceMoves (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        video_source_type TEXT NOT NULL,
        video_uri TEXT NOT NULL,
        trim_start INTEGER DEFAULT 0,
        trim_end INTEGER DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'new',
        interval INTEGER DEFAULT 1,
        next_review_date INTEGER NOT NULL,
        mastery_level INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');

    // 创建复习记录表
    await db.execute('''
      CREATE TABLE $tableReviewRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        move_id TEXT NOT NULL,
        feedback TEXT NOT NULL,
        reviewed_at INTEGER NOT NULL,
        previous_interval INTEGER NOT NULL,
        new_interval INTEGER NOT NULL,
        FOREIGN KEY (move_id) REFERENCES $tableDanceMoves (id)
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX idx_dance_moves_next_review ON $tableDanceMoves (next_review_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_review_records_move_id ON $tableReviewRecords (move_id)
    ''');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 未来版本升级逻辑
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
