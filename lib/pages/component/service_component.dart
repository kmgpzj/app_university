import 'package:flutter/material.dart';

// 查寝页面
class DormCheckPage extends StatelessWidget {
  const DormCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('查寝记录'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCheckCard('2023-10-15', '优秀', '卫生整洁，物品摆放有序'),
          _buildCheckCard('2023-10-08', '良好', '地面有少量垃圾'),
          _buildCheckCard('2023-10-01', '合格', '床铺整理不够整齐'),
          _buildCheckCard('2023-09-25', '不合格', '存在违规电器', isWarning: true),
        ],
      ),
    );
  }

  Widget _buildCheckCard(String date, String result, String comment, {bool isWarning = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWarning ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isWarning ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: isWarning ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('评语: $comment'),
          ],
        ),
      ),
    );
  }
}

// 辅导猫助手页面
class TutorCatPage extends StatelessWidget {
  const TutorCatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('辅导猫助手'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFunctionCard(
              context,
              '请假申请',
              Icons.edit_document,
              Colors.blue,
              '提交新的请假申请',
            ),
            _buildFunctionCard(
              context,
              '请假记录',
              Icons.history,
              Colors.orange,
              '查看历史请假记录',
            ),
            _buildFunctionCard(
              context,
              '签到打卡',
              Icons.check_circle,
              Colors.green,
              '每日签到打卡',
            ),
            _buildFunctionCard(
              context,
              '通知公告',
              Icons.notifications,
              Colors.purple,
              '查看学校通知',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      String subtitle,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // 这里可以添加导航逻辑
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('进入$title功能')),
          );
        },
      ),
    );
  }
}

// 辅导员通知页面
class TutorNoticePage extends StatelessWidget {
  const TutorNoticePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('辅导员通知'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildNoticeItem(
            '关于国庆假期安排的通知',
            '2023-09-28',
            '各位同学：国庆假期从10月1日至10月7日，请按时返校...',
            true,
          ),
          _buildNoticeItem(
            '班会通知',
            '2023-09-25',
            '本周五下午3点在A201教室召开班会，请全体同学准时参加...',
            false,
          ),
          _buildNoticeItem(
            '奖学金申请通知',
            '2023-09-20',
            '2022-2023学年奖学金申请现已开始，请符合条件的同学...',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String title, String date, String content, bool isImportant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isImportant)
                  const Icon(Icons.error, color: Colors.red, size: 16),
                if (isImportant)
                  const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isImportant ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(content),
          ],
        ),
      ),
    );
  }
}

// 个人信息页面
class PersonalInfoPage extends StatelessWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('个人信息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem('姓名', '张三'),
          _buildInfoItem('学号', '20231001'),
          _buildInfoItem('学院', '计算机学院'),
          _buildInfoItem('专业', '软件工程'),
          _buildInfoItem('班级', '软件2101班'),
          _buildInfoItem('联系电话', '13800138000'),
          _buildInfoItem('邮箱', 'student@example.com'),
          _buildInfoItem('宿舍', '东区3栋502'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// 活动报名页面
class ActivityRegistrationPage extends StatelessWidget {
  const ActivityRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('活动报名'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActivityCard(
            '校园歌手大赛',
            '2023-11-15 18:00',
            '学生活动中心',
            '报名截止: 2023-11-10',
            Icons.music_note,
            Colors.purple,
            isHot: true,
          ),
          _buildActivityCard(
            '编程竞赛',
            '2023-11-20 09:00',
            '计算机学院实验室',
            '限计算机学院学生参加',
            Icons.code,
            Colors.blue,
          ),
          _buildActivityCard(
            '运动会报名',
            '2023-12-05 08:00',
            '学校操场',
            '所有项目均可报名',
            Icons.sports_soccer,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      String title,
      String time,
      String location,
      String desc,
      IconData icon,
      Color color, {
        bool isHot = false,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '热门',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.access_time, time),
            _buildInfoRow(Icons.location_on, location),
            const SizedBox(height: 8),
            Text(desc, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('查看详情'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('立即报名'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// 节假日离返校页面
class HolidayLeavePage extends StatelessWidget {
  const HolidayLeavePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('节假日离返校'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '请在假期开始前1天提交离校申请，返校后及时登记',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHolidayCard(
                  '国庆假期',
                  '2023-10-01 至 2023-10-07',
                  '已提交离校申请',
                  status: 1, // 1-已申请 2-待审核 3-已批准
                ),
                _buildHolidayCard(
                  '中秋假期',
                  '2023-09-29 至 2023-10-01',
                  '已批准 (2023-09-28)',
                  status: 3,
                ),
                _buildHolidayCard(
                  '寒假',
                  '2024-01-15 至 2024-02-25',
                  '未申请',
                  status: 0,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('新建离校申请'),
              onPressed: () {
                // 跳转到申请页面
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayCard(String title, String date, String statusText, {int status = 0}) {
    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.pending;

    switch (status) {
      case 1:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_top;
        break;
      case 2:
        statusColor = Colors.blue;
        statusIcon = Icons.verified;
        break;
      case 3:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(date, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 4),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 计算机等级考试查询页面
class ComputerExamPage extends StatelessWidget {
  const ComputerExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('计算机等级考试'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '全国计算机等级考试(NCRE)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('最近一次考试: 2023年9月'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildExamCard(
                  '二级C语言',
                  '2023-09-23',
                  '合格',
                  '2023100012345',
                ),
                _buildExamCard(
                  '三级网络技术',
                  '2023-03-25',
                  '优秀',
                  '2023100056789',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () {},
              child: const Text('查看历年所有考试成绩'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamCard(String subject, String date, String result, String ticketNo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: result == '优秀' ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    result,
                    style: TextStyle(
                      color: result == '优秀' ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildExamInfoRow('考试日期', date),
            _buildExamInfoRow('准考证号', ticketNo),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              '证书领取: 考试通过后约2个月可到教务处领取',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

// 普通话等级查询页面
class MandarinExamPage extends StatelessWidget {
  const MandarinExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('普通话等级'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '普通话水平测试(PSC)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('测试等级: 三级六等 (一甲、一乙、二甲、二乙、三甲、三乙)'),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTestResultCard(
                  '2023年5月测试',
                  '二级甲等',
                  '89.5分',
                  '2023050012345',
                ),
                _buildTestResultCard(
                  '2022年11月测试',
                  '二级乙等',
                  '83.2分',
                  '2022110056789',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('证书补办申请'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('查看测试大纲'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResultCard(
      String testName,
      String level,
      String score,
      String ticketNo,
      ) {
    Color levelColor = Colors.grey;
    if (level.contains('一甲')) levelColor = Colors.red;
    if (level.contains('一乙')) levelColor = Colors.orange;
    if (level.contains('二甲')) levelColor = Colors.blue;
    if (level.contains('二乙')) levelColor = Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildScoreBox('等级', level, levelColor),
                const SizedBox(width: 16),
                _buildScoreBox('分数', score, Colors.blue),
              ],
            ),
            const SizedBox(height: 12),
            _buildTestInfoRow('准考证号', ticketNo),
            _buildTestInfoRow('证书编号', 'PSK2023050012345'),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
