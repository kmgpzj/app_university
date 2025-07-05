import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course.dart';

class CourseDatabase {
  static final CourseDatabase instance = CourseDatabase._init();
  static Database? _database;

  CourseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('courses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        teacher TEXT,
        classroom TEXT,
        dayOfWeek INTEGER NOT NULL,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        weeks TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');
  }

  // 增删改查方法
  Future<Course> create(Course course) async {
    final db = await instance.database;
    await db.insert('courses', course.toMap());
    return course;
  }

  Future<List<Course>> readAllCourses() async {
    final db = await instance.database;
    final result = await db.query('courses');
    return result.map((json) => Course.fromMap(json)).toList();
  }

  Future<int> update(Course course) async {
    final db = await instance.database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}