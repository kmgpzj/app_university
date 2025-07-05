import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

import '../../../../services/user_service.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  String _avatarPath = 'lib/assets/default_avatar.png';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _bioController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await UserService.getUserData();
    setState(() {
      _nicknameController.text = userData['nickname'];
      _bioController.text = userData['bio'] ?? '';
      _avatarPath = userData['avatar'] ?? 'lib/assets/default_avatar.png';
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        String avatarToSave = _avatarPath;

        // 如果有新选择的图片，复制到应用目录
        if (_selectedImage != null) {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.png';
          final savedImage = await _selectedImage!.copy('${appDir.path}/$fileName');
          avatarToSave = savedImage.path;
        }

        await UserService.updateUserData(
          nickname: _nicknameController.text,
          bio: _bioController.text,
          avatar: avatarToSave,
        );

        if (mounted) {
          Navigator.pop(context, true); // 返回时带参数表示需要刷新
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('保存失败: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _changeAvatar() async {
    // 检查并请求权限
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('需要相册访问权限')),
        );
      }
      return;
    }

    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _avatarPath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _changeAvatar,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : _avatarPath.startsWith('lib/assets/')
                      ? AssetImage(_avatarPath) as ImageProvider
                      : FileImage(File(_avatarPath)) as ImageProvider,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '昵称',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入昵称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: '个性签名',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text(
                '学校信息',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '云南大学',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}