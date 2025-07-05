
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:untitled1/models/live_broadcast.dart';

import '../models/grade.dart';

class DatabaseHelper {
  // 静态初始化FFI
  static void initialize() {
    sqfliteFfiInit(); // 初始化FFI
    databaseFactory = databaseFactoryFfi; // 设置工厂
  }

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('live_broadcast.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE live_broadcasts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        location TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        views INTEGER DEFAULT 0,
        postDate TEXT NOT NULL,
        imageUrl TEXT NOT NULL DEFAULT 'lib/assets/images/p2.jpg'
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE live_broadcasts ADD COLUMN imageUrl TEXT NOT NULL DEFAULT "lib/assets/images/p2.jpg"');
    }
  }

  Future<LiveBroadcast?> getLiveBroadcast() async {
    final db = await database;
    final maps = await db.query('live_broadcasts', limit: 1);
    if (maps.isEmpty) return null;
    return LiveBroadcast.fromMap(maps.first);
  }

  Future<int> updateViews(int id, int newViews) async {
    final db = await database;
    return await db.update(
      'live_broadcasts',
      {'views': newViews},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  // 新增直播预告
  Future<int> insertLiveBroadcast(LiveBroadcast broadcast) async {
    final db = await database;
    return await db.insert('live_broadcasts', broadcast.toMap());
  }

// 删除直播预告
  Future<int> deleteLiveBroadcast(int id) async {
    final db = await database;
    return await db.delete(
      'live_broadcasts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<List<LiveBroadcast>> getAllLiveBroadcasts() async {
    final db = await database;
    final maps = await db.query('live_broadcasts');
    return maps.map((map) => LiveBroadcast.fromMap(map)).toList();
  }


}