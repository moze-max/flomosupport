// class Template {
//   String name;
//   List<dynamic> items;
//   String? imagePath;

//   Template({required this.name, this.items = const [], this.imagePath});

//   Map<String, dynamic> toJson() {
//     return {'name': name, 'items': items, 'imagePath': imagePath};
//   }

//   factory Template.fromJson(Map<String, dynamic> json) {
//     return Template(
//         name: json['name'], items: json['items'], imagePath: json['imagePath']);
//   }
// }

// models/template.dart
import 'package:uuid/uuid.dart'; // 导入 uuid 包

class Template {
  final String id; // <-- 添加 id 字段，通常设为 final
  String name;
  List<dynamic> items;
  String? imagePath;

  // 修改构造函数，id 应该是必须的
  Template({
    required this.id, // <-- id 必须提供
    required this.name,
    this.items = const [],
    this.imagePath,
  });

  // 添加一个便捷构造函数来自动生成 id
  factory Template.create({
    required String name,
    List<dynamic> items = const [],
    String? imagePath,
  }) {
    // 生成一个 V4 UUID（随机生成）
    final uuid = const Uuid();
    return Template(
      id: uuid.v4(), // 自动生成 UUID
      name: name,
      items: items,
      imagePath: imagePath,
    );
  }

  @override // 建议重写 hashCode 和 == 来正确比较模板对象
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Template && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id, // <-- 添加 id
      'name': name,
      'items': items,
      'imagePath': imagePath,
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String, // <-- 从 JSON 读取 id
      name: json['name'] as String,
      // 确保 items 是 List<dynamic> 类型，如果直接是 List<String> 更好
      items: (json['items'] as List<dynamic>).map((e) => e).toList(),
      imagePath: json['imagePath'] as String?,
    );
  }
}
