import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/leave_application_db.dart';
import 'leave_add_page.dart';

class LeaveApplicationPage extends StatefulWidget {
  const LeaveApplicationPage({super.key});
  @override
  State<LeaveApplicationPage> createState() => _LeaveApplicationPageState();
}

class _LeaveApplicationPageState extends State<LeaveApplicationPage> {
  List<Map<String, dynamic>> _leaveRecords = [];
  bool _isLoading = true;
  String _filterStatus = '全部';
  final _studentIdController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadLeaveRecords();
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadLeaveRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await DatabaseHelper.instance.getLeaveApplications();
      setState(() {
        _leaveRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载失败: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _searchByStudentId() async {
    if (_studentIdController.text.isEmpty) {
      await _loadLeaveRecords();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final records = await DatabaseHelper.instance
          .getLeaveApplicationsByStudent(_studentIdController.text);
      setState(() {
        _leaveRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('查询失败: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '已批准':
        return const Color(0xFF4CAF50);
      case '已拒绝':
        return const Color(0xFFF44336);
      case '待审核':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  void _navigateToAddLeave() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaveAddPage()),
    ).then((_) => _loadLeaveRecords());
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _filterStatus == '全部'
        ? _leaveRecords
        : _leaveRecords.where((r) => r['status'] == _filterStatus).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '请假记录',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: _loadLeaveRecords,
            tooltip: '刷新',
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                // 搜索栏
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(10),
                    child: TextField(
                      controller: _studentIdController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        labelText: '输入学号查询',
                        hintText: '请输入学生学号',
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        suffixIcon: _studentIdController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _studentIdController.clear();
                            _searchByStudentId();
                          },
                        )
                            : null,
                      ),
                      onSubmitted: (_) => _searchByStudentId(),
                    ),
                  ),
                ),

                // 筛选标签
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildFilterChip('全部'),
                      _buildFilterChip('待审核'),
                      _buildFilterChip('已批准'),
                      _buildFilterChip('已拒绝'),
                    ],
                  ),
                ),

                const Divider(height: 1, thickness: 1),

                // 记录列表
                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                      : filteredRecords.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无请假记录',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecords.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final record = filteredRecords[index];
                      return _buildRecordCard(record);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 底部请假按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _navigateToAddLeave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
              child: const Text(
                '我要请假',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(status),
        selected: _filterStatus == status,
        onSelected: (selected) {
          setState(() => _filterStatus = selected ? status : '全部');
        },
        selectedColor: _getStatusColor(status).withOpacity(0.2),
        labelStyle: TextStyle(
          color: _filterStatus == status ? _getStatusColor(status) : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _filterStatus == status
                ? _getStatusColor(status)
                : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // 点击卡片可以查看详情
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${record['name']} (${record['studentId']})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(record['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(record['status']),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      record['status'],
                      style: TextStyle(
                        color: _getStatusColor(record['status']),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildInfoRow('请假类型', record['leaveType']),
              _buildInfoRow(
                '请假时间',
                '${_formatDate(record['startDate'])} 至 ${_formatDate(record['endDate'])}',
              ),
              _buildInfoRow('提交时间', _formatDate(record['submitTime'])),

              const SizedBox(height: 8),

              Text(
                '请假原因: ${record['reason']}',
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (record['reviewer'] != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow('审核人', record['reviewer']),
                _buildInfoRow('审核时间', _formatDate(record['reviewTime'])),
                if (record['reviewComment'] != null)
                  Text(
                    '审核意见: ${record['reviewComment']}',
                    style: const TextStyle(fontSize: 14),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}