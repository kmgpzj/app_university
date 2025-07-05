class Grade {
  final int? id;
  final String courseCode;
  final String courseName;
  final String academicYear;
  final String semester;
  final String credit;
  final String score;
  final String courseType;
  final String teacher;
  final String remarks;

  Grade({
    this.id,
    required this.courseCode,
    required this.courseName,
    required this.academicYear,
    required this.semester,
    required this.credit,
    required this.score,
    this.courseType = '',
    this.teacher = '',
    this.remarks = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'academicYear': academicYear,
      'semester': semester,
      'credit': credit,
      'score': score,
      'courseType': courseType,
      'teacher': teacher,
      'remarks': remarks,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      courseCode: map['courseCode'],
      courseName: map['courseName'],
      academicYear: map['academicYear'],
      semester: map['semester'],
      credit: map['credit'],
      score: map['score'],
      courseType: map['courseType'] ?? '',
      teacher: map['teacher'] ?? '',
      remarks: map['remarks'] ?? '',
    );
  }
}