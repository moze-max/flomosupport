class Template {
  String name;
  List<dynamic> items;
  String? imagePath;

  Template({required this.name, this.items = const [], this.imagePath});

  Map<String, dynamic> toJson() {
    return {'name': name, 'items': items, 'imagePath': imagePath};
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
        name: json['name'], items: json['items'], imagePath: json['imagePath']);
  }
}
