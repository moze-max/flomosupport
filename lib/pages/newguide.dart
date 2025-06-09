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
        items: List<dynamic>.from(_useritems),
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
        // body: SingleChildScrollView(
        //   child: Padding(
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
                    // mainAxisSize: MainAxisSize.min, // <-- 这里可能需要移除或调整
                    // 因为我们想要拉伸，所以Column可能需要占据更多空间
                    // 通常，如果SingleChildScrollView包裹Column，且Column包含Spacer，
                    // Column的mainAxisSize默认为MainAxisSize.max，Spacer会填充剩余空间。
                    // 但在SingleChildScrollView内部，Column的布局行为可能受限于其内容大小。
                    // 更好的做法是让Column占据其父级（SingleChildScrollView的子级）的最大高度。
                    // 要确保Column能拉伸到其父级的最大高度，需要确保其父级也有足够的空间。
                    // 考虑将Padding直接作为Scaffold的body，然后内部使用Column+Expanded。

                    // 暂时保留mainAxisSize: MainAxisSize.min，如果效果不对再移除
                    // 让我们先尝试以下结构，它更常见：
                    // Column作为Scaffold的直接body，然后处理溢出。

                    // 临时移除 SingleChildScrollView 来测试 Spacer 效果
                    // 如果内容溢出，再添加 SingleChildScrollView
                    // crossAxisAlignment: CrossAxisAlignment.start, // 保持左对齐

                    // *** 新的布局思路：将 Column 作为 Scaffold 的直接 body ***
                    // 如果内容可能溢出屏幕，那么Column的父级需要有足够的空间来滚动。
                    // 最简单的实现方式是：
                    // Scaffold -> Column (Expanded if needed) -> 各个组件 -> Spacer -> 按钮 Row

                    // 重新设计 body 部分，去除 SingleChildScrollView 的直接包裹，
                    // 而是让 Column 填充所有可用空间，并内部处理滚动（如果需要）
                    // 但是，您原有的 SingleChildScrollView 是为了处理内容过长时滚动。
                    // 要达到“拉伸”且“底部”的效果，同时保留滚动，有点复杂。

                    // 方案A: 弹性布局，内容部分可滚动
                    // 这种方案是：Scaffold -> Column (填充高度) -> [可滚动的区域] -> Spacer -> [底部固定区域]
                    // 这意味着你可能需要两个滚动区域或一个CustomScrollView。

                    // 让我们假设你的内容不是总是很长以至于需要Scaffold级别的滚动，
                    // 而是希望在“有空间”时拉伸。如果内容真的很高，那么按钮也会随着滚动而向上。
                    // 如果您希望按钮永远在屏幕底部，不随内容滚动，那还是 bottomNavigationBar 更好。
                    // “当屏幕的高度超过一定限度，元素的高度将会按照比例拉伸”
                    // 意味着在足够大的屏幕上，内容会变高，把按钮推到屏幕的底部。

                    // 最终决定：保留 SingleChildScrollView，但让其子级 Column 能够按需拉伸。
                    // 这需要一个 `ConstrainedBox` 或 `LayoutBuilder` 来确保 `Column` 至少能占据屏幕高度。

                    // **最简单的实现方式，无需复杂的高度计算，适用于您的场景：**
                    // 将 Column 的 mainAxisSize 设置为 MainAxisSize.max，并包裹在一个可以获得最大高度的 Widget 中。
                    // 或者更直接，将 `Column` 直接作为 `body`，并让其 `mainAxisAlignment` 变为 `spaceBetween`。
                    // 但这样会导致内容直接分散，而不是拉伸特定部分。

                    // **回到最初的理解，您想要的是在有额外空间时，页面内容（或一部分）填充这部分空间，从而让按钮在视觉上“保持在底部”**
                    // 这最适合 `Column` + `Spacer` 组合，但要确保 `Column` 本身有足够的空间来拉伸。
                    // 在 `Scaffold` 的 `body` 中，如果直接是一个 `Column`，它会尝试填充可用高度。
                    // 但 `SingleChildScrollView` 会限制其子级 `Column` 的高度为内容所需高度。

                    // 解决方案：将 `SingleChildScrollView` 嵌套在 `Expanded` 或 `SizedBox.expand` 中，
                    // 并将 `Column` 的 `mainAxisSize` 设置为 `MainAxisSize.max`。

                    // **修改为 Scaffold 的直接 body，并使用 Column 弹性布局：**

                    // --- 放弃 SingleChildScrollView 直接包裹 Column 的简单方法，改为更灵活的方案 ---

                    // 新的 body 结构
                    // 利用 `LayoutBuilder` 来获取可用高度，然后强制 `Column` 至少占据这个高度
                    // 这样 `Spacer` 才能工作

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
