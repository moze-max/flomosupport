import 'package:flutter/material.dart';
import 'package:flomosupport/functions/storage_service.dart';
import 'package:flomosupport/models/guidemodel.dart';

class ClassItemNotifier extends ChangeNotifier {
  List<String> _uniqueClassItems = [];
  String? _selectedClassItem;
  List<Template> _allTemplates = [];
  List<Template> _filteredTemplates = [];

  ClassItemNotifier() {
    _loadAllData(); // 初始化时加载数据
  }

  List<String> get uniqueClassItems => _uniqueClassItems;
  String? get selectedClassItem => _selectedClassItem;
  List<Template> get filteredTemplates => _filteredTemplates;
  List<Template> get allTemplates => _allTemplates;

  Future<void> _loadAllData() async {
    // 加载分类
    final List<String> loadedClassItems = await StorageService.loadClassItems();
    // 加载所有模板
    final List<Template> loadedTemplates = await StorageService.loadTemplates();

    _uniqueClassItems = loadedClassItems.toSet().toList(); // 确保唯一性并排序
    _uniqueClassItems.sort();
    _allTemplates = loadedTemplates;
    _filterTemplates(); // 重新过滤模板

    if (_selectedClassItem != null &&
        !_uniqueClassItems.contains(_selectedClassItem)) {
      _selectedClassItem = null; // 如果当前选中的分类不存在了，则重置
    }
    notifyListeners(); // 通知所有监听者数据已更新
  }

  void setSelectedClassItem(String? item) {
    _selectedClassItem = item;
    _filterTemplates(); // 过滤模板
    notifyListeners(); // 通知监听者
  }

  void _filterTemplates() {
    if (_selectedClassItem == null) {
      _filteredTemplates = _allTemplates; // 如果选中“全部”，显示所有模板
    } else {
      // ⭐ 关键修改：检查模板的 classitems 列表中是否包含当前选中的分类
      _filteredTemplates = _allTemplates
          .where((template) =>
              template.classitems != null &&
              template.classitems!.contains(_selectedClassItem!))
          .toList();
    }
  }

  // 当 ClassItemManagementPage 更新了 class items 后调用
  Future<void> refreshClassItems() async {
    await _loadAllData();
  }

  // 假设你还需要一个方法来刷新所有模板数据，比如从 Newguide 页面返回后
  Future<void> refreshAllData() async {
    await _loadAllData();
  }
}
