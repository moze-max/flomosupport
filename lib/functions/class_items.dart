// lib/services/class_item_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flomosupport/models/guidemodel.dart'; // 需要 Template 来进行初始化提取

class ClassItemService {
  static const String _classItemsFileName =
      'class_items.json'; // 存储 classitems 的文件
  static const String _appDirName =
      'flomosupport'; // 应用根目录，与 TemplateService 保持一致

  Future<File> _getClassItemsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDirPath = path.join(directory.path, _appDirName);
    final appDir = Directory(appDirPath);
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File(path.join(appDirPath, _classItemsFileName));
  }

  /// 从持久化文件加载所有唯一的 class items。
  Future<Set<String>> loadClassItems() async {
    try {
      final file = await _getClassItemsFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents) as List;
        return Set<String>.from(jsonList.map((e) => e.toString()));
      }
    } catch (e) {
      developer.log('Error loading class items: $e');
    }
    return {}; // 如果文件不存在或发生错误，返回空 Set
  }

  /// 将给定的 class items 保存到持久化文件。
  Future<void> saveClassItems(Set<String> items) async {
    try {
      final file = await _getClassItemsFile();
      final jsonString =
          json.encode(items.toList()); // Set 需要转换为 List 才能 JSON 编码
      await file.writeAsString(jsonString);
    } catch (e) {
      developer.log('Error saving class items: $e');
    }
  }

  /// 从给定的模板列表中提取所有唯一的 class items 并保存它们。
  /// 这个方法可以在 class_items.json 文件为空时用于初始化。
  Future<void> extractAndSaveFromTemplates(List<Template> allTemplates) async {
    // 首先加载当前已有的 class items，确保不会覆盖
    final Set<String> existingClassItems = await loadClassItems();
    Set<String> uniqueItems = Set.from(existingClassItems);

    for (var template in allTemplates) {
      if (template.classitems != null) {
        for (var item in template.classitems!) {
          uniqueItems.add(item);
        }
      }
    }
    await saveClassItems(uniqueItems); // 保存合并后的 Set
  }

  /// 添加一个新的 class item 并保存更新后的列表。
  Future<void> addAndSaveClassItem(String newItem) async {
    if (newItem.trim().isEmpty) return;
    Set<String> currentItems = await loadClassItems();
    currentItems.add(newItem.trim());
    await saveClassItems(currentItems);
  }
}
