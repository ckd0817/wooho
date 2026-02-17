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
  static const int _databaseVersion = 2;

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
        mastery_level INTEGER DEFAULT 0,
        last_practiced_at INTEGER NOT NULL,
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
        previous_mastery INTEGER NOT NULL,
        new_mastery INTEGER NOT NULL,
        FOREIGN KEY (move_id) REFERENCES $tableDanceMoves (id)
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX idx_dance_moves_last_practiced ON $tableDanceMoves (last_practiced_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_dance_moves_mastery ON $tableDanceMoves (mastery_level)
    ''');
    await db.execute('''
      CREATE INDEX idx_review_records_move_id ON $tableReviewRecords (move_id)
    ''');
  }

  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 从 v1 升级到 v2：移除 interval 和 next_review_date，添加 last_practiced_at
      // 由于 SQLite 不支持直接删除列，我们需要重建表

      // 使用事务来执行迁移
      await db.transaction((txn) async {
        // 备份旧数据到临时表
        await txn.execute('''
          CREATE TABLE dance_moves_backup AS SELECT * FROM $tableDanceMoves
        ''');

        // 删除旧表
        await txn.execute('DROP TABLE $tableDanceMoves');

        // 创建新表
        await txn.execute('''
          CREATE TABLE $tableDanceMoves (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            video_source_type TEXT NOT NULL,
            video_uri TEXT NOT NULL,
            trim_start INTEGER DEFAULT 0,
            trim_end INTEGER DEFAULT 0,
            status TEXT NOT NULL DEFAULT 'new',
            mastery_level INTEGER DEFAULT 0,
            last_practiced_at INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER
          )
        ''');

        // 迁移数据（使用 created_at 作为 last_practiced_at 的默认值）
        await txn.execute('''
          INSERT INTO $tableDanceMoves (id, name, category, video_source_type, video_uri, trim_start, trim_end, status, mastery_level, last_practiced_at, created_at, updated_at)
          SELECT id, name, category, video_source_type, video_uri, trim_start, trim_end, status, mastery_level, created_at, created_at, updated_at
          FROM dance_moves_backup
        ''');

        // 删除备份表
        await txn.execute('DROP TABLE dance_moves_backup');

        // 创建新索引
        await txn.execute('''
          CREATE INDEX idx_dance_moves_last_practiced ON $tableDanceMoves (last_practiced_at)
        ''');
        await txn.execute('''
          CREATE INDEX idx_dance_moves_mastery ON $tableDanceMoves (mastery_level)
        ''');
      });

      // 更新复习记录表（如果需要）- 在事务外执行，因为可能失败
      try {
        await db.execute('ALTER TABLE $tableReviewRecords ADD COLUMN previous_mastery INTEGER DEFAULT 0');
        await db.execute('ALTER TABLE $tableReviewRecords ADD COLUMN new_mastery INTEGER DEFAULT 0');
      } catch (e) {
        // 列可能已存在，忽略错误
      }
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
