// main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../database/database_kexue/database_helper.dart';
import 'publish_blog_screen.dart';

class CampusBlogApp extends StatelessWidget {
  const CampusBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '今日校园',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _selectedSubIndex = 0;
  int _selectedCategoryIndex = 0; // 新增：当前选中的子分类索引
  final List<String> _mainCategories = ['推荐', '热门'];
  final Map<String, List<String>> _subCategories = {
    '推荐': ['校园生活', '学习交流', '社团活动', '二手交易'],
    '热门': [],
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日校园'),
        actions: [
          if (_selectedIndex == 0 || _selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.add_box),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PublishBlogScreen(),
                  ),
                );
                if (result == true) {
                  setState(() {
                    _selectedIndex = 0;
                    _selectedSubIndex = 0;
                    _selectedCategoryIndex = 0;
                  });
                }
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mainCategories.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = 0;
                            _selectedSubIndex = index;
                            if (index == 0) {
                              _selectedCategoryIndex = 0; // 重置子分类选择
                            }
                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _mainCategories[index],
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: _selectedSubIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _selectedSubIndex == index
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                            ),
                            if (_selectedSubIndex == index)
                              Container(
                                height: 2,
                                width: isSmallScreen ? 20 : 24,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_selectedSubIndex == 0)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  height: 56,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      final useWrap = maxWidth < 500;

                      return useWrap
                          ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          direction: Axis.horizontal,
                          spacing: isSmallScreen ? 8 : 12,
                          runSpacing: 8,
                          children: _buildSubCategoryChips(isSmallScreen, textScaleFactor),
                        ),
                      )
                          : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _subCategories['推荐']!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 8 : 12,
                            ),
                            child: _buildSubCategoryChip(
                              _subCategories['推荐']![index],
                              index,
                              isSmallScreen,
                              textScaleFactor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              Expanded(
                child: _selectedSubIndex == 0
                    ? BlogListScreen(
                  key: ValueKey('blog_list_${_subCategories['推荐']![_selectedCategoryIndex]}'),
                  type: _subCategories['推荐']![_selectedCategoryIndex],
                  isMainCategory: false,
                )
                    : BlogListScreen(
                  key: const ValueKey('blog_list_hot'),
                  type: '热门',
                  isMainCategory: true,
                ),
              ),
            ],
          ),
          MyBlogsScreen(),
        ],
      ),

    );
  }

  List<Widget> _buildSubCategoryChips(bool isSmallScreen, double textScaleFactor) {
    return List.generate(_subCategories['推荐']!.length, (index) {
      return _buildSubCategoryChip(
        _subCategories['推荐']![index],
        index,
        isSmallScreen,
        textScaleFactor,
      );
    });
  }

  Widget _buildSubCategoryChip(
      String label,
      int index,
      bool isSmallScreen,
      double textScaleFactor,
      ) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: (isSmallScreen ? 12 : 14) * textScaleFactor,
        ),
      ),
      selected: _selectedCategoryIndex == index,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategoryIndex = index;
            _selectedSubIndex = 0; // 确保显示的是推荐分类下的子分类
          });
        }
      },
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      labelPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 4 : 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      backgroundColor: Colors.grey[200],
      elevation: 0,
      pressElevation: 0,
    );
  }
}

// ... [其余代码保持不变] ...


class MyBlogsScreen extends StatefulWidget {
  @override
  _MyBlogsScreenState createState() => _MyBlogsScreenState();
}

class _MyBlogsScreenState extends State<MyBlogsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Blog> _blogs = [];
  List<Blog> _filteredBlogs = [];
  bool _isLoading = false;
  bool _hasError = false;

  String? _selectedType;
  String? _selectedSort;
  final List<String> _types = ['全部', '校园生活', '学习交流', '社团活动', '二手交易'];
  final List<String> _sortOptions = ['最新发布', '最早发布', '最多点赞'];

  @override
  void initState() {
    super.initState();
    _selectedType = '全部';
    _selectedSort = '最新发布';
    _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final blogs = await _dbHelper.getAllBlogs();
      if (!mounted) return;

      setState(() {
        _blogs = blogs;
        _applyFilters();
      });
    } catch (e) {
      debugPrint('加载博客出错: $e');
      if (!mounted) return;

      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    List<Blog> filtered = List.from(_blogs);

    if (_selectedType != null && _selectedType != '全部') {
      filtered = filtered.where((blog) => blog.type == _selectedType).toList();
    }

    switch (_selectedSort) {
      case '最新发布':
        filtered.sort((a, b) => b.createTime.compareTo(a.createTime));
        break;
      case '最早发布':
        filtered.sort((a, b) => a.createTime.compareTo(b.createTime));
        break;
      case '最多点赞':
        filtered.sort((a, b) => b.likes.compareTo(a.likes));
        break;
    }

    setState(() {
      _filteredBlogs = filtered;
    });
  }

  Future<void> _deleteBlog(int id) async {
    try {
      await _dbHelper.deleteBlog(id);
      await _loadBlogs();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除成功')),
      );
    } catch (e) {
      debugPrint('删除博客出错: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('删除失败')),
      );
    }
  }

  Widget _buildBlogItem(Blog blog, BuildContext context, bool isSmallScreen, double screenWidth) {
    return Dismissible(
      key: Key(blog.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("确认删除"),
              content: const Text("确定要删除这篇博客吗？"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("取消"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("删除"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteBlog(blog.id!);
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 6 : 8,
          horizontal: isSmallScreen ? 4 : 8,
        ),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditBlogScreen(blog: blog),
              ),
            );
            if (result == true) {
              await _loadBlogs();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (blog.imagePath != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.file(
                    File(blog.imagePath!),
                    width: double.infinity,
                    height: screenWidth * (isSmallScreen ? 0.55 : 0.5),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: screenWidth * (isSmallScreen ? 0.55 : 0.5),
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      blog.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      blog.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                        Text(' ${blog.likes}'),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, color: Colors.grey, size: 16),
                        Text(
                          ' ${blog.createTime.year}-${blog.createTime.month.toString().padLeft(2, '0')}-${blog.createTime.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            blog.type,
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedDropdown({
    required BuildContext context,
    required String? value,
    required List<String> items,
    required IconData icon,
    required String hint,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
          iconSize: 24,
          elevation: 8,
          dropdownColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color,
          ),
          hint: Row(
            children: [
              Icon(icon, size: 20, color: theme.hintColor),
              const SizedBox(width: 8),
              Text(hint, style: TextStyle(color: theme.hintColor)),
            ],
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  item,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的博客'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildEnhancedDropdown(
                    context: context,
                    value: _selectedType,
                    items: _types,
                    icon: Icons.category,
                    hint: '选择类型',
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEnhancedDropdown(
                    context: context,
                    value: _selectedSort,
                    items: _sortOptions,
                    icon: Icons.sort,
                    hint: '排序方式',
                    onChanged: (value) {
                      setState(() {
                        _selectedSort = value;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('加载失败'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBlogs,
                    child: const Text('重试'),
                  ),
                ],
              ),
            )
                : _filteredBlogs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('暂无博客'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBlogs,
                    child: const Text('刷新'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadBlogs,
              child: ListView.builder(
                padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
                itemCount: _filteredBlogs.length,
                itemBuilder: (context, index) {
                  final blog = _filteredBlogs[index];
                  return _buildBlogItem(
                      blog, context, isSmallScreen, screenWidth);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ... [EditBlogScreen, BlogListScreen, BlogDetailScreen, CommentList, CommentInput 类保持不变] ...

class EditBlogScreen extends StatefulWidget {
  final Blog blog;

  const EditBlogScreen({super.key, required this.blog});

  @override
  _EditBlogScreenState createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  File? _image;
  late String _selectedType;
  final List<String> _types = ['校园生活', '学习交流', '社团活动', '二手交易'];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blog.title);
    _contentController = TextEditingController(text: widget.blog.content);
    _selectedType = widget.blog.type;
    if (widget.blog.imagePath != null) {
      _image = File(widget.blog.imagePath!);
    }
  }

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

  Future<void> _updateBlog() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final updatedBlog = Blog(
      id: widget.blog.id,
      title: _titleController.text,
      content: _contentController.text,
      imagePath: _image?.path,
      type: _selectedType,
      likes: widget.blog.likes,
      createTime: widget.blog.createTime,
    );

    try {
      await DatabaseHelper.instance.updateBlog(updatedBlog);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('博客更新成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('更新失败，请重试'),
            action: SnackBarAction(
              label: '重试',
              onPressed: _updateBlog,
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
        title: const Text('编辑博客'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateBlog,
              tooltip: '保存',
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
                      '更换图片',
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

// 以下是原有的 BlogListScreen, BlogDetailScreen, CommentList, CommentInput 类
// 保持不变，为了节省空间这里省略了，实际代码中需要保留

class BlogListScreen extends StatefulWidget {
  final String type;
  final bool isMainCategory;

  const BlogListScreen({
    super.key,
    required this.type,
    required this.isMainCategory,
  });

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Blog> _blogs = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBlogs();
  }

  @override
  void didUpdateWidget(covariant BlogListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type || oldWidget.isMainCategory != widget.isMainCategory) {
      _loadBlogs();
    }
  }

  Future<void> _loadBlogs() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      List<Blog> blogs;
      if (widget.type == '热门') {
        blogs = await _dbHelper.getHotBlogs();
      } else if (widget.isMainCategory) {
        blogs = await _dbHelper.getAllBlogs();
      } else {
        blogs = await _dbHelper.getBlogsByType(widget.type);
      }

      if (mounted) {
        setState(() {
          _blogs = blogs;
        });
      }
    } catch (e) {
      debugPrint('加载博客出错: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _likeBlog(int id) async {
    try {
      await _dbHelper.likeBlog(id);
      await _loadBlogs(); // 点赞后重新加载数据
    } catch (e) {
      debugPrint('点赞失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('点赞失败，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('加载失败'),
            ElevatedButton(
              onPressed: _loadBlogs,
              child: const Text('重试'),
            ),
          ],
        ),
      )
          : _blogs.isEmpty
          ? const Center(child: Text('暂无内容'))
          : RefreshIndicator(
        onRefresh: _loadBlogs,
        child: ListView.builder(
          padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
          itemCount: _blogs.length,
          itemBuilder: (context, index) =>
              _buildBlogItem(_blogs[index], isSmallScreen),
        ),
      ),
    );
  }

  Widget _buildBlogItem(Blog blog, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6 : 8,
        horizontal: isSmallScreen ? 4 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(blog: blog),
            ),
          ).then((_) => _loadBlogs()); // 返回时刷新数据
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.imagePath != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.file(
                  File(blog.imagePath!),
                  width: double.infinity,
                  height: screenWidth * (isSmallScreen ? 0.55 : 0.5),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: screenWidth * (isSmallScreen ? 0.55 : 0.5),
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 * textScaleFactor : 18 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Text(
                    blog.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 * textScaleFactor : 14 * textScaleFactor,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 10 : 12),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red[300],
                          size: isSmallScreen ? 18 : 20,
                        ),
                        onPressed: () => _likeBlog(blog.id!),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text(
                        '${blog.likes}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 8 : 12),
                      IconButton(
                        icon: Icon(
                          Icons.comment,
                          color: Colors.blue[300],
                          size: isSmallScreen ? 18 : 20,
                        ),
                        onPressed: () => _showCommentsBottomSheet(blog.id!),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      FutureBuilder<int>(
                        future: _getCommentCount(blog.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              '0',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              '0',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            );
                          } else {
                            return Text(
                              '${snapshot.data ?? 0}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            );
                          }
                        },
                      ),
                      const Spacer(),
                      Text(
                        _formatDateTime(blog.createTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isSmallScreen ? 11 : 12,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6 : 8,
                          vertical: isSmallScreen ? 3 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          blog.type,
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: isSmallScreen ? 11 : 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCommentsBottomSheet(int blogId) async {
    final comments = await _dbHelper.getCommentsByBlog(blogId);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '评论 (${comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: comments.isEmpty
                    ? const Center(child: Text('暂无评论'))
                    : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comments[index].content,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(comments[index].createTime),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (index != comments.length - 1)
                            const Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<int> _getCommentCount(int blogId) async {
    try {
      final comments = await DatabaseHelper.instance.getCommentsByBlog(blogId);
      return comments.length;
    } catch (e) {
      debugPrint('获取评论数量出错: $e');
      return 0;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class BlogDetailScreen extends StatelessWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          blog.title,
          style: TextStyle(
              fontSize: isSmallScreen ? 16 * textScaleFactor : 18 * textScaleFactor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: 80, // 为底部评论输入框留出空间
            ),
            child: Column(
              children: [
                if (blog.imagePath != null)
                  Container(
                    height: screenWidth * (isSmallScreen ? 0.7 : 0.6),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(blog.imagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 6 : 8,
                              vertical: isSmallScreen ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              blog.type,
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontSize: isSmallScreen ? 11 : 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${blog.createTime.year}-${blog.createTime.month.toString().padLeft(2, '0')}-${blog.createTime.day.toString().padLeft(2, '0')} '
                                '${blog.createTime.hour.toString().padLeft(2, '0')}:${blog.createTime.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        blog.content,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 * textScaleFactor : 16 * textScaleFactor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                CommentList(blogId: blog.id!),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CommentInput(blogId: blog.id!),
          ),
        ],
      ),
    );
  }
}

class CommentList extends StatefulWidget {
  final int blogId;

  const CommentList({super.key, required this.blogId});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Comment> _comments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      _comments = await _dbHelper.getCommentsByBlog(widget.blogId);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('加载评论出错: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _comments.isEmpty
        ? Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const Text('暂无评论'),
    )
        : ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _comments.length,
      itemBuilder: (ctx, i) => Card(
        margin: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 3 : 4,
          horizontal: isSmallScreen ? 8 : 12,
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _comments[i].content,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 * textScaleFactor : 14 * textScaleFactor,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                '${_comments[i].createTime.year}-${_comments[i].createTime.month.toString().padLeft(2, '0')}-${_comments[i].createTime.day.toString().padLeft(2, '0')} '
                    '${_comments[i].createTime.hour.toString().padLeft(2, '0')}:${_comments[i].createTime.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentInput extends StatefulWidget {
  final int blogId;

  const CommentInput({super.key, required this.blogId});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) return;
    final comment = Comment(
      blogId: widget.blogId,
      content: _commentController.text,
      createTime: DateTime.now(),
    );
    await _dbHelper.insertComment(comment);
    _commentController.clear();
    // 通知父组件刷新评论列表
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('评论成功')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 400;
    final double textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[300] ?? Colors.grey)),
      ),
      child: Row(  // 修复：将child移出decoration
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '写下你的评论...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12 : 16,
                  vertical: isSmallScreen ? 8 : 12,
                ),
                isDense: true,
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              maxLines: 1,
              style: TextStyle(
                fontSize: (isSmallScreen ? 14 : 16) * textScaleFactor,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}