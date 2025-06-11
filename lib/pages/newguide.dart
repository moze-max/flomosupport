import 'package:flomosupport/components/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flomosupport/models/guidemodel.dart'; // 确保路径正确
import 'package:flomosupport/components/dialog_components.dart';
import 'package:flomosupport/functions/image_picker_service.dart'; // 假设你有一个 showSnackbar 辅助函数
import 'package:flomosupport/functions/storage_service.dart';
import 'package:flomosupport/functions/class_items.dart';

class Newguide extends StatefulWidget {
  const Newguide({super.key});

  @override
  NewguideState createState() => NewguideState();
}

class NewguideState extends State<Newguide> {
  List<Template> _templates = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classItemController = TextEditingController();
  final ImagePickerService _imagePickerService = ImagePickerService();
  final StorageService _StorageService = StorageService();
  final ClassItemService _classItemService = ClassItemService();
  final List<String> _useritems = [];
  List<String> _availableClassItems = []; // 由 ClassItemService 填充，保持顺序
  final Set<String> _selectedClassItems =
      {}; // 当前模板已选中的 classitems (仍为 Set，因为选中不关心顺序)
  File? _pickedImage; // 用于存储用户选择的图片文件

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final loadedTemplates = await _StorageService.loadTemplates();
    if (mounted) {
      setState(() {
        _templates = loadedTemplates;
      });
    }

    // 从 ClassItemService 加载 List<String>
    List<String> loadedClassItems = await _classItemService.loadClassItems();

    if (loadedClassItems.isEmpty && _templates.isNotEmpty) {
      await _classItemService.extractAndSaveFromTemplates(_templates);
      loadedClassItems = await _classItemService.loadClassItems();
    }

    if (mounted) {
      setState(() {
        _availableClassItems = loadedClassItems;
      });
    }
  }

  void _addCustomClassItem() {
    showDialog(
      context: context,
      builder: (context) {
        String newClassItem = '';
        return AlertDialog(
          title: const Text('添加新分类'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: '输入分类名称'),
            onChanged: (value) {
              newClassItem = value.trim();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newClassItem.isNotEmpty) {
                  // 通过服务添加并保存
                  await _classItemService.addAndSaveClassItem(newClassItem);

                  // 更新本地 UI 状态 (如果 service 已处理了唯一性，这里只需添加)
                  if (mounted) {
                    setState(() {
                      // 确保本地列表也添加，且不重复
                      if (!_availableClassItems.contains(newClassItem)) {
                        _availableClassItems.add(newClassItem);
                      }
                      _selectedClassItems.add(newClassItem); // 添加后默认选中
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                } else {
                  showSnackbar(context, '分类名称不能为空！', isError: true);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final File? image = await _imagePickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _createAndPersistNewTemplate() async {
    if (_nameController.text.isEmpty) {
      showSnackbar(context, '模板名称不能为空！', isError: true);
      return;
    }
    if (_useritems.isEmpty) {
      showSnackbar(context, '模板条目不能为空！', isError: true);
      return;
    }

    // Call the refactored saveNewTemplate method from StorageService
    final savedTemplate = await StorageService.saveNewTemplate(
      name: _nameController.text,
      items: _useritems,
      pickedImage: _pickedImage,
      classitems: _selectedClassItems.toList(),
    );

    if (mounted) {
      if (savedTemplate != null) {
        setState(() {
          _templates.add(
              savedTemplate); // Add the newly saved template to your local list
        });
        showSnackbar(context, '模板保存成功！');
        _nameController.clear(); // 清空名称输入框
        _useritems.clear(); // 清空当前条目列表
        _pickedImage = null; // 清空已选择的图片
        _selectedClassItems.clear();
        Navigator.pop(context, true); // 返回上一页并传递成功结果
      } else {
        showSnackbar(context, '模板保存失败，请重试！', isError: true);
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
                            SizedBox(
                              height: 50, // 高度固定
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _availableClassItems.length +
                                    1, // +1 for the add button
                                itemBuilder: (context, index) {
                                  if (index == _availableClassItems.length) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: ActionChip(
                                        label: const Icon(Icons.add),
                                        onPressed: _addCustomClassItem,
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
                                    final classItem = _availableClassItems[
                                        index]; // 从 List 获取元素
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
                                    onPressed: _createAndPersistNewTemplate,
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
    _classItemController.dispose();
    super.dispose();
  }
}
