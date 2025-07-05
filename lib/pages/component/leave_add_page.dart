import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/leave_application_db.dart';
import 'leave_application.dart';

class LeaveAddPage extends StatefulWidget {
  const LeaveAddPage({super.key});

  @override
  State<LeaveAddPage> createState() => _LeaveAddPageState();
}

class _LeaveAddPageState extends State<LeaveAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _reasonController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTimeRange? _leaveDateRange;
  String _leaveType = '病假';

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _reasonController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: _leaveDateRange ?? DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 1)),
      ),
    );
    if (picked != null) {
      setState(() => _leaveDateRange = picked);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _submitLeaveApplication() async {
    if (_formKey.currentState!.validate() && _leaveDateRange != null) {
      try {
        await DatabaseHelper.instance.insertLeaveApplication({
          'name': _nameController.text,
          'studentId': _studentIdController.text,
          'leaveType': _leaveType,
          'startDate': _formatDate(_leaveDateRange!.start),
          'endDate': _formatDate(_leaveDateRange!.end),
          'reason': _reasonController.text,
          'phone': _phoneController.text,
          'status': '待审核',
          'submitTime': DateTime.now().toString(),
        });

        if (!mounted) return;

        // 显示提交成功的SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('请假申请已提交'),
            duration: Duration(seconds: 2),
          ),
        );

        // 提交成功后跳转到请假记录页面，并移除当前页面
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LeaveApplicationPage()),
              (route) => false, // 移除所有之前的页面
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('提交失败: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写完整信息并选择请假日期')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('请假申请'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaveApplicationPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? '请输入姓名' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: '学号',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? '请输入学号' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _leaveType,
                decoration: const InputDecoration(
                  labelText: '请假类型',
                  border: OutlineInputBorder(),
                ),
                items: ['病假', '事假', '公假'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _leaveType = value!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDateRange(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '请假时间',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _leaveDateRange == null
                            ? '请选择日期范围'
                            : '${_formatDate(_leaveDateRange!.start)} 至 ${_formatDate(_leaveDateRange!.end)}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: '请假原因',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? '请输入请假原因' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '联系电话',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) return '请输入联系电话';
                  if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                    return '请输入有效的手机号码';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitLeaveApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('提交申请'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}