import 'package:flomosupport/components/show_snackbar.dart';
import 'package:flomosupport/functions/class_items_notification.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flomosupport/models/guidemodel.dart'; // 确保路径正确
import 'package:flomosupport/components/dialog_components.dart';
import 'package:flomosupport/functions/image_picker_service.dart'; // 假设你有一个 showSnackbar 辅助函数
import 'package:flomosupport/functions/storage_service.dart';
import 'package:provider/provider.dart';

class Newguide extends StatefulWidget {
  const Newguide({super.key});

  @override
  NewguideState createState() => NewguideState();
}

class NewguideState extends State<Newguide> {
  // List<Template> _templates = [];
  final TextEditingController _nameController = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final List<String> _useritems = [];
  final Set<String> _selectedClassItems = {}; // 当前模板已选中的 classitems
  File? _pickedImage; // 用于存储用户选择的图片文件

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    final File? image = await _imagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _handleAddItem() async {
    final String? newItem = await showAddItemDialog(context);
    if (!context.mounted) {
      return;
    }
    if (newItem != null && newItem.isNotEmpty) {
      setState(() {
        _useritems.add(newItem);
      });
    }
  }

  Future<void> _handleAddNewClassItem() async {
    final String? newClassItem = await showAddClassItemDialog(context);
    if (!context.mounted) {
      return;
    }
    if (newClassItem != null && newClassItem.isNotEmpty) {
      if (!mounted) return;
      final classItemNotifier =
          Provider.of<ClassItemNotifier>(context, listen: false);
      if (classItemNotifier.uniqueClassItems.contains(newClassItem)) {
        showSnackbar(context, '分类已存在');
        return;
      }
      // 添加到存储并通知 Notifier
      List<String> currentClassItemsInStorage =
          await StorageService.loadClassItems();
      currentClassItemsInStorage.add(newClassItem);
      await StorageService.saveClassItems(currentClassItemsInStorage);
      await classItemNotifier.refreshClassItems(); // 刷新分类列表
      // 自动选中新添加的分类
      setState(() {
        _selectedClassItems.add(newClassItem);
      });
      if (!mounted) return;
      showSnackbar(context, '新分类已添加');
    }
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.isEmpty) {
      showSnackbar(context, '模板名称不能为空');
      return;
    }
    if (_selectedClassItems.isEmpty) {
      showSnackbar(context, '请至少选择一个分类');
      return;
    }

    String? savedImagePath;
    if (_pickedImage != null) {
      savedImagePath = await StorageService.saveImageToFile(_pickedImage!);
    }

    final newTemplate = Template.create(
      name: _nameController.text,
      items: _useritems,
      classitems: _selectedClassItems.toList(), // 将 Set 转换为 List
      imagePath: savedImagePath,
    );

    List<Template> currentTemplates = await StorageService.loadTemplates();
    currentTemplates.add(newTemplate);
    await StorageService.saveTemplates(currentTemplates);

    // 通知 ClassItemNotifier 刷新所有数据（包括模板）
    if (!context.mounted) return;
    if (!mounted) return;
    final classItemNotifier =
        Provider.of<ClassItemNotifier>(context, listen: false);
    await classItemNotifier.refreshAllData();
    if (!mounted) return;
    showSnackbar(context, '模板保存成功！');
    Navigator.pop(context, true); // 返回 true 表示数据已更新
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    // final bool canPop = Navigator.of(context).canPop();
    final classItemNotifier =
        Provider.of<ClassItemNotifier>(context, listen: false);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('新建模板'),
          centerTitle: true,
          backgroundColor: currentTheme.appBarTheme.backgroundColor,
          foregroundColor: currentTheme.appBarTheme.foregroundColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                            SizedBox(
                              height: 50, // 高度固定
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    classItemNotifier.uniqueClassItems.length +
                                        1,
                                itemBuilder: (context, index) {
                                  if (index ==
                                      classItemNotifier
                                          .uniqueClassItems.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: ActionChip(
                                        label: const Icon(Icons.add),
                                        onPressed: _handleAddNewClassItem,
                                        backgroundColor: currentTheme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                              color: currentTheme
                                                  .colorScheme.outline),
                                        ),
                                      ),
                                    );
                                  } else {
                                    final classItem = classItemNotifier
                                        .uniqueClassItems[index]; // 从 List 获取元素
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: ChoiceChip(
                                        label: Text(classItem),
                                        selected: _selectedClassItems
                                            .contains(classItem),
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              _selectedClassItems
                                                  .add(classItem);
                                            } else {
                                              _selectedClassItems
                                                  .remove(classItem);
                                            }
                                          });
                                        },
                                        selectedColor:
                                            currentTheme.colorScheme.primary,
                                        labelStyle: TextStyle(
                                          color: _selectedClassItems
                                                  .contains(classItem)
                                              ? currentTheme
                                                  .colorScheme.onPrimary
                                              : currentTheme
                                                  .colorScheme.onSurface,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: _selectedClassItems
                                                    .contains(classItem)
                                                ? currentTheme
                                                    .colorScheme.primary
                                                : currentTheme
                                                    .colorScheme.outline,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
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
                            const Spacer(),
                            const SizedBox(height: 16),
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
