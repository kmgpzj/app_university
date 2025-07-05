import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('leave_applications.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE leave_applications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      studentId TEXT NOT NULL,
      leaveType TEXT NOT NULL,
      startDate TEXT NOT NULL,
      endDate TEXT NOT NULL,
      reason TEXT NOT NULL,
      phone TEXT NOT NULL,
      status TEXT NOT NULL,
      submitTime TEXT NOT NULL,
      reviewTime TEXT,
      reviewer TEXT,
      reviewComment TEXT
    )
    ''');

    await _insertSampleData(db);
  }

  Future<void> _insertSampleData(Database db) async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');

    // 已批准的请假记录
    await db.insert('leave_applications', {
      'name': '张三',
      'studentId': '2023001',
      'leaveType': '病假',
      'startDate': formatter.format(now.subtract(Duration(days: 5))),
      'endDate': formatter.format(now.subtract(Duration(days: 3))),
      'reason': '感冒发烧，需要休息',
      'phone': '13800138001',
      'status': '已批准',
      'submitTime': now.subtract(Duration(days: 6)).toString(),
      'reviewTime': now.subtract(Duration(days: 5)).toString(),
      'reviewer': '李老师',
      'reviewComment': '好好休息，早日康复'
    });

    // 已拒绝的请假记录
    await db.insert('leave_applications', {
      'name': '王五',
      'studentId': '2023003',
      'leaveType': '事假',
      'startDate': formatter.format(now.subtract(Duration(days: 3))),
      'endDate': formatter.format(now.subtract(Duration(days: 1))),
      'reason': '外出游玩',
      'phone': '13800138003',
      'status': '已拒绝',
      'submitTime': now.subtract(Duration(days: 4)).toString(),
      'reviewTime': now.subtract(Duration(days: 3)).toString(),
      'reviewer': '张老师',
      'reviewComment': '非紧急情况不予批准'
    });

    // 待审核的请假记录
    await db.insert('leave_applications', {
      'name': '钱七',
      'studentId': '2023005',
      'leaveType': '公假',
      'startDate': formatter.format(now.add(Duration(days: 2))),
      'endDate': formatter.format(now.add(Duration(days: 3))),
      'reason': '参加学校比赛',
      'phone': '13800138005',
      'status': '待审核',
      'submitTime': now.toString(),
    });
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE leave_applications ADD COLUMN reviewTime TEXT');
      await db.execute('ALTER TABLE leave_applications ADD COLUMN reviewer TEXT');
      await db.execute('ALTER TABLE leave_applications ADD COLUMN reviewComment TEXT');
      await _insertSampleData(db);
    }
  }

  Future<int> insertLeaveApplication(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('leave_applications', row);
  }

  Future<List<Map<String, dynamic>>> getLeaveApplications() async {
    final db = await instance.database;
    return await db.query('leave_applications', orderBy: 'submitTime DESC');
  }

  Future<List<Map<String, dynamic>>> getLeaveApplicationsByStudent(String studentId) async {
    final db = await instance.database;
    return await db.query(
      'leave_applications',
      where: 'studentId = ?',
      whereArgs: [studentId],
      orderBy: 'submitTime DESC',
    );
  }

  Future<int> updateLeaveStatus(int id, String status, {String? reviewer, String? comment}) async {
    final db = await instance.database;
    return await db.update(
      'leave_applications',
      {
        'status': status,
        'reviewTime': DateTime.now().toString(),
        'reviewer': reviewer,
        'reviewComment': comment,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}