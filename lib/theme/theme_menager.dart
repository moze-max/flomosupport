// flomosupport/theme/theme_menager.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  // 定义存储 key
  static const String _themeModeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system; // 默认值

  ThemeMode get currentThemeMode => _themeMode;

  // ✨ 1. 初始化加载主题设置 ✨
  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedModeString = prefs.getString(_themeModeKey);

    if (savedModeString != null) {
      // 将保存的字符串转回 ThemeMode 枚举
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString().split('.').last == savedModeString,
        orElse: () => ThemeMode.system, // 如果找不到匹配，则默认跟随系统
      );
    }
    // 注意：这里不需要 notifyListeners()，因为这是在应用启动前设置的初始值
  }

  // ✨ 2. 设置并保存主题模式 ✨
  void setThemeMode(ThemeMode newMode) {
    if (_themeMode != newMode) {
      _themeMode = newMode;
      _saveThemeMode(newMode); // 保存到本地
      notifyListeners();
    }
  }

  // 辅助函数：保存数据到 SharedPreferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    // 将 ThemeMode 枚举转为字符串保存（例如: ThemeMode.dark -> 'dark'）
    await prefs.setString(_themeModeKey, mode.toString().split('.').last);
  }

  // ... 你的 toggleTheme 方法可以调用 setThemeMode
  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
