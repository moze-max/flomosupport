import 'package:flomosupport/components/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/models/guidemodel.dart';
import 'package:flomosupport/functions/storage_service.dart';
import 'package:flomosupport/components/dialog_components.dart';

// **解耦后的删除处理函数**
Future<bool> handleDeleteTemplateLogic(
    {required BuildContext context, required Template templateToDelete}) async {
  if (!context.mounted) {
    return false;
  }
  // 使用 contextCopy 来避免异步操作后 context 不再有效的问题
  final contextCopy = context;

  // 弹出确认对话框
  final bool? confirm = await showDeleteConfirmationDialog(
      context: contextCopy, template: templateToDelete);

  if (confirm == true) {
    bool deleted = await StorageService.deleteTemplate(templateToDelete);
    if (contextCopy.mounted) {
      // 再次检查 context 是否 mounted
      if (deleted) {
        showSnackbar(contextCopy, '模板已删除');
        return true;
      } else {
        showSnackbar(contextCopy, '删除模板失败', isError: true);
        return false;
      }
    } else {
      return false;
    }
  }
  return false;
}
