// publish_blog_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../database/database_kexue/database_helper.dart';

class PublishBlogScreen extends StatefulWidget {
  const PublishBlogScreen({super.key});

  @override
  State<PublishBlogScreen> createState() => _PublishBlogScreenState();
}

class _PublishBlogScreenState extends State<PublishBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  File? _image;
  String _selectedType = '校园生活';
  final List<String> _types = ['校园生活', '学习交流', '社团活动', '二手交易'];
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker(); // 显式实例化
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _image = null;
    });
  }

  Future<void> _submitBlog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final blog = Blog(
      title: _titleController.text,
      content: _contentController.text,
      imagePath: _image?.path,
      type: _selectedType,
      createTime: DateTime.now(),
    );

    try {
      await DatabaseHelper.instance.insertBlog(blog);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('博客发布成功'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('发布失败，请重试'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: '重试',
              onPressed: _submitBlog,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('发布博客'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitBlog,
              tooltip: '发布',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: 16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 博客类型选择
              _buildSectionTitle('博客类型'),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField(
                  value: _selectedType,
                  isExpanded: true,
                  items: _types.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16 * textScaleFactor,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 20,
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16 * textScaleFactor,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),

              // 标题输入
              _buildSectionTitle('标题'),
              SizedBox(height: isSmallScreen ? 8 : 12),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration(hintText: '请输入博客标题'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20 * textScaleFactor,
                  fontWeight: FontWeight.w600,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),

              // 内容输入
              _buildSectionTitle('内容'),
              SizedBox(height: isSmallScreen ? 8 : 12),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                minLines: 6,
                decoration: _buildInputDecoration(hintText: '请输入博客内容'),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16 * textScaleFactor,
                  height: 1.6,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入内容';
                  }
                  return null;
                },
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),

              // 图片上传
              _buildSectionTitle('图片'),
              SizedBox(height: isSmallScreen ? 8 : 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image, size: 18),
                    label: Text(
                      '添加图片',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 14 * textScaleFactor,
                      ),
                    ),
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                        vertical: isSmallScreen ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (_image != null) ...[
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete, size: 16),
                      label: Text(
                        '移除',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14 * textScaleFactor,
                        ),
                      ),
                      onPressed: _removeImage,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              Text(
                '支持一张图片（可选）',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: 12 * textScaleFactor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),

              // 图片预览
              if (_image != null)
                Container(
                  width: double.infinity,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: theme.dividerColor.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: theme.disabledColor,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: isSmallScreen ? 24 : 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText}) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.hintColor,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 16 : 18,
      ),
      filled: true,
      fillColor: theme.cardColor,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}