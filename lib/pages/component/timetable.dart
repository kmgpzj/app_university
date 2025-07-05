import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../models/course.dart';
import '../../database/course_db.dart';
import 'course_edit_page.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({Key? key}) : super(key: key);

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  late Future<List<Course>> _coursesFuture;
  final double _timeColumnWidth = 50.0;
  final double _courseCellHeight = 60.0;
  final double _dayColumnWidth = 80.0;
  final int _maxPeriods = 12;
  final int _daysInWeek = 7;
  bool _hasInitializedDemoData = false;

  @override
  void initState() {
    super.initState();
    _refreshCourses();
    _initializeDemoData();
  }

  Future<void> _initializeDemoData() async {
    if (!_hasInitializedDemoData) {
      final existingCourses = await CourseDatabase.instance.readAllCourses();
      if (existingCourses.isEmpty) {
        await _addDemoCourses();
        setState(() {
          _hasInitializedDemoData = true;
          _refreshCourses();
        });
      }
    }
  }

  Future<void> _addDemoCourses() async {
    final demoCourses = [
      Course(
        id: '1',
        name: '高等数学',
        teacher: '张教授',
        classroom: '逸夫楼201',
        dayOfWeek: 1,
        startTime: 1,
        endTime: 2,
        weeks: '1-16周',
        color: '#4285F4',
      ),
      Course(
        id: '2',
        name: '大学英语',
        teacher: '李老师',
        classroom: '外语楼105',
        dayOfWeek: 2,
        startTime: 3,
        endTime: 4,
        weeks: '1-16周',
        color: '#EA4335',
      ),
      Course(
        id: '3',
        name: '数据结构',
        teacher: '王教授',
        classroom: '计算机中心302',
        dayOfWeek: 3,
        startTime: 5,
        endTime: 7,
        weeks: '1-8,10-16周',
        color: '#FBBC05',
      ),
      Course(
        id: '4',
        name: '体育(篮球)',
        teacher: '赵教练',
        classroom: '东区体育馆',
        dayOfWeek: 4,
        startTime: 8,
        endTime: 9,
        weeks: '1-16周(单周)',
        color: '#34A853',
      ),
      Course(
        id: '5',
        name: '操作系统',
        teacher: '刘教授',
        classroom: '计算机中心401',
        dayOfWeek: 5,
        startTime: 1,
        endTime: 2,
        weeks: '1-16周',
        color: '#673AB7',
      ),
      Course(
        id: '6',
        name: '艺术史',
        teacher: '陈教授',
        classroom: '人文楼203',
        dayOfWeek: 6,
        startTime: 3,
        endTime: 4,
        weeks: '1-8周',
        color: '#FF9800',
      ),
    ];

    for (var course in demoCourses) {
      await CourseDatabase.instance.create(course);
    }
  }

  void _refreshCourses() {
    setState(() {
      _coursesFuture = CourseDatabase.instance.readAllCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('课程表'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditPage(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshCourses();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('课程表已刷新')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: _coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('错误: ${snapshot.error}'));
          }

          final courses = snapshot.data ?? [];
          return _buildTimetable(courses);
        },
      ),
    );
  }

  Widget _buildTimetable(List<Course> courses) {
    final totalWidth = _timeColumnWidth + (_dayColumnWidth * _daysInWeek);

    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: totalWidth,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWeekHeader(),
                _buildTimetableContent(courses),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekHeader() {
    List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    return Container(
      height: 40,
      child: Row(
        children: [
          Container(
            width: _timeColumnWidth,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: const Text('时间'),
          ),
          ...weekdays.map((day) => Container(
            width: _dayColumnWidth,
            color: Colors.grey[200],
            alignment: Alignment.center,
            child: Text(day),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildTimetableContent(List<Course> courses) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(_maxPeriods, (index) => Container(
            width: _timeColumnWidth,
            height: _courseCellHeight,
            color: Colors.grey[100],
            alignment: Alignment.center,
            child: Text('${index + 1}'),
          )),
        ),
        ...List.generate(_daysInWeek, (dayIndex) {
          return SizedBox(
            width: _dayColumnWidth,
            child: Column(
              children: List.generate(_maxPeriods, (periodIndex) {
                final dayCourses = courses.where((c) => c.dayOfWeek == dayIndex + 1).toList();
                final course = _findCourseAtPeriod(dayCourses, periodIndex + 1);

                if (course != null) {
                  if (course.startTime == periodIndex + 1) {
                    return _buildCourseCell(course);
                  } else {
                    return const SizedBox.shrink();
                  }
                } else {
                  return Container(
                    height: _courseCellHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                  );
                }
              }),
            ),
          );
        }),
      ],
    );
  }

  Course? _findCourseAtPeriod(List<Course> courses, int period) {
    for (var course in courses) {
      if (course.startTime <= period && course.endTime >= period) {
        return course;
      }
    }
    return null;
  }

  Widget _buildCourseCell(Course course) {
    final span = course.endTime - course.startTime + 1;

    return GestureDetector(
      onTap: () => _navigateToEditPage(context, course),
      child: Container(
        height: _courseCellHeight * span,
        decoration: BoxDecoration(
          color: HexColor(course.color),
          border: Border.all(color: Colors.white, width: 1),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              course.teacher,
              style: const TextStyle(fontSize: 10, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              course.classroom,
              style: const TextStyle(fontSize: 10, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              course.weeks,
              style: const TextStyle(fontSize: 10, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToEditPage(BuildContext context, [Course? course]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseEditPage(course: course),
      ),
    );

    if (result != null) {
      _refreshCourses();
    }
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}