import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../database/course_db.dart';
import '../../models/course.dart';

class CourseEditPage extends StatefulWidget {
  final Course? course;

  const CourseEditPage({Key? key, this.course}) : super(key: key);

  @override
  _CourseEditPageState createState() => _CourseEditPageState();
}

class _CourseEditPageState extends State<CourseEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _teacherController;
  late TextEditingController _classroomController;
  late TextEditingController _weeksController;
  late int _dayOfWeek;
  late int _startTime;
  late int _endTime;
  Color _currentColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _nameController = TextEditingController(text: course?.name ?? '');
    _teacherController = TextEditingController(text: course?.teacher ?? '');
    _classroomController = TextEditingController(text: course?.classroom ?? '');
    _weeksController = TextEditingController(text: course?.weeks ?? '1-16周');
    _dayOfWeek = course?.dayOfWeek ?? 1;
    _startTime = course?.startTime ?? 1;
    _endTime = course?.endTime ?? 2;
    _currentColor = course != null
        ? HexColor(course.color)
        : Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.course == null ? '添加课程' : '编辑课程'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: '课程名称',
                validator: (v) => v!.isEmpty ? '课程名称不能为空' : null,
              ),
              _buildTextField(
                controller: _teacherController,
                label: '教师姓名',
              ),
              _buildTextField(
                controller: _classroomController,
                label: '教室',
              ),
              _buildWeekdayDropdown(),
              _buildTimeRangePicker(),
              _buildTextField(
                controller: _weeksController,
                label: '上课周数',
                validator: (v) => v!.isEmpty ? '上课周数不能为空' : null,
                hintText: '如: 1-3,5,7-16周',
              ),
              _buildColorPicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCourse,
                child: const Text('保存课程'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
      ),
      validator: validator,
    );
  }

  Widget _buildWeekdayDropdown() {
    return DropdownButtonFormField<int>(
      value: _dayOfWeek,
      decoration: const InputDecoration(labelText: '星期几'),
      items: List.generate(7, (index) => index + 1).map((day) {
        return DropdownMenuItem(
          value: day,
          child: Text('星期$day'),
        );
      }).toList(),
      onChanged: (value) => setState(() => _dayOfWeek = value!),
    );
  }

  Widget _buildTimeRangePicker() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _startTime,
            decoration: const InputDecoration(labelText: '开始节次'),
            items: List.generate(12, (index) => index + 1).map((time) {
              return DropdownMenuItem(
                value: time,
                child: Text('第$time节'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _startTime = value!),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _endTime,
            decoration: const InputDecoration(labelText: '结束节次'),
            items: List.generate(12, (index) => index + 1)
                .where((time) => time >= _startTime)
                .map((time) {
              return DropdownMenuItem(
                value: time,
                child: Text('第$time节'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _endTime = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return ListTile(
      title: const Text('课程颜色'),
      trailing: Icon(Icons.circle, color: _currentColor),
      onTap: () => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('选择颜色'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) => setState(() => _currentColor = color),
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              child: const Text('确定'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      final course = Course(
        id: widget.course?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        teacher: _teacherController.text,
        classroom: _classroomController.text,
        dayOfWeek: _dayOfWeek,
        startTime: _startTime,
        endTime: _endTime,
        weeks: _weeksController.text,
        color: '#${_currentColor.value.toRadixString(16).substring(2)}',
      );

      await CourseDatabase.instance.create(course);
      if (!mounted) return;
      Navigator.pop(context, course);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _classroomController.dispose();
    _weeksController.dispose();
    super.dispose();
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