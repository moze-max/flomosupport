// lib/templates/app_templates.dart
import 'package:flutter/material.dart';
import 'package:flomosupport/models/share_model.dart';

// 模板1：简单卡片，带有渐变背景
Widget _buildSimpleGradientCard(
    BuildContext context, String title, String content) {
  return Container(
    width: 300, // 固定宽度，方便截图
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: Colors.white, // 明确设置背景色防止黑边
      borderRadius: BorderRadius.circular(15.0),
      gradient: LinearGradient(
        colors: [
          Colors.blue.shade300,
          Colors.purple.shade300,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(51),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // 自动适应内容高度
      children: [
        Icon(Icons.emoji_events, color: Colors.yellow.shade700, size: 60),
        SizedBox(height: 15),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

// 模板2：带有边框的简约风格
Widget _buildBorderedCard(BuildContext context, String title, String content) {
  return Container(
    width: 300, // 固定宽度，方便截图
    padding: const EdgeInsets.all(20.0),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade400, width: 2),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎉 恭喜！',
          style: TextStyle(
            color: Colors.green,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          content,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 15),
        Align(
          alignment: Alignment.bottomRight,
          child: Text(
            '来自 FlomoSupport',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ],
    ),
  );
}

final List<shareTemplate> availableTemplates = [
  shareTemplate(
    id: 'simple_gradient',
    name: '渐变卡片',
    builder: _buildSimpleGradientCard,
  ),
  shareTemplate(
    id: 'bordered_minimal',
    name: '简约边框',
    builder: _buildBorderedCard,
  ),
];
