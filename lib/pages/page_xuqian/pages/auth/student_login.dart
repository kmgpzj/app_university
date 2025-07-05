import 'package:flutter/material.dart';

import 'dart:math';

import '../../../../services/user_service.dart';
class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  State<StudentLoginPage> createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  String _captchaCode = _generateCaptcha();
  bool _rememberMe = false;

  static String _generateCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void _refreshCaptcha() {
    setState(() {
      _captchaCode = _generateCaptcha();
    });
  }

  Future<void> _handleLogin(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _studentIdController.text;
    final password = _passwordController.text;
    final captcha = _captchaController.text;

    // 验证验证码
    if (captcha != _captchaCode) {
      _showErrorDialog(context, '验证码不正确');
      return;
    }

    // 从数据库验证账号密码
    final isValid = await UserService.validateLogin(username, password);
    if (!isValid) {
      _showErrorDialog(context, '账号或密码不正确');
      return;
    }

    // 登录成功，跳转到主页面
    Navigator.pushReplacementNamed(context, '/main');
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('登录失败'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学工号登录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 大学logo和标题
                Center(
                  child: Image.asset(
                    'lib/assets/university_logo.png',
                    height: 120,
                  ),
                ),

                // 登录容器
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // 学号输入框
                      _buildInputField(
                        controller: _studentIdController,
                        hintText: '请输入学号/工号',
                        iconPath: 'lib/assets/id_icon.png',
                        isFirst: true,
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      // 密码输入框
                      _buildInputField(
                        controller: _passwordController,
                        hintText: '请输入密码',
                        iconPath: 'lib/assets/password_icon.png',
                        isPassword: true,
                      ),
                      const Divider(height: 1, color: Colors.grey),
                      // 验证码输入框
                      _buildCaptchaField(),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 账号操作行（含7天免登录复选框）
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 7天免登录复选框
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Text('7天免登录'),
                        const SizedBox(width: 16),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('账号激活'),
                    ),
                    const SizedBox(width: 8),
                    const VerticalDivider(width: 1, thickness: 1),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {},
                      child: const Text('账号解禁'),
                    ),
                  ],
                ),

                // 忘记密码
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('忘记密码'),
                  ),
                ),
                const SizedBox(height: 5),

                // 登录按钮
                SizedBox(
                  width: double.infinity,
                  height: 36 * 1.5,
                  child: ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    child: const Text('登录'),
                  ),
                ),
                const SizedBox(height: 15),

                // 验证码登录选项
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 32,
                              width: 32,
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'lib/assets/phone1_icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('验证码登录'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required String iconPath,
    bool isPassword = false,
    bool isFirst = false,
  }) {
    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Container(
            height: 30,
            width: 30,
            padding: const EdgeInsets.all(5),
            child: Image.asset(iconPath, fit: BoxFit.contain),
          ),
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '请输入内容';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCaptchaField() {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _captchaController,
              decoration: InputDecoration(
                prefixIcon: Container(
                  height: 30,
                  width: 30,
                  padding: const EdgeInsets.all(5),
                  child: Image.asset('lib/assets/captcha_icon.png', fit: BoxFit.contain),
                ),
                hintText: '请输入验证码',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入验证码';
                }
                return null;
              },
            ),
          ),
          GestureDetector(
            onTap: _refreshCaptcha,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              alignment: Alignment.center,
              child: Text(
                _captchaCode,
                style: const TextStyle(
                  fontSize: 20,
                  letterSpacing: 3,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}