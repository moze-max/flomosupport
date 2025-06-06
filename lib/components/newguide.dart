import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart'; // 导入 image_picker
import 'package:flomosupport/models/guidemodel.dart'; // 确保路径正确
// import 'package:flomosupport/themes.dart'; // 导入你的主题文件，用于颜色和文本样式

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('模板加载失败，$e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('模板保存失败: $e')),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('模板名称不能为空！',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
      return;
    }
    if (_useritems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('模板条目不能为空！',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onError))),
        );
      }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('封面图片保存失败: $e',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onError))),
          );
        }
        // 即使图片保存失败，也允许模板保存
        imagePath = null;
      }
    }

    final newTemplate = Template(
      name: _nameController.text.trim(),
      items: List<dynamic>.from(_useritems),
      imagePath: imagePath, // 将保存的图片路径赋值给模板
    );

    setState(() {
      _templates.add(newTemplate); // 将新模板添加到总模板列表
    });

    if (mounted) {
      await _saveTemplates(); // 调用 _saveTemplates 将所有模板保存到文件
      _nameController.clear(); // 清空名称输入框
      _useritems.clear(); // 清空当前条目列表
      _pickedImage = null; // 清空已选择的图片
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('模板保存成功！',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
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
      // --- MODIFICATION START ---
      body: SingleChildScrollView(
        // Allow the whole page to scroll if needed
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Apply overall padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // Take minimum space
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '添加模板',
                style: currentTheme.textTheme.headlineSmall?.copyWith(
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
                  labelStyle:
                      TextStyle(color: currentTheme.colorScheme.onSurface),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: currentTheme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: currentTheme.colorScheme.primary, width: 2),
                  ),
                ),
                style: TextStyle(color: currentTheme.colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: currentTheme.colorScheme.surfaceContainerHighest,
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image,
                              size: 50,
                              color: currentTheme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击选择封面图片',
                              style:
                                  currentTheme.textTheme.bodyMedium?.copyWith(
                                color:
                                    currentTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Apply a fixed height to the Card here
              SizedBox(
                height: 200, // <--- Set your desired fixed height here
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
                              style:
                                  currentTheme.textTheme.bodyMedium?.copyWith(
                                color: currentTheme.colorScheme.onSurface
                                    .withAlpha(178),
                              ),
                            ),
                          )
                        : ListView.builder(
                            // Important: Nested ListView with fixed height container
                            shrinkWrap:
                                true, // Only take space needed by children
                            primary: false, // Not the primary scroll view
                            physics:
                                const AlwaysScrollableScrollPhysics(), // Allow list to scroll if its content overflows fixed height
                            itemCount: _useritems.length,
                            itemBuilder: (context, index) {
                              final item = _useritems[index];
                              return ListTile(
                                title: Text(item,
                                    style: TextStyle(
                                        color: currentTheme
                                            .colorScheme.onSurface)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      if (index < _useritems.length) {
                                        _useritems.removeAt(index);
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
              const SizedBox(
                  height: 16), // Add spacing after the fixed-height card
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showAddItemDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTheme.colorScheme.secondary,
                        foregroundColor: currentTheme.colorScheme.onSecondary,
                      ),
                      child: const Text('添加条目'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTheme.colorScheme.primary,
                        foregroundColor: currentTheme.colorScheme.onPrimary,
                      ),
                      child: const Text('保存模板'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // --- MODIFICATION END ---
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        final itemsInputController =
            TextEditingController(); // Controller created here
        try {
          return AlertDialog(
            title: Text('添加条目',
                style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.onSurface)),
            content: TextField(
              controller: itemsInputController,
              decoration: InputDecoration(
                labelText: '条目内容',
                labelStyle: TextStyle(
                    color: Theme.of(dialogContext)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7)),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(dialogContext).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(dialogContext).colorScheme.primary,
                      width: 2),
                ),
              ),
              style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.onSurface),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text('取消',
                    style: TextStyle(
                        color: Theme.of(dialogContext).colorScheme.onSurface)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (itemsInputController.text.isNotEmpty) {
                    setState(() {
                      _useritems.add(itemsInputController.text.trim());
                    });
                    Navigator.pop(dialogContext);
                  } else {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                          content: Text('条目内容不能为空！',
                              style: TextStyle(
                                  color: Theme.of(dialogContext)
                                      .colorScheme
                                      .onError))),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(dialogContext).colorScheme.primary,
                  foregroundColor:
                      Theme.of(dialogContext).colorScheme.onPrimary,
                ),
                child: const Text('保存'),
              ),
            ],
          );
        } finally {
          // This block ensures the controller is disposed right after the dialog is built
          // and removed from the tree, whether by pop, or back button, or tap outside.
          // This is a robust way to ensure disposal.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!dialogContext.mounted && itemsInputController.hasListeners) {
              itemsInputController.dispose();
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
