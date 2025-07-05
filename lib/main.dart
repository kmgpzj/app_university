/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:untitled1/pages/page_kexue/main.dart';
import 'package:untitled1/pages/page_xuqian/pages/message_page.dart';
import 'package:untitled1/pages/page_xuqian/pages/profile_page.dart';
import 'package:untitled1/pages/service_center_page.dart';
import 'package:untitled1/pages/yunnan_university_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
void main() {
  // 修改为使用kIsWeb判断
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper.initialize();
  runApp(YunnanUniversityApp());
}

class YunnanUniversityApp extends StatelessWidget {
  const YunnanUniversityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      title: '云南大学',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MessagePage(),
    const ServicePage(),
    const CampusBlogApp(),
    const ProfilePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: '今日',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: '讯息',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: '服务',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '校园',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}*/

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:untitled1/pages/page_kexue/main.dart';
import 'package:untitled1/pages/page_xuqian/pages/auth/chat_detail_page.dart';
import 'package:untitled1/pages/page_xuqian/pages/auth/login_page.dart';
import 'package:untitled1/pages/page_xuqian/pages/message_page.dart';
import 'package:untitled1/pages/page_xuqian/pages/profile_page.dart';
import 'package:untitled1/pages/service_center_page.dart';
import 'package:untitled1/pages/yunnan_university_page.dart';

import 'services/user_service.dart';
import 'services/chat_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserService.initDefaultCredentials();
  await ChatService.initDefaultChat();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '校园通',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => const MainWrapper(),
        // 修改聊天详情页路由，使用正确的参数
        '/chat': (context) {
          // 这里可以传递默认值或从其他地方获取数据
          return ChatDetailPage(
            contact: {
              'id': 'default',
              'name': '默认用户',
              'avatar': 'lib/assets/default_avatar.png',
            },
            onMessageSent: () {},
          );
        },
      },
    );
  }
}

// 其他部分保持不变...

/// 认证包装器，用于处理登录状态
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 这里可以添加登录状态检查逻辑
    // 目前直接显示登录页面，登录成功后跳转到主界面
    return const LoginPage(lastLoginTime: null);
  }
}

/// 主界面包装器
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0; // 默认显示讯息页面

  final List<Widget> _pages = const [
    HomePage(),
    MessagePage(),
    ServicePage(),
    CampusBlogApp(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('今日', 0),
          _buildNavItem('讯息', 1),
          _buildNavItem('服务', 2),
          _buildNavItem('校园', 3),
          _buildNavItem('我的', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: _currentIndex == index ? FontWeight.bold : FontWeight.normal,
              color: _currentIndex == index ? Colors.blue : Colors.grey,
            ),
          ),
          if (_currentIndex == index)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 20,
              color: Colors.blue,
            )
        ],
      ),
    );
  }
}

/// 占位页面
class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(child: Text(title)),
    );
  }
}