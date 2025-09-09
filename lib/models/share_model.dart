import 'package:flutter/material.dart';

class ShareTemplate {
  final String id; // 模板的ID
  final String name; // 模板的名字
  final Widget Function(BuildContext context, String title, String content)
      builder;

  ShareTemplate({
    required this.id,
    required this.name,
    required this.builder,
  });
}
