// // lib/services/class_item_service.dart
// import 'dart:convert';
// import 'dart:developer' as developor;
// import 'dart:io';
// import 'package:flomosupport/functions/storage_service.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart' as path;
// import 'package:flomosupport/models/guidemodel.dart'; // Needed for initial extraction from Templates

// class ClassItemService {
//   final StorageService _storageService = StorageService();

//   // Future<File> _getClassItemsFile() async {
//   //   final directory = await getApplicationDocumentsDirectory();
//   //   final appDirPath = path.join(directory.path, _appDirName);
//   //   final appDir = Directory(appDirPath);
//   //   if (!await appDir.exists()) {
//   //     await appDir.create(recursive: true);
//   //   }
//   //   return File(path.join(appDirPath, _classItemsFileName));
//   // }

//   // /// Loads all class items from the persisted file as a List, preserving order.
//   // Future<List<String>> loadClassItems() async {
//   //   try {
//   //     final file = await _getClassItemsFile();
//   //     if (await file.exists()) {
//   //       final contents = await file.readAsString();
//   //       final List<dynamic> jsonList = json.decode(contents) as List;
//   //       // 直接返回 List<String>，保持加载时的顺序
//   //       return jsonList.map((e) => e.toString()).toList();
//   //     }
//   //   } catch (e) {
//   //     developor.log('Error loading class items: $e');
//   //   }
//   //   return []; // Return an empty list if file doesn't exist or error occurs
//   // }

//   /// Saves the given list of class items to the persisted file, preserving order.
//   Future<void> saveClassItems(List<String> items) async {
//     try {
//       final file = await _storageService.loadClassItems();
//       final jsonString = json.encode(items); // List 可以直接进行 JSON 编码
//       await file.writeAsString(jsonString);
//     } catch (e) {
//       developor.log('Error saving class items: $e');
//     }
//   }

//   /// Extracts unique class items from a list of templates and saves them,
//   /// 确保唯一性并保持一致的顺序 (例如，插入顺序)。
//   Future<void> extractAndSaveFromTemplates(List<Template> allTemplates) async {
//     // 加载当前已有的 items，以保持现有顺序
//     final List<String> currentItems = await loadClassItems();
//     // 使用 Set 来进行唯一性检查，避免重复添加
//     Set<String> uniqueTracker = Set.from(currentItems);

//     List<String> updatedItems = List.from(currentItems); // 从当前顺序开始

//     for (var template in allTemplates) {
//       if (template.classitems != null) {
//         for (var item in template.classitems!) {
//           if (uniqueTracker.add(item)) {
//             // 如果是新的唯一项
//             updatedItems.add(item); // 添加到有序列表中
//           }
//         }
//       }
//     }
//     await saveClassItems(updatedItems); // 保存合并后的有序列表
//   }

//   /// Adds a single new class item and saves the updated list.
//   /// 新的项目将添加到列表末尾。
//   Future<void> addAndSaveClassItem(String newItem) async {
//     if (newItem.trim().isEmpty) return;
//     List<String> currentItems = await loadClassItems();
//     // 检查是否已存在，如果不存在才添加
//     if (!currentItems.contains(newItem.trim())) {
//       currentItems.add(newItem.trim());
//       await saveClassItems(currentItems);
//     }
//   }

//   /// 重新排序持久化列表中的 class items 并保存。
//   Future<void> reorderAndSaveClassItems(int oldIndex, int newIndex) async {
//     List<String> currentItems = await loadClassItems();
//     // ReorderableListView 在 newIndex 处插入时，如果向下移动，newIndex 会多 1
//     if (newIndex > oldIndex) {
//       newIndex -= 1;
//     }
//     final String item = currentItems.removeAt(oldIndex);
//     currentItems.insert(newIndex, item);
//     await saveClassItems(currentItems);
//   }

//   Future<void> removeClassItem(String itemToRemove) async {
//     List<String> currentItems = await loadClassItems();
//     if (currentItems.remove(itemToRemove)) {
//       // remove returns true if item was found and removed
//       await saveClassItems(currentItems);
//     }
//   }
// }
