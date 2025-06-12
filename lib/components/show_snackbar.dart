import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, String message,
    {bool isError = false, bool isfloating = true, isClosedAble = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  final Color backgroundColor = isError
      ? Theme.of(context).colorScheme.errorContainer // 错误提示的背景色
      : Theme.of(context).colorScheme.primaryContainer; // 普通提示的背景色

  final Color foregroundColor = isError
      ? Theme.of(context).colorScheme.onErrorContainer // 错误提示的文字颜色
      : Theme.of(context).colorScheme.onPrimaryContainer; // 普通提示的文字颜色
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: foregroundColor),
      ),
      backgroundColor: backgroundColor,
      behavior: isfloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.all(16.0), // 如果是 floating，可以设置 margin
      duration: const Duration(milliseconds: 1000),
      action: isClosedAble
          ? SnackBarAction(
              label: '关闭', // 可以提供一个关闭按钮
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              textColor: foregroundColor,
            )
          : null,
    ),
  );
}
