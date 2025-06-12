// lib/functions/avatar_notifier.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flomosupport/functions/storage_service.dart'; // 导入 StorageService
import 'dart:developer' as developer;

class AvatarNotifier extends ChangeNotifier {
  File? _currentAvatar;

  File? get currentAvatar => _currentAvatar;

  AvatarNotifier() {
    _loadInitialAvatar();
  }

  Future<void> _loadInitialAvatar() async {
    _currentAvatar = await StorageService.loadAvatar();
    notifyListeners(); // 通知所有监听者初始头像已加载
  }

  // 这个方法将在 UserAvatarManager 中调用
  Future<void> updateAvatar(File? newAvatar) async {
    if (newAvatar != null) {
      final String? savedPath = await StorageService.saveAvatar(newAvatar);
      if (savedPath != null) {
        _currentAvatar = File(savedPath);
      } else {
        // 保存失败，可能需要处理错误或提示用户
        _currentAvatar = null; // 或者保持旧头像
      }
    } else {
      // 如果传入 null，表示删除头像
      await StorageService.deleteAvatar();
      _currentAvatar = null;
    }
    developer.log('准备通知监听者头像发生变更');
    notifyListeners(); // 通知所有监听者头像已更新
  }

  // 用于在删除头像时调用
  Future<void> deleteAvatar() async {
    await StorageService.deleteAvatar();
    _currentAvatar = null;
    notifyListeners(); // 通知所有监听者头像已删除
  }
}
