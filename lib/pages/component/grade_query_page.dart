import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/grade_db.dart';

class GradeQueryPage extends StatefulWidget {
  const GradeQueryPage({super.key});

  @override
  State<GradeQueryPage> createState() => _GradeQueryPageState();
}

class _GradeQueryPageState extends State<GradeQueryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _courses = [];
  int? _selectedSemesterId;
  bool _isLoading = false;
  final TextEditingController _studentIdController = TextEditingController();
  String _currentStudentId = '';
  bool _hasEnteredStudentId = false;
  String? _studentName;
  String? _studentDepartment;
  Map<String, dynamic> _gradeAnalysis = {};

  @override
  void initState() {
    super.initState();
    _loadSemesters();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _loadSemesters() async {
    setState(() {
      _isLoading = true;
    });

    final semesters = await _dbHelper.getAllSemesters();

    setState(() {
      _semesters = semesters;
      if (semesters.isNotEmpty) {
        _selectedSemesterId = semesters.first['id'] as int;
      }
      _isLoading = false;
    });
  }

  Future<void> _loadStudentGrades() async {
    if (_selectedSemesterId == null) return;

    setState(() {
      _isLoading = true;
    });

    final grades = await _dbHelper.getStudentGrades(
        _currentStudentId,
        _selectedSemesterId!
    );

    final studentInfo = await _dbHelper.getStudentInfo(_currentStudentId);
    final analysis = await _dbHelper.getGradeAnalysis(_currentStudentId);

    setState(() {
      _courses = grades;
      _studentName = studentInfo['name'] as String?;
      _studentDepartment = studentInfo['department'] as String?;
      _gradeAnalysis = analysis;
      _isLoading = false;
    });
  }

  double _calculateGPA() {
    double totalCredit = 0;
    double totalGradePoint = 0;

    for (var course in _courses) {
      double credit = course['credit'] as double;
      int score = course['score'] as int;

      double gradePoint = _convertScoreToGradePoint(score);
      totalCredit += credit;
      totalGradePoint += credit * gradePoint;
    }

    return totalCredit > 0 ? totalGradePoint / totalCredit : 0.0;
  }

  double _convertScoreToGradePoint(int score) {
    if (score >= 90) return 4.0;
    if (score >= 85) return 3.7;
    if (score >= 82) return 3.3;
    if (score >= 78) return 3.0;
    if (score >= 75) return 2.7;
    if (score >= 72) return 2.3;
    if (score >= 68) return 2.0;
    if (score >= 64) return 1.5;
    if (score >= 60) return 1.0;
    return 0.0;
  }

  String _getGradeLevel(int score) {
    if (score >= 90) return '优秀';
    if (score >= 80) return '良好';
    if (score >= 70) return '中等';
    if (score >= 60) return '及格';
    return '不及格';
  }

  Future<void> _queryStudentGrades() async {
    if (_studentIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入学号')),
      );
      return;
    }

    final isValid = await _dbHelper.validateStudentId(_studentIdController.text);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('学号不存在，请重新输入')),
      );
      return;
    }

    setState(() {
      _currentStudentId = _studentIdController.text;
      _hasEnteredStudentId = true;
    });

    await _loadStudentGrades();
  }

  @override
  Widget build(BuildContext context) {
    final gpa = _calculateGPA();
    final totalCredits = _courses.fold(
        0.0,
            (sum, course) => sum + (course['credit'] as double)
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('成绩查询系统'),
        centerTitle: true,
        actions: [
          if (_hasEnteredStudentId)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadStudentGrades,
            ),
        ],
      ),
      body: _hasEnteredStudentId
          ? Column(
        children: [
          // 学生信息卡片
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '$_studentName ($_currentStudentId)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('学院/专业: $_studentDepartment'),
                  const SizedBox(height: 8),
                  Text(
                    '总课程: ${_gradeAnalysis['total'] ?? 0} '
                        '通过: ${_gradeAnalysis['passed'] ?? 0} '
                        '优秀: ${_gradeAnalysis['excellent'] ?? 0}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 学期选择器
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int>(
              value: _selectedSemesterId,
              decoration: const InputDecoration(
                labelText: '选择学期',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              items: _semesters.map((semester) {
                return DropdownMenuItem<int>(
                  value: semester['id'] as int,
                  child: Text(semester['name'] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSemesterId = value;
                });
                _loadStudentGrades();
              },
            ),
          ),

          // 成绩概览卡片
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatisticItem('平均绩点', gpa.toStringAsFixed(2)),
                      _buildStatisticItem('总学分', totalCredits.toStringAsFixed(1)),
                      _buildStatisticItem('课程数', _courses.length.toString()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: gpa / 4.0,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      gpa >= 3.5
                          ? Colors.green
                          : gpa >= 2.5
                          ? Colors.blue
                          : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPA: ${gpa.toStringAsFixed(2)}/4.0',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // 成绩列表标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '课程成绩',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // 成绩列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _courses.isEmpty
                ? const Center(child: Text('该学期暂无成绩数据'))
                : RefreshIndicator(
              onRefresh: _loadStudentGrades,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  final course = _courses[index];
                  final score = course['score'] as int;
                  final gradeLevel = _getGradeLevel(score);
                  final date = DateFormat('yyyy-MM-dd').format(
                    DateTime.parse(course['exam_date'] as String),
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      title: Text(
                        course['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${course['type']} · ${course['teacher']}'),
                          Text('学分: ${course['credit']} · 考试日期: $date'),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: score >= 90
                                  ? Colors.green
                                  : score >= 80
                                  ? Colors.blue
                                  : score >= 60
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            gradeLevel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      )
          : Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                const Text(
                  '学生成绩查询系统',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '请输入学号登录查询成绩',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _studentIdController,
                    decoration: const InputDecoration(
                      labelText: '学号',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _queryStudentGrades,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '查询',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // 显示测试学号提示
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('测试学号'),
                        content: const Text('可用测试学号: 20230001 到 20230010'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('确定'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('忘记学号?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}