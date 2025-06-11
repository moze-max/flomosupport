import 'package:flomosupport/components/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flomosupport/models/guidemodel.dart'; // 确保路径正确
import 'package:flomosupport/components/dialog_components.dart';

class Newguide extends StatefulWidget {
  const Newguide({super.key});

  @override
  NewguideState createState() => NewguideState();
}

class NewguideState extends State<Newguide> {
  final _fileName = 'templates.json';
  final _imageDirName = 'guideimages'; // 新增：存放图片子文件夹名称

  List<Template> _templates = [];
  final TextEditingController _nameController = TextEditingController();
  final List<String> _useritems = [];
  File? _pickedImage; // 用于存储用户选择的图片文件

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  // 加载模板的逻辑保持不变
  Future<void> _loadTemplates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final appDirPath = '${directory.path}/flomosupport'; // 应用根目录
      final file = File('$appDirPath/$_fileName');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonList = json.decode(contents) as List;
        setState(() {
          _templates = jsonList.map((json) => Template.fromJson(json)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, '模板加载失败，: $e');
      }
    }
  }

  // 保存所有模板的逻辑保持不变
  Future<void> _saveTemplates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final appDirPath = '${directory.path}/flomosupport';
      final dir = Directory(appDirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('$appDirPath/$_fileName');

      final jsonList = _templates.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      if (mounted) {
        showSnackbar(context, '模板保存失败: $e');
      }
    }
  }

  // 新增：图片选择器方法
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery); // 可以选择 .camera
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  // 新增：保存当前模板的逻辑，包括图片处理
  Future<void> _saveTemplate() async {
    if (_nameController.text.isEmpty) {
      showSnackbar(context, '模板名称不能为空！', isError: true);
      return;
    }
    if (_useritems.isEmpty) {
      showSnackbar(context, '模板条目不能为空！', isError: true);
      return;
    }

    String? imagePath;
    if (_pickedImage != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final imageDirPath = '${directory.path}/flomosupport/$_imageDirName';
        final imageDir = Directory(imageDirPath);
        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }

        // 使用时间戳作为图片名，确保唯一性
        final String newFileName =
            '${DateTime.now().millisecondsSinceEpoch}.png';
        final String newPath = '$imageDirPath/$newFileName';
        final File newImage = await _pickedImage!.copy(newPath); // 复制图片到指定目录
        imagePath = newImage.path; // 存储新图片路径
      } catch (e) {
        if (mounted) {
          showSnackbar(context, '封面图片保存失败: $e', isError: true);
        }

        imagePath = null;
      }
    }

    final newTemplate = Template.create(
        name: _nameController.text.trim(),
        items: List<String>.from(_useritems),
        imagePath: imagePath);

    setState(() {
      _templates.add(newTemplate);
    });

    if (mounted) {
      await _saveTemplates(); // 调用 _saveTemplates 将所有模板保存到文件
      _nameController.clear(); // 清空名称输入框
      _useritems.clear(); // 清空当前条目列表
      _pickedImage = null; // 清空已选择的图片
      if (mounted) {
        showSnackbar(context, '模板保存成功！');
      }
      // 返回上一页并传递成功结果，可以用于刷新Guide页面
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final bool canPop = Navigator.of(context).canPop();

    return Scaffold(
        appBar: AppBar(
          title: const Text('新建模板'),
          centerTitle: true,
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : null,
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
          foregroundColor: currentTheme.appBarTheme.foregroundColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                // 注意：如果使用Spacer，可能需要重新评估SingleChildScrollView
                // 如果屏幕高度足够，Spacer会拉伸，body内容可能不会滚动
                // 如果屏幕高度不足，SingleChildScrollView仍会提供滚动
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return IntrinsicHeight(
                        // 使得 Column 能够根据其 Expanded 子元素来决定高度
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.start, // 元素从顶部开始排列
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '添加模板',
                              style: currentTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: currentTheme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: '模板名称',
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(
                                    color: currentTheme.colorScheme.onSurface),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: currentTheme.colorScheme.outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: currentTheme.colorScheme.primary,
                                      width: 2),
                                ),
                              ),
                              style: TextStyle(
                                  color: currentTheme.colorScheme.onSurface),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: currentTheme
                                      .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: currentTheme.colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: _pickedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          _pickedImage!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 50,
                                            color: currentTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '点击选择封面图片',
                                            style: currentTheme
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              color: currentTheme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // 条目列表区域（Card包裹）
                            // 考虑让这个Card可以拉伸，或者在其之后添加Spacer
                            SizedBox(
                              height: 200, // 保持固定高度的列表
                              child: Card(
                                elevation: 4,
                                color: currentTheme.colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _useritems.isEmpty
                                      ? Center(
                                          child: Text(
                                            '暂未添加任何条目',
                                            style: currentTheme
                                                .textTheme.bodyMedium
                                                ?.copyWith(
                                              color: currentTheme
                                                  .colorScheme.onSurface
                                                  .withAlpha(178),
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          primary: false,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: _useritems.length,
                                          itemBuilder: (context, index) {
                                            final item = _useritems[index];
                                            return ListTile(
                                              title: Text(item,
                                                  style: TextStyle(
                                                      color: currentTheme
                                                          .colorScheme
                                                          .onSurface)),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () {
                                                  setState(() {
                                                    if (index <
                                                        _useritems.length) {
                                                      _useritems
                                                          .removeAt(index);
                                                    }
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ),

                            // 这是实现拉伸效果的关键！
                            // Spacer 会填充所有剩余的垂直空间，将下面的按钮推到底部
                            const Spacer(), // <-- 添加 Spacer

                            const SizedBox(height: 16), // 按钮上方的间距
                            // 按钮行：添加条目 & 保存模板
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleAddItem,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          currentTheme.colorScheme.secondary,
                                      foregroundColor:
                                          currentTheme.colorScheme.onSecondary,
                                    ),
                                    child: const Text('添加条目'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saveTemplate,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          currentTheme.colorScheme.primary,
                                      foregroundColor:
                                          currentTheme.colorScheme.onPrimary,
                                    ),
                                    child: const Text('保存模板'),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).padding.bottom +
                                    16.0), // 底部安全区域和额外间距
                          ],
                        ),
                      ); // End of IntrinsicHeight
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void _handleAddItem() async {
    // Capture the result from the dialog
    final String? newItem = await showAddItemDialog(context);

    // Check if a valid item was returned (not null and not empty)
    if (newItem != null && newItem.isNotEmpty) {
      setState(() {
        _useritems.add(newItem); // Add the item to your local list
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
