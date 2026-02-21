import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// 数据库帮助类
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// 数据库名称
  static const String _databaseName = 'wooho.db';

  /// 数据库版本
  static const int _databaseVersion = 3;

  /// 表名
  static const String tableDanceElements = 'dance_elements';
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
    // 创建元素表
    await db.execute('''
      CREATE TABLE $tableDanceElements (
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
        element_id TEXT NOT NULL,
        feedback TEXT NOT NULL,
        reviewed_at INTEGER NOT NULL,
        previous_mastery INTEGER NOT NULL,
        new_mastery INTEGER NOT NULL,
        FOREIGN KEY (element_id) REFERENCES $tableDanceElements (id)
      )
    ''');

    // 创建索引
    await db.execute('''
      CREATE INDEX idx_dance_elements_last_practiced ON $tableDanceElements (last_practiced_at)
    ''');
    await db.execute('''
      CREATE INDEX idx_dance_elements_mastery ON $tableDanceElements (mastery_level)
    ''');
    await db.execute('''
      CREATE INDEX idx_review_records_element_id ON $tableReviewRecords (element_id)
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
          CREATE TABLE dance_elements_backup AS SELECT * FROM dance_elements
        ''');

        // 删除旧表
        await txn.execute('DROP TABLE dance_elements');

        // 创建新表
        await txn.execute('''
          CREATE TABLE dance_elements (
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
          INSERT INTO dance_elements (id, name, category, video_source_type, video_uri, trim_start, trim_end, status, mastery_level, last_practiced_at, created_at, updated_at)
          SELECT id, name, category, video_source_type, video_uri, trim_start, trim_end, status, mastery_level, created_at, created_at, updated_at
          FROM dance_elements_backup
        ''');

        // 删除备份表
        await txn.execute('DROP TABLE dance_elements_backup');

        // 创建新索引
        await txn.execute('''
          CREATE INDEX idx_dance_elements_last_practiced ON dance_elements (last_practiced_at)
        ''');
        await txn.execute('''
          CREATE INDEX idx_dance_elements_mastery ON dance_elements (mastery_level)
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

    if (oldVersion < 3) {
      // v2 → v3: 重命名表和字段
      // dance_moves → dance_elements
      // move_id → element_id
      await db.transaction((txn) async {
        // 1. 重命名 dance_moves 表为 dance_elements
        await txn.execute('''
          ALTER TABLE dance_moves RENAME TO dance_elements
        ''');

        // 2. 重命名 review_records 表中的 move_id 字段
        // SQLite 不支持直接重命名列，需要重建表
        await txn.execute('''
          CREATE TABLE review_records_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            element_id TEXT NOT NULL,
            feedback TEXT NOT NULL,
            reviewed_at INTEGER NOT NULL,
            previous_mastery INTEGER NOT NULL,
            new_mastery INTEGER NOT NULL
          )
        ''');

        await txn.execute('''
          INSERT INTO review_records_new (id, element_id, feedback, reviewed_at, previous_mastery, new_mastery)
          SELECT id, move_id, feedback, reviewed_at, previous_mastery, new_mastery
          FROM review_records
        ''');

        await txn.execute('DROP TABLE review_records');
        await txn.execute('ALTER TABLE review_records_new RENAME TO review_records');

        // 3. 重建索引
        await txn.execute('DROP INDEX IF EXISTS idx_dance_moves_last_practiced');
        await txn.execute('DROP INDEX IF EXISTS idx_dance_moves_mastery');
        await txn.execute('DROP INDEX IF EXISTS idx_review_records_move_id');

        await txn.execute('''
          CREATE INDEX idx_dance_elements_last_practiced ON dance_elements (last_practiced_at)
        ''');
        await txn.execute('''
          CREATE INDEX idx_dance_elements_mastery ON dance_elements (mastery_level)
        ''');
        await txn.execute('''
          CREATE INDEX idx_review_records_element_id ON review_records (element_id)
        ''');
      });
    }
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
