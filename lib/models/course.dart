class Course {
  final String id;
  final String name;
  final String teacher;
  final String classroom;
  final int dayOfWeek; // 1-7表示周一到周日
  final int startTime; // 开始节次（1-12）
  final int endTime;   // 结束节次
  final String weeks;  // "1-3,5,7-16周"
  final String color;  // 颜色代码如"#FF0000"

  Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.classroom,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.weeks,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacher': teacher,
      'classroom': classroom,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'weeks': weeks,
      'color': color,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      teacher: map['teacher'],
      classroom: map['classroom'],
      dayOfWeek: map['dayOfWeek'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      weeks: map['weeks'],
      color: map['color'],
    );
  }
}