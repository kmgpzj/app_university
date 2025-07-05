import 'package:flutter/material.dart';
import './component/service_component.dart';
class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey()
  ];
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent) {
      setState(() => _currentTabIndex = 3);
      return;
    }

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        if (position.dy <= 100 && position.dy + box.size.height > 100) {
          if (_currentTabIndex != i) {
            setState(() => _currentTabIndex = i);
          }
          break;
        }
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentTabIndex = index);
    _scrollToSection(index);
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: const Text('服务中心'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                tabs: const [
                  Tab(text: '我的服务'),
                  Tab(text: '其它'),
                  Tab(text: '学生服务'),
                  Tab(text: '教职'),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                onTap: _onTabTapped,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    _buildServiceSection('我的服务', '点击右上角[编辑]进行添加'),
                    _buildServiceSection('其它', [
                      _buildServiceItem('查寝', Icons.home),
                      _buildServiceItem('辅导猫助手', Icons.pets),
                      _buildServiceItem('辅导员通知', Icons.notifications),
                      _buildServiceItem('个人信息', Icons.person),
                      _buildServiceItem('活动报名', Icons.event),
                      _buildServiceItem('节假日离返校', Icons.holiday_village),
                      _buildServiceItem('计算机等级考试查询', Icons.computer),
                      _buildServiceItem('普通话等级查询', Icons.mic),
                    ]),
                    _buildServiceSection('学生服务', [
                      _buildServiceItem('查寝', Icons.home),
                      _buildServiceItem('辅导猫助手', Icons.pets),
                      _buildServiceItem('辅导员通知', Icons.notifications),
                      _buildServiceItem('个人信息', Icons.person),
                      _buildServiceItem('活动报名', Icons.event),
                      _buildServiceItem('节假日离返校', Icons.holiday_village),
                      _buildServiceItem('计算机等级考试查询', Icons.computer),
                      _buildServiceItem('普通话等级查询', Icons.mic),
                    ]),
                    _buildServiceSection('教职', [
                      _buildServiceItem('查寝', Icons.home),
                      _buildServiceItem('辅导猫助手', Icons.pets),
                      _buildServiceItem('辅导员通知', Icons.notifications),
                      _buildServiceItem('个人信息', Icons.person),
                      _buildServiceItem('活动报名', Icons.event),
                      _buildServiceItem('节假日离返校', Icons.holiday_village),
                      _buildServiceItem('计算机等级考试查询', Icons.computer),
                      _buildServiceItem('普通话等级查询', Icons.mic),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String title, IconData icon) {
    return InkWell(
      onTap: () {
        // 根据不同的服务项跳转到对应页面
        switch (title) {
          case '查寝':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DormCheckPage()),
            );
            break;
          case '辅导猫助手':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TutorCatPage()),
            );
            break;
          case '辅导员通知':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TutorNoticePage()),
            );
            break;
          case '个人信息':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PersonalInfoPage()),
            );
            break;
          case '活动报名':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ActivityRegistrationPage()),
            );
            break;
          case '节假日离返校':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HolidayLeavePage()),
            );
            break;
          case '计算机等级考试查询':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComputerExamPage()),
            );
            break;
          case '普通话等级查询':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MandarinExamPage()),
            );
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title 功能正在开发中')),
            );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 60,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                height: 0.95,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(String title, dynamic content) {
    return Container(
      key: _sectionKeys[_getIndexByTitle(title)],
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
          const SizedBox(height: 16),
          if (content is String)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: Text(content)),
            )
          else if (content is List<Widget>)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              mainAxisSpacing: 25,  // 增加垂直间距
              crossAxisSpacing: 5,  // 增加水平间距
              children: content,
            ),
        ],
      ),
    );
  }

  int _getIndexByTitle(String title) {
    switch (title) {
      case '我的服务': return 0;
      case '其它': return 1;
      case '学生服务': return 2;
      case '教职': return 3;
      default: return 0;
    }
  }
}