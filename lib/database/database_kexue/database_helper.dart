import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Blog {
  int? id;
  String title;
  String content;
  String? imagePath;
  String type;
  int likes;
  DateTime createTime;

  Blog({
    this.id,
    required this.title,
    required this.content,
    this.imagePath,
    required this.type,
    this.likes = 0,
    required this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePath': imagePath,
      'type': type,
      'likes': likes,
      'createTime': createTime.toIso8601String(),
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePath: map['imagePath'],
      type: map['type'],
      likes: map['likes'],
      createTime: DateTime.parse(map['createTime']),
    );
  }
}

class Comment {
  int? id;
  int blogId;
  String content;
  DateTime createTime;

  Comment({
    this.id,
    required this.blogId,
    required this.content,
    required this.createTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blogId': blogId,
      'content': content,
      'createTime': createTime.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      blogId: map['blogId'],
      content: map['content'],
      createTime: DateTime.parse(map['createTime']),
    );
  }
}

class DatabaseHelper {
  static final _databaseName = "campus_blog.db";
  static final _databaseVersion = 6; // 版本号更新

  static final tableBlogs = 'blogs';
  static final tableComments = 'comments';
  static final columnId = 'id';

  // Blogs表字段
  static final columnTitle = 'title';
  static final columnContent = 'content';
  static final columnImagePath = 'imagePath';
  static final columnType = 'type';
  static final columnLikes = 'likes';
  static final columnCreateTime = 'createTime';

  // Comments表字段
  static final columnBlogId = 'blogId';
  static final columnCommentContent = 'content';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableBlogs (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTitle TEXT NOT NULL,
        $columnContent TEXT NOT NULL,
        $columnImagePath TEXT,
        $columnType TEXT NOT NULL,
        $columnLikes INTEGER DEFAULT 0,
        $columnCreateTime TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableComments (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnBlogId INTEGER NOT NULL,
        $columnCommentContent TEXT NOT NULL,
        $columnCreateTime TEXT NOT NULL,
        FOREIGN KEY ($columnBlogId) REFERENCES $tableBlogs($columnId)
      )
    ''');

    // 创建索引提高查询性能
    await db.execute('CREATE INDEX idx_blogs_type ON $tableBlogs($columnType)');
    await db.execute('CREATE INDEX idx_blogs_likes ON $tableBlogs($columnLikes)');
    await db.execute('CREATE INDEX idx_comments_blogId ON $tableComments($columnBlogId)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableBlogs ADD COLUMN $columnImagePath TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $tableBlogs DROP COLUMN imagePaths');
    }
    if (oldVersion < 6) {
      // 添加新版本的升级逻辑
      await db.execute('CREATE INDEX idx_blogs_type ON $tableBlogs($columnType)');
      await db.execute('CREATE INDEX idx_blogs_likes ON $tableBlogs($columnLikes)');
      await db.execute('CREATE INDEX idx_comments_blogId ON $tableComments($columnBlogId)');
    }
  }

  Future<int> insertBlog(Blog blog) async {
    final db = await database;
    return await db.insert(tableBlogs, blog.toMap());
  }

  Future<List<Blog>> getBlogsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBlogs,
      where: '$columnType = ?',
      whereArgs: [type],
      orderBy: '$columnCreateTime DESC',
    );
    return List.generate(maps.length, (i) => Blog.fromMap(maps[i]));
  }

  Future<List<Blog>> getHotBlogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT b.*, 
             (SELECT COUNT(*) FROM $tableComments c WHERE c.$columnBlogId = b.$columnId) as commentCount
      FROM $tableBlogs b
      ORDER BY b.$columnLikes DESC, commentCount DESC, b.$columnCreateTime DESC
      LIMIT 20
    ''');
    return List.generate(maps.length, (i) => Blog.fromMap(maps[i]));
  }

  Future<List<Blog>> getAllBlogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableBlogs,
      orderBy: '$columnCreateTime DESC',
    );
    return List.generate(maps.length, (i) => Blog.fromMap(maps[i]));
  }

  Future<int> likeBlog(int id) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE $tableBlogs SET $columnLikes = $columnLikes + 1 WHERE $columnId = ?',
      [id],
    );
  }

  Future<int> insertComment(Comment comment) async {
    final db = await database;
    return await db.insert(tableComments, comment.toMap());
  }

  Future<List<Comment>> getCommentsByBlog(int blogId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableComments,
      where: '$columnBlogId = ?',
      whereArgs: [blogId],
      orderBy: '$columnCreateTime DESC',
    );
    return List.generate(maps.length, (i) => Comment.fromMap(maps[i]));
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }


  // database_helper.dart
// 在 DatabaseHelper 类中添加以下方法：

  Future<int> updateBlog(Blog blog) async {
    final db = await database;
    return await db.update(
      tableBlogs,
      blog.toMap(),
      where: '$columnId = ?',
      whereArgs: [blog.id],
    );
  }

  Future<int> deleteBlog(int id) async {
    final db = await database;
    // 先删除相关评论
    await db.delete(
      tableComments,
      where: '$columnBlogId = ?',
      whereArgs: [id],
    );
    // 再删除博客
    return await db.delete(
      tableBlogs,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

}