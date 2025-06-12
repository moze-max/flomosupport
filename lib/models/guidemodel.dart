import 'package:uuid/uuid.dart';

class Template {
  final String id;
  String name;
  List<String>? classitems;
  List<String> items;
  String? imagePath;

  Template({
    required this.id,
    required this.name,
    this.classitems,
    this.items = const [],
    this.imagePath,
  });

  factory Template.create({
    required String name,
    List<String> items = const [],
    String? imagePath,
    List<String>? classitems,
    Uuid? uuidGenerator,
  }) {
    final uuid = uuidGenerator ?? const Uuid();
    return Template(
      id: uuid.v4(), // 自动生成 UUID
      name: name,
      items: items,
      classitems: classitems,
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
      'classitems': classitems,
      'imagePath': imagePath,
    };
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      id: json['id'] as String,
      name: json['name'] as String,
      // classitems:
      // (json['classitems'] as List<dynamic>?)?.cast<String>().toList(),
      classitems: (json['classitems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      items: (json['items'] as List<dynamic>?)?.cast<String>().toList() ??
          const [],
      imagePath: json['imagePath'] as String?,
    );
  }
}
