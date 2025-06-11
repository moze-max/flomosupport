import 'package:flutter/material.dart';

class shareTemplate {
  final String id; // 模板唯一ID
  final String name; // 模板名称，用于显示给用户
  final Widget Function(BuildContext context, String title, String content)
      builder; // 构建模板内容的函数

  shareTemplate({
    required this.id,
    required this.name,
    required this.builder,
  });
}
