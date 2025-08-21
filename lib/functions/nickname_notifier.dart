// lib/functions/nickname_notifier.dart
import 'package:flutter/material.dart';
import 'package:flomosupport/functions/storage_service.dart'; // 导入 StorageService

/// 一个用于管理用户昵称状态的 Change Notifier。
/// 它负责加载、保存和通知 UI 昵称的变更。
class NicknameNotifier extends ChangeNotifier {
  String? _currentNickname;

  String? get currentNickname => _currentNickname;

  // 默认构造函数，负责在初始化时加载昵称。
  NicknameNotifier() {
    _loadInitialNickname();
  }

  /// 从本地存储加载初始昵称。
  /// 如果没有找到昵称，则使用默认值。
  Future<void> _loadInitialNickname() async {
    _currentNickname = await StorageService.loadNickname();
    if (_currentNickname == null || _currentNickname!.isEmpty) {
      _currentNickname = '未设置昵称'; // 如果昵称为空，设置一个默认值
    }
    notifyListeners(); // 通知所有监听者初始昵称已加载
  }

  /// 更新并保存新的昵称。
  /// 这个方法将在昵称设置页面调用。
  Future<void> updateNickname(String newNickname) async {
    if (newNickname.isNotEmpty) {
      await StorageService.saveNickname(newNickname);
      _currentNickname = newNickname;
    } else {
      // 如果传入空字符串，将昵称设置为空
      _currentNickname = '未设置昵称';
      await StorageService.saveNickname(''); // 在存储中也保存为空
    }
    notifyListeners(); // 通知所有监听者昵称已更新
  }
}
