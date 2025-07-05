import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 添加这行导入
import 'package:untitled1/pages/page_xuqian/pages/auth/student_login.dart';

import 'dart:io';

import '../../../../services/user_service.dart'; // 添加这行导入

class LoginPage extends StatelessWidget {
  final DateTime? lastLoginTime;

  const LoginPage({super.key, this.lastLoginTime});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 350;
    final iconSize = screenSize.width * 0.07;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 上部蓝色区域 (40%)
                    Container(
                      height: constraints.maxHeight * 0.4,
                      color: Colors.blue,
                      padding: EdgeInsets.only(
                        top: constraints.maxHeight * 0.05,
                        left: 20,
                        right: 20,
                      ),
                      child: const Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: null,
                          child: Text(
                            '设置',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    // 下部白色区域 (60%)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12.0 : 20.0,
                        ),
                        child: FutureBuilder<Map<String, dynamic>>(
                          future: UserService.getUserData(),
                          builder: (context, snapshot) {
                            final userData = snapshot.data ?? {
                              'avatar': 'lib/assets/default_avatar.png',
                            };

                            return FutureBuilder<String?>(
                              future: SharedPreferences.getInstance()
                                  .then((prefs) => prefs.getString('last_logout_time')),
                              builder: (context, timeSnapshot) {
                                DateTime lastLoginTime = DateTime.now();
                                if (timeSnapshot.hasData && timeSnapshot.data != null) {
                                  lastLoginTime = DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(timeSnapshot.data!));
                                }

                                return Column(
                                  children: [
                                    // 遇到问题链接
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          '遇到问题？',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: isSmallScreen ? 12.0 : 14.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // 欢迎登录标题与头像区域
                                    Column(
                                      children: [
                                        const Text(
                                          '欢迎登录',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Column(
                                          children: [
                                            CircleAvatar(
                                              radius: isSmallScreen ? 32.0 : 40.0,
                                              backgroundColor: Colors.white,
                                              backgroundImage: userData['avatar']!.startsWith('lib/assets/')
                                                  ? AssetImage(userData['avatar']!)
                                                  : FileImage(File(userData['avatar']!)) as ImageProvider,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                '上次登录时间：${_formatDateTime(lastLoginTime)}',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: isSmallScreen ? 12.0 : 14.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: constraints.maxHeight * 0.03),
                                    // 学工号登录按钮
                                    _buildLoginButton(
                                      context,
                                      '学工号登录',
                                      Colors.blue,
                                          () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const StudentLoginPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    SizedBox(height: constraints.maxHeight * 0.02),
                                    _buildLoginButton(
                                      context,
                                      '微信登录',
                                      Colors.green,
                                          () {},
                                    ),
                                    const Spacer(),
                                    // 底部图标区域
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: constraints.maxHeight * 0.02,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: iconSize*1.6,
                                            height: iconSize*1.6,
                                            child: Image.asset('lib/assets/qq_icon.png'),
                                          ),
                                          SizedBox(width: iconSize * 2),
                                          SizedBox(
                                            width: iconSize*1.6,
                                            height: iconSize*1.6,
                                            child: Image.asset('lib/assets/phone_icon.png'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 协议文本
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: constraints.maxHeight * 0.03,
                                      ),
                                      child: _buildAgreementText(isSmallScreen),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginButton(
      BuildContext context,
      String text,
      Color color,
      VoidCallback onPressed,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return SizedBox(
      width: screenWidth * (isSmallScreen ? 0.8 : 0.7),
      height: isSmallScreen ? 48.0 : 54.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 14.0 : 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementText(bool isSmallScreen) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: Colors.grey,
          fontSize: isSmallScreen ? 10.0 : 12.0,
        ),
        children: const [
          TextSpan(text: '我已阅读并同意\n'),
          TextSpan(
            text: '《今日校园使用协议》',
            style: TextStyle(color: Colors.blue),
          ),
          TextSpan(text: '、'),
          TextSpan(
            text: '《今日校园隐私政策》',
            style: TextStyle(color: Colors.blue),
          ),
          TextSpan(text: '和'),
          TextSpan(
            text: '《今日校园隐私政策摘要》',
            style: TextStyle(color: Colors.blue),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}