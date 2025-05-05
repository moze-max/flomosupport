class Template {
  String name;
  List<dynamic> items;

  Template({required this.name, this.items = const []});

  Map<String, dynamic> toJson() {
    return {'name': name, 'items': items};
  }

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(name: json['name'], items: json['items']);
  }
}
