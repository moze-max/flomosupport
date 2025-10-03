// theme_manager.dart

import 'package:flomosupport/theme/theme_data.dart'; // 假设这里定义了 lightTheme 和 darkTheme
import 'package:flutter/material.dart';

class ThemeManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get currentThemeMode => _themeMode;
  ThemeData get lightThemeData => lightTheme;
  ThemeData get darkThemeData => darkTheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  set themeMode(ThemeMode newMode) {
    if (_themeMode != newMode) {
      _themeMode = newMode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    // if (_themeMode == ThemeMode.light) {
    //   themeMode = ThemeMode.dark;
    // } else {
    //   themeMode = ThemeMode.light;
    // }
    // 如果需要循环切换：
    themeMode = (_themeMode == ThemeMode.light)
        ? ThemeMode.dark
        : (_themeMode == ThemeMode.dark)
            ? ThemeMode.system
            : ThemeMode.light;
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }
}
