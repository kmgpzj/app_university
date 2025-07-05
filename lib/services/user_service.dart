import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class UserService {
  static const String _userDataKey = 'user_data';
  static const String _userStatusKey = 'user_status';
  static const String _userCredentialsKey = 'user_credentials';

  // 默认账号密码
  static const String _defaultUsername = '123456';
  static const String _defaultPassword = '123456';

  // 初始化默认账号密码
  static Future<void> initDefaultCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_userCredentialsKey)) {
      await prefs.setString(_userCredentialsKey, '$_defaultUsername|$_defaultPassword');
    }
  }

  // 验证登录
  static Future<bool> validateLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final credentials = prefs.getString(_userCredentialsKey);

    if (credentials != null) {
      final parts = credentials.split('|');
      if (parts.length == 2) {
        return username == parts[0] && password == parts[1];
      }
    }

    return username == _defaultUsername && password == _defaultPassword;
  }

  // 验证当前密码
  static Future<bool> validateCurrentPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final credentials = prefs.getString(_userCredentialsKey);

    if (credentials != null) {
      final parts = credentials.split('|');
      if (parts.length == 2) {
        return password == parts[1];
      }
    }

    return password == _defaultPassword;
  }

  // 更新密码
  static Future<void> updatePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final credentials = prefs.getString(_userCredentialsKey);

    if (credentials != null) {
      final parts = credentials.split('|');
      if (parts.length == 2) {
        await prefs.setString(_userCredentialsKey, '${parts[0]}|$newPassword');
        return;
      }
    }

    await prefs.setString(_userCredentialsKey, '$_defaultUsername|$newPassword');
  }

  // 登出
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // 只清除登录状态，保留用户数据
    await prefs.remove(_userStatusKey);
    // 记录登出时间
    await prefs.setString('last_logout_time', DateTime.now().millisecondsSinceEpoch.toString());
  }

  // 获取用户数据
  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_userDataKey);

    if (json != null) {
      try {
        final parts = json.split('|');
        if (parts.length >= 4) {
          final data = {
            'nickname': parts[0],
            'school': parts[1],
            'avatar': parts[2],
            'bio': parts[3],
          };

          // 检查自定义头像文件是否存在
          if (data['avatar'] != null &&
              !data['avatar']!.startsWith('lib/assets/') &&
              await File(data['avatar']!).exists()) {
            return data;
          }

          // 如果自定义头像不存在，回退到默认头像
          return {
            'nickname': parts[0],
            'school': parts[1],
            'avatar': 'lib/assets/default_avatar.png',
            'bio': parts[3],
          };
        }
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }

    // 默认数据
    return {
      'nickname': '聊表心意',
      'school': '云南大学',
      'avatar': 'lib/assets/default_avatar.png',
      'bio': '',
    };
  }

  // 更新用户数据
  static Future<void> updateUserData({
    required String nickname,
    required String bio,
    required String avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final json = '$nickname|云南大学|$avatar|$bio';
    await prefs.setString(_userDataKey, json);
  }


  // 获取用户状态
  static Future<String?> getUserStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userStatusKey);
  }

  // 更新用户状态
  static Future<void> updateUserStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStatusKey, status);
  }

  // 清除缓存
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_userStatusKey);
  }
}