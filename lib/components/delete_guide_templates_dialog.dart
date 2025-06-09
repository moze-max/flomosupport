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
