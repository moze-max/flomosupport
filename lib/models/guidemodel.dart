import 'package:uuid/uuid.dart';

class Template {
  final String id;
  String name;
  List<dynamic> items;
  String? imagePath;

  Template({
    required this.id,
    required this.name,
    this.items = const [],
    this.imagePath,
  });

  // 添加一个便捷构造函数来自动生成 id
  factory Template.create({
    required String name,
    List<dynamic> items = const [],
    String? imagePath,
    Uuid? uuidGenerator,
  }) {
    final uuid = uuidGenerator ?? const Uuid();
    return Template(
      id: uuid.v4(), // 自动生成 UUID
      name: name,
      items: items,
      imagePath: imagePath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Template && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items,
      'imagePath': imagePath,
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      name: json['name'] as String,
      // 确保 items 是 List<dynamic> 类型，如果直接是 List<String> 更好
      items: (json['items'] as List<dynamic>).map((e) => e).toList(),
      imagePath: json['imagePath'] as String?,
    );
  }
}
