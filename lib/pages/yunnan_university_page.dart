import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/live_broadcast.dart';
import 'component/course_edit_page.dart';
import 'component/grade_query_page.dart';
import 'component/leave_application.dart';
import 'component/timetable.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 格式化浏览量显示
  String _formatViews(dynamic views) {
    if (views is int) {
      return views >= 10000 ? '${(views/10000).toStringAsFixed(1)}万' : '$views';
    } else if (views is String) {
      return views;
    }
    return '0';
  }

  // 课表跳转方法
  void _navigateToTimetable() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimetablePage()),
    );
  }

  //请假跳转
  void _navigateToLeaveApplication() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaveApplicationPage()),
    );
  }

// 添加跳转方法
  void _navigateToGradeQuery() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GradeQueryPage()),
    );
  }

  // 快键功能按钮组件（修改为必选参数）
  Widget _buildQuickAction(String title, IconData icon, {required VoidCallback onPressed}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          width: 50,
          height: 50,
          child: IconButton(
            icon: Icon(icon, size: 30, color: Colors.blue),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  // 显示更多菜单
  void _showMoreMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'add',
          child: Row(
            children: const [
              Icon(Icons.add, size: 20),
              SizedBox(width: 8),
              Text('添加直播预告'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 8),
              Text('设置'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'add') {
        _showAddBroadcastDialog();
      } else if (value == 'settings') {
        // 处理设置逻辑
      }
    });
  }

  // 添加直播预告对话框
  void _showAddBroadcastDialog() {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加直播预告'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '标题'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: '地点'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: '日期'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: '时间'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final newBroadcast = LiveBroadcast(
                title: titleController.text,
                location: locationController.text,
                date: dateController.text,
                time: timeController.text,
                views: 0,
                postDate: DateTime.now().toString().substring(0, 10),
                imageUrl: 'lib/assets/images/p1.jpg',
              );

              await DatabaseHelper.instance.insertLiveBroadcast(newBroadcast);
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 定义深蓝色颜色常量
    final Color darkBlue = const Color(0xFF1976D2); // 使用Material Design深蓝色
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: const Text('云南大学', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 头部蓝色区域
            Container(
              color: darkBlue,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索应用名称/学工号/姓名等',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickAction('我的课表', Icons.calendar_today, onPressed: _navigateToTimetable),
                        _buildQuickAction('请假', Icons.edit_note, onPressed: _navigateToLeaveApplication),
                        _buildQuickAction('成绩查询', Icons.grade, onPressed: _navigateToGradeQuery),
                        _buildQuickAction('更多', Icons.more_horiz, onPressed: () {
                          _showMoreMenu(context);
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // 中部内容区域（带重叠效果）
            Transform.translate(
              offset: const Offset(0, -15), // 上移20像素实现重叠
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20), // 补偿布局偏移

                    // 宣传图片
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        height: 150,
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('lib/assets/images/p1.jpg'),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '欢迎来到云南大学',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '探索美丽校园',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xE6FFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 推荐内容标题
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '推荐内容',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // 直播列表
                    FutureBuilder<List<LiveBroadcast>>(
                      future: DatabaseHelper.instance.getAllLiveBroadcasts(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text('暂无直播预告，点击右下角+号添加'),
                          );
                        }

                        return Column(
                          children: snapshot.data!.map((broadcast) => Dismissible(
                            key: Key(broadcast.id.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              bool? result = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('确认删除'),
                                  content: const Text('确定要删除这条直播预告吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('删除'),
                                    ),
                                  ],
                                ),
                              );
                              return result;
                            },
                            onDismissed: (_) async {
                              await DatabaseHelper.instance.deleteLiveBroadcast(broadcast.id!);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已删除直播预告')));
                            },
                            child: GestureDetector(
                              onTap: () async {
                                await DatabaseHelper.instance.updateViews(
                                    broadcast.id!,
                                    broadcast.views + 1
                                );
                                setState(() {});
                              },
                              child: Card(
                                elevation: 4,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                      child: Text(
                                        broadcast.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(0),
                                        bottom: Radius.circular(0),
                                      ),
                                      child: Image.asset(
                                        broadcast.imageUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.remove_red_eye, size: 16),
                                              const SizedBox(width: 4),
                                              Text(_formatViews(broadcast.views)),
                                            ],
                                          ),
                                          Text(broadcast.postDate),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBroadcastDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}