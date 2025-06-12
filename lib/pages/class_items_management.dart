import 'package:flutter/material.dart';
import 'package:flomosupport/components/show_snackbar.dart';
import 'package:flomosupport/components/dialog_components.dart';
import 'package:flomosupport/functions/storage_service.dart'; // 使用 StorageService
import 'package:provider/provider.dart';
import 'package:flomosupport/functions/class_items_notification.dart';

class ClassItemManagementPage extends StatefulWidget {
  const ClassItemManagementPage({super.key});

  @override
  State<ClassItemManagementPage> createState() =>
      _ClassItemManagementPageState();
}

class _ClassItemManagementPageState extends State<ClassItemManagementPage> {
  List<String> _classItems = [];

  @override
  void initState() {
    super.initState();
    _loadClassItems();
  }

  Future<void> _loadClassItems() async {
    // ⭐ 从 StorageService 加载数据到本地状态
    final loadedItems = await StorageService.loadClassItems();
    if (mounted) {
      setState(() {
        _classItems = loadedItems;
      });
    }
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    setState(() {
      final String item = _classItems.removeAt(oldIndex);
      _classItems.insert(newIndex, item);
    });

    // ⭐ 保存新的排序到存储
    await StorageService.saveClassItems(_classItems);

    // ⭐ 关键一步：获取 ClassItemNotifier 并通知它刷新数据
    if (!context.mounted) return;
    if (!mounted) {
      return;
    }
    final classItemNotifier =
        Provider.of<ClassItemNotifier>(context, listen: false);
    await classItemNotifier.refreshClassItems(); // 通知刷新分类
    // if (mounted) {
    //   showSnackbar(context, '分类顺序已保存');
    // }
  }

  Future<void> _addCustomClassItem() async {
    if (!context.mounted) return;
    final String? newClassItem = await showAddClassItemDialog(context);
    if (!context.mounted) {
      return;
    }
    if (newClassItem != null && newClassItem.isNotEmpty) {
      if (_classItems.contains(newClassItem)) {
        if (mounted) {
          showSnackbar(context, '分类已存在');
        }
        return;
      }
      setState(() {
        _classItems.add(newClassItem);
      });
      // ⭐ 保存新的分类到存储
      await StorageService.saveClassItems(_classItems);
      // ⭐ 通知 ClassItemNotifier 刷新数据
      if (!context.mounted) return;
      if (!mounted) return;
      final classItemNotifier =
          Provider.of<ClassItemNotifier>(context, listen: false);
      await classItemNotifier.refreshClassItems();
      if (mounted) {
        showSnackbar(context, '分类添加成功');
      }
    }
  }

  Future<void> _deleteClassItem(String itemToDelete) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除分类'),
          content: Text('确定要删除分类 "$itemToDelete" 吗？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _classItems.remove(itemToDelete);
      });
      // ⭐ 保存更新后的分类到存储
      await StorageService.saveClassItems(_classItems);
      // ⭐ 通知 ClassItemNotifier 刷新数据
      if (!context.mounted) return;
      if (!mounted) return;
      final classItemNotifier =
          Provider.of<ClassItemNotifier>(context, listen: false);
      await classItemNotifier.refreshClassItems();
      if (mounted) {
        showSnackbar(context, '分类删除成功');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);
    final bool canPop = Navigator.of(context).canPop();
    final BorderRadius defaultCardBorderRadius = BorderRadius.circular(8.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理分类'),
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
      body: _classItems.isEmpty
          ? Center(
              child: Text(
                '暂无分类，点击右下角按钮添加',
                style: currentTheme.textTheme.bodyLarge?.copyWith(
                  color: currentTheme.colorScheme.onSurface
                      .withAlpha(153), // 使用 withOpacity 更通用
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _classItems.length,
              buildDefaultDragHandles: false,
              itemBuilder: (context, index) {
                final String item = _classItems[index];
                return Card(
                  key: ValueKey(item),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  color:
                      currentTheme.colorScheme.surfaceContainerHighest, // 略微灰色
                  shape: RoundedRectangleBorder(
                      borderRadius: defaultCardBorderRadius),
                  child: InkWell(
                    // 替换 ListTile 为 InkWell + Row
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    borderRadius: defaultCardBorderRadius,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          // ⭐ 左侧的拖拽手柄保持不变
                          ReorderableDragStartListener(
                            index: index,
                            child: Icon(Icons.drag_handle,
                                color: currentTheme.colorScheme.onSurface
                                    .withAlpha(153)),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Text(
                              item,
                              style:
                                  currentTheme.textTheme.titleMedium?.copyWith(
                                color: currentTheme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          // ⭐ 确保 trailing 只有删除图标，没有额外的拖拽图标
                          // 如果你看到了一个 == 图标在删除图标旁边，那很可能是 ReorderableListView 的默认行为
                          // 强制它只识别 ReorderableDragStartListener 作为拖拽目标
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: currentTheme.colorScheme.error),
                            onPressed: () => _deleteClassItem(item),
                          ),
                          // 确保这里没有其他 widget 可能会被误认为是拖拽手柄
                        ],
                      ),
                    ),
                  ),
                );
              },
              onReorder: _onReorder,
              // ⭐⭐⭐ 拖拽时的视觉优化 ⭐⭐⭐
              proxyDecorator:
                  (Widget child, int index, Animation<double> animation) {
                return AnimatedBuilder(
                  // 使用 AnimatedBuilder 确保每次动画值变化时都重建
                  animation: animation,
                  builder: (BuildContext context, Widget? childToAnimate) {
                    final double elevation = 8.0 * animation.value; // 拖拽时阴影逐渐增大
                    final double scale =
                        1.0 + 0.05 * animation.value; // 拖拽时放大 5%
                    return Transform.scale(
                      scale: scale,
                      child: Material(
                        // 使用 Material 包裹以应用阴影
                        elevation: elevation,
                        color: Colors.transparent, // ⭐ 拖拽时背景完全透明
                        shadowColor: Colors.black..withAlpha(77), // 设置阴影颜色
                        child: childToAnimate,
                      ),
                    );
                  },
                  child: child, // 将原始的 child 传递给 AnimatedBuilder 的 child 参数
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomClassItem,
        backgroundColor: currentTheme.colorScheme.primary,
        foregroundColor: currentTheme.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
