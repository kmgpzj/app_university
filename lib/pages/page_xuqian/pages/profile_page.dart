import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import '../../../models/models_xuqian/models/profile_item.dart';
import '../../../services/user_service.dart';
import 'auth/edit_profile_page.dart';
import 'auth/settings_page.dart'; // 假设你有一个 settings_page.dart 文件

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _userData;
  late Future<String?> _userStatus;
  bool _isEditingStatus = false;
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _userData = UserService.getUserData();
    _userStatus = UserService.getUserStatus().then((status) {
      _statusController.text = status ?? '';
      return status;
    });
  }

  Future<void> _saveStatus() async {
    if (_statusController.text.isNotEmpty) {
      await UserService.updateUserStatus(_statusController.text);
      setState(() {
        _isEditingStatus = false;
        _userStatus = Future.value(_statusController.text);
      });
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ProfileItem> appItems = [
      ProfileItem(title: '扫一扫'),
      ProfileItem(title: '大学运动'),
      ProfileItem(title: '个人主页'),
      ProfileItem(title: '大学圈记录'),
    ];

    final List<ProfileItem> circleItems = [
      ProfileItem(title: '互动消息'),
      ProfileItem(title: '话题管理'),
    ];

    final List<ProfileItem> settingItems = [
      ProfileItem(title: '个人资料'),
      ProfileItem(title: '消息通知'),
      ProfileItem(title: '通用设置'),
      ProfileItem(title: '帮助反馈'),
      ProfileItem(title: '分享应用'),
      ProfileItem(title: '清除缓存'),
      ProfileItem(title: '关于我们'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: null,
      body: Column(
        children: [
          // 蓝色背景区域
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildProfileLoading();
                }
                if (snapshot.hasError) {
                  return _buildProfileError();
                }
                final userData = snapshot.data ?? {
                  'nickname': '聊表心意',
                  'school': '云南大学',
                  'avatar': 'lib/assets/default_avatar.png',
                  'bio': '',
                };
                return Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: userData['avatar']!.startsWith('lib/assets/')
                              ? AssetImage(userData['avatar']!)
                              : FileImage(File(userData['avatar']!)) as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['nickname'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userData['school'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              if (userData['bio']?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    userData['bio'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code, color: Colors.white, size: 30),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // 状态编辑区域
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isEditingStatus
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _statusController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: '输入你的状态...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _saveStatus(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.blue),
                    onPressed: _saveStatus,
                  ),
                ],
              ),
            )
                : InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _isEditingStatus = true;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: FutureBuilder<String?>(
                  future: _userStatus,
                  builder: (context, snapshot) {
                    final status = snapshot.data;
                    return Row(
                      children: [
                        Icon(
                          status == null ? Icons.add : Icons.edit,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status ?? '添加状态',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 功能列表区域
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 应用分组
                  _buildSection('应用', appItems),
                  const SizedBox(height: 16),
                  // 大学圈分组
                  _buildSection('大学圈', circleItems),
                  const SizedBox(height: 16),
                  // 设置反馈分组
                  _buildSection('设置反馈', settingItems, onItemTap: (index) {
                    if (index == 0) { // 个人资料
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      ).then((shouldRefresh) {
                        if (shouldRefresh == true) {
                          setState(() {
                            _loadUserData();
                          });
                        }
                      });
                    } else if (index == 2) { // 通用设置
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsPage(),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLoading() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 20,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 16,
              color: Colors.white.withOpacity(0.5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileError() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          child: Icon(Icons.error),
        ),
        const SizedBox(width: 16),
        const Text(
          '加载失败',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<ProfileItem> items, {Function(int)? onItemTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 分组标题
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          // 分组内容
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 16),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(item.title),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  if (onItemTap != null) {
                    onItemTap(index);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}