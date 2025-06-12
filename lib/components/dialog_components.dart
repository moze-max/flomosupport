import 'package:flutter/material.dart';
import 'package:flomosupport/models/guidemodel.dart';
// Assuming you have a Template class or similar structure defined
// For demonstration purposes, let's define a simple one:

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

Future<String?> showAddItemDialog(BuildContext context) async {
  final itemsInputController = TextEditingController();
  String? result;

  await showDialog<String>(
    context: context,
    builder: (dialogContext) {
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
                    .withAlpha(179)),
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(dialogContext).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(dialogContext).colorScheme.primary, width: 2),
            ),
          ),
          style:
              TextStyle(color: Theme.of(dialogContext).colorScheme.onSurface),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, null); // Return null on cancel
            },
            child: Text('取消',
                style: TextStyle(
                    color: Theme.of(dialogContext).colorScheme.onSurface)),
          ),
          ElevatedButton(
            onPressed: () {
              if (itemsInputController.text.isNotEmpty) {
                result = itemsInputController.text.trim();
                Navigator.pop(dialogContext, result);
              } else {
                // Show a local snackbar within the dialog context
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(
                      '条目内容不能为空！',
                      style: TextStyle(
                          color: Theme.of(dialogContext).colorScheme.onError),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.primary,
              foregroundColor: Theme.of(dialogContext).colorScheme.onPrimary,
            ),
            child: const Text('保存'),
          ),
        ],
      );
    },
  );

  // Dispose controller after dialog is dismissed
  itemsInputController.dispose();
  return result;
}

Future<String?> showAddClassItemDialog(BuildContext context) async {
  final TextEditingController textController = TextEditingController();
  final String? enteredText = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('添加分类'),
          content: TextField(
            autofocus: true,
            controller: textController,
            decoration: InputDecoration(hintText: '输入条目内容'),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(null);
                },
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  final String trimmedText = textController.text.trim();
                  if (trimmedText.isNotEmpty) {
                    Navigator.of(dialogContext).pop(trimmedText);
                  } else {
                    showConfirmationDialog(context,
                        title: "请再检查一下", content: "现在好像还没有内容哦？");
                  }
                },
                child: const Text('添加'))
          ],
        );
      });
  textController.dispose();
  return enteredText;
}

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
              backgroundColor: confirmButtonColor ??
                  Theme.of(context).colorScheme.error, // 默认删除是红色
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(confirmButtonText),
          ),
        ],
      );
    },
  );
}
