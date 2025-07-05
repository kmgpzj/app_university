import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grades.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        department TEXT,
        admission_date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE semesters (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        credit REAL NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT NOT NULL,
        semester_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        teacher TEXT NOT NULL,
        exam_date TEXT NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (semester_id) REFERENCES semesters (id),
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    ''');

    await _insertInitialData(db);
  }

  Future _insertInitialData(Database db) async {
    // 插入学期数据
    final semesters = [
      '2023-2024学年第一学期',
      '2022-2023学年第二学期',
      '2022-2023学年第一学期',
      '2021-2022学年第二学期',
      '2021-2022学年第一学期',
      '2020-2021学年第二学期',
      '2020-2021学年第一学期',
      '2019-2020学年第二学期',
      '2019-2020学年第一学期',
    ];

    for (var semester in semesters) {
      await db.insert('semesters', {'name': semester});
    }

    // 插入10个学生数据
    final students = [
      {'id': '20230001', 'name': '张三', 'department': '计算机科学与技术', 'admission_date': '2020-09-01'},
      {'id': '20230002', 'name': '李四', 'department': '软件工程', 'admission_date': '2020-09-01'},
      {'id': '20230003', 'name': '王五', 'department': '人工智能', 'admission_date': '2020-09-01'},
      {'id': '20230004', 'name': '赵六', 'department': '数据科学', 'admission_date': '2020-09-01'},
      {'id': '20230005', 'name': '钱七', 'department': '网络安全', 'admission_date': '2020-09-01'},
      {'id': '20230006', 'name': '孙八', 'department': '物联网工程', 'admission_date': '2020-09-01'},
      {'id': '20230007', 'name': '周九', 'department': '电子信息工程', 'admission_date': '2020-09-01'},
      {'id': '20230008', 'name': '吴十', 'department': '自动化', 'admission_date': '2020-09-01'},
      {'id': '20230009', 'name': '郑十一', 'department': '通信工程', 'admission_date': '2020-09-01'},
      {'id': '20230010', 'name': '王十二', 'department': '计算机科学与技术', 'admission_date': '2020-09-01'},
    ];

    for (var student in students) {
      await db.insert('students', student);
    }

    // 插入50门课程数据
    final courses = [
      {'name': '高等数学(上)', 'credit': 4.0, 'type': '公共必修'},
      {'name': '高等数学(下)', 'credit': 4.0, 'type': '公共必修'},
      {'name': '线性代数', 'credit': 3.0, 'type': '公共必修'},
      {'name': '概率论与数理统计', 'credit': 3.0, 'type': '公共必修'},
      {'name': '大学英语(一)', 'credit': 3.0, 'type': '公共必修'},
      {'name': '大学英语(二)', 'credit': 3.0, 'type': '公共必修'},
      {'name': '大学英语(三)', 'credit': 3.0, 'type': '公共必修'},
      {'name': '大学英语(四)', 'credit': 3.0, 'type': '公共必修'},
      {'name': '大学物理(上)', 'credit': 3.0, 'type': '公共必修'},
      {'name': '大学物理(下)', 'credit': 3.0, 'type': '公共必修'},
      {'name': '体育(一)', 'credit': 1.0, 'type': '公共必修'},
      {'name': '体育(二)', 'credit': 1.0, 'type': '公共必修'},
      {'name': '体育(三)', 'credit': 1.0, 'type': '公共必修'},
      {'name': '体育(四)', 'credit': 1.0, 'type': '公共必修'},
      {'name': '思想道德修养与法律基础', 'credit': 2.0, 'type': '公共必修'},
      {'name': '中国近现代史纲要', 'credit': 2.0, 'type': '公共必修'},
      {'name': '马克思主义基本原理', 'credit': 2.0, 'type': '公共必修'},
      {'name': '毛泽东思想和中国特色社会主义理论体系概论', 'credit': 3.0, 'type': '公共必修'},
      {'name': '形势与政策', 'credit': 1.0, 'type': '公共必修'},
      {'name': '军事理论', 'credit': 2.0, 'type': '公共必修'},
      {'name': '计算机科学导论', 'credit': 2.0, 'type': '专业必修'},
      {'name': '程序设计基础', 'credit': 3.0, 'type': '专业必修'},
      {'name': '面向对象程序设计', 'credit': 3.0, 'type': '专业必修'},
      {'name': '数据结构', 'credit': 3.0, 'type': '专业必修'},
      {'name': '算法设计与分析', 'credit': 3.0, 'type': '专业必修'},
      {'name': '计算机组成原理', 'credit': 3.0, 'type': '专业必修'},
      {'name': '操作系统', 'credit': 3.0, 'type': '专业必修'},
      {'name': '计算机网络', 'credit': 3.0, 'type': '专业必修'},
      {'name': '数据库系统原理', 'credit': 3.0, 'type': '专业必修'},
      {'name': '软件工程', 'credit': 3.0, 'type': '专业必修'},
      {'name': '编译原理', 'credit': 3.0, 'type': '专业必修'},
      {'name': '数字逻辑', 'credit': 3.0, 'type': '专业必修'},
      {'name': '离散数学', 'credit': 3.0, 'type': '专业必修'},
      {'name': '人工智能导论', 'credit': 2.0, 'type': '专业选修'},
      {'name': '机器学习', 'credit': 3.0, 'type': '专业选修'},
      {'name': '深度学习', 'credit': 3.0, 'type': '专业选修'},
      {'name': '计算机视觉', 'credit': 2.0, 'type': '专业选修'},
      {'name': '自然语言处理', 'credit': 2.0, 'type': '专业选修'},
      {'name': '大数据技术', 'credit': 2.0, 'type': '专业选修'},
      {'name': '云计算', 'credit': 2.0, 'type': '专业选修'},
      {'name': '区块链技术', 'credit': 2.0, 'type': '专业选修'},
      {'name': '物联网技术', 'credit': 2.0, 'type': '专业选修'},
      {'name': '移动应用开发', 'credit': 2.0, 'type': '专业选修'},
      {'name': 'Web开发技术', 'credit': 2.0, 'type': '专业选修'},
      {'name': 'Python编程', 'credit': 2.0, 'type': '专业选修'},
      {'name': 'Java程序设计', 'credit': 3.0, 'type': '专业选修'},
      {'name': 'C++程序设计', 'credit': 3.0, 'type': '专业选修'},
      {'name': 'Linux系统', 'credit': 2.0, 'type': '专业选修'},
      {'name': '信息安全基础', 'credit': 2.0, 'type': '专业选修'},
      {'name': '计算机图形学', 'credit': 2.0, 'type': '专业选修'},
    ];

    for (var course in courses) {
      await db.insert('courses', course);
    }

    // 为每个学生生成随机成绩数据
    final random = Random();
    for (var student in students) {
      for (int i = 0; i < semesters.length; i++) {
        int courseCount = 3 + random.nextInt(4);
        for (int j = 0; j < courseCount; j++) {
          int courseId = 1 + random.nextInt(courses.length);
          int score = 50 + random.nextInt(51);
          if (random.nextDouble() > 0.2) {
            score = 60 + random.nextInt(31);
          }

          await db.insert('grades', {
            'student_id': student['id'],
            'semester_id': i + 1,
            'course_id': courseId,
            'score': score,
            'teacher': '${['张','李','王','赵','钱','孙','周','吴','郑','王'][random.nextInt(10)]}教授',
            'exam_date': '${2020 + (i ~/ 2)}-${i % 2 == 0 ? '01' : '06'}-${10 + random.nextInt(10)}'
          });
        }
      }
    }
  }

  Future<List<Map<String, dynamic>>> getStudentGrades(String studentId, int semesterId) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT 
        c.id, c.name, c.credit, c.type, 
        g.score, g.teacher, g.exam_date
      FROM grades g
      JOIN courses c ON g.course_id = c.id
      WHERE g.student_id = ? AND g.semester_id = ?
      ORDER BY g.exam_date DESC
    ''', [studentId, semesterId]);
  }

  Future<List<Map<String, dynamic>>> getAllSemesters() async {
    final db = await database;
    return await db.query('semesters', orderBy: 'name DESC');
  }

  Future<bool> validateStudentId(String studentId) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>> getStudentInfo(String studentId) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  Future<Map<String, dynamic>> getGradeAnalysis(String studentId) async {
    final db = await database;
    final grades = await db.rawQuery('''
    SELECT g.score, c.type 
    FROM grades g
    JOIN courses c ON g.course_id = c.id
    WHERE g.student_id = ?
  ''', [studentId]);

    // 修复类型转换问题
    int total = grades.length;
    int passed = grades.where((g) => (g['score'] as int) >= 60).length;
    int excellent = grades.where((g) => (g['score'] as int) >= 90).length;

    Map<String, List<int>> byType = {};
    for (var g in grades) {
      String type = g['type'] as String;
      int score = g['score'] as int;
      byType.putIfAbsent(type, () => []).add(score);
    }

    return {
      'total': total,
      'passed': passed,
      'excellent': excellent,
      'byType': byType.map((k, v) => MapEntry(k, {
        'count': v.length,
        'average': v.reduce((a, b) => a + b) / v.length,
      })),
    };
  }
}