import 'package:flutter/material.dart';
import 'package:flomosupport/models/guidemodel.dart';

/// Shows a confirmation dialog for deleting a template.
/// Returns `true` if the user confirms deletion, `false` otherwise.
Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required Template template,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('确认删除'),
      content: Text('确定要删除"${template.name}"吗？此操作不可撤销。'),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text(
            '删除',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
}

/// Shows a dialog for adding a new item with a TextField.
Future<String?> showAddItemDialog(BuildContext context) async {
  return await showDialog<String>(
    context: context,
    builder: (dialogContext) {
      // 使用 StatefulBuilder 来管理 controller 的生命周期
      return StatefulBuilder(
        builder: (innerContext, setState) {
          final itemsInputController = TextEditingController();

          return AlertDialog(
            title: Text('添加条目',
                style: TextStyle(
                    color: Theme.of(innerContext).colorScheme.onSurface)),
            content: TextField(
              controller: itemsInputController,
              decoration: InputDecoration(
                labelText: '条目内容',
                labelStyle: TextStyle(
                    color: Theme.of(innerContext)
                        .colorScheme
                        .onSurface
                        .withAlpha(179)),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(innerContext).colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(innerContext).colorScheme.primary,
                      width: 2),
                ),
              ),
              style: TextStyle(
                  color: Theme.of(innerContext).colorScheme.onSurface),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(innerContext, null);
                },
                child: Text('取消',
                    style: TextStyle(
                        color: Theme.of(innerContext).colorScheme.onSurface)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (itemsInputController.text.isNotEmpty) {
                    final result = itemsInputController.text.trim();
                    Navigator.pop(innerContext, result);
                  } else {
                    ScaffoldMessenger.of(innerContext).showSnackBar(
                      SnackBar(
                        content: Text(
                          '条目内容不能为空！',
                          style: TextStyle(
                              color:
                                  Theme.of(innerContext).colorScheme.onError),
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(innerContext).colorScheme.primary,
                  foregroundColor: Theme.of(innerContext).colorScheme.onPrimary,
                ),
                child: const Text('保存'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Shows a dialog for adding a new class item.
Future<String?> showAddClassItemDialog(BuildContext context) async {
  return await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        // 使用 StatefulBuilder 来管理 controller 的生命周期
        return StatefulBuilder(builder: (innerContext, setState) {
          final TextEditingController addClassController =
              TextEditingController();

          return AlertDialog(
            title: const Text('添加分类'),
            content: TextField(
              autofocus: true,
              controller: addClassController,
              decoration: const InputDecoration(hintText: '输入条目内容'),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(innerContext).pop(null);
                  },
                  child: const Text('取消')),
              ElevatedButton(
                  onPressed: () {
                    final String trimmedText = addClassController.text.trim();
                    if (trimmedText.isNotEmpty) {
                      final result = trimmedText; // 存储有效结果
                      Navigator.of(innerContext).pop(result); // 弹出并返回结果
                    } else {
                      ScaffoldMessenger.of(innerContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            '分类内容不能为空！',
                            style: TextStyle(
                                color:
                                    Theme.of(innerContext).colorScheme.onError),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('添加'))
            ],
          );
        });
      });
}

//---

/// Shows a generic confirmation dialog.
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmButtonText = '确定',
  String cancelButtonText = '取消',
  Color? confirmButtonColor,
}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  confirmButtonColor ?? Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(confirmButtonText),
          ),
        ],
      );
    },
  );
}
