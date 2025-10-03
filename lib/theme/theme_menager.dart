import 'package:flomosupport/theme/theme_data.dart';
import 'package:flutter/material.dart';

class ThemeMenager extends ChangeNotifier {
  ThemeData _themeData = lightTheme;
  ThemeData get currentthemedate => _themeData;

  bool get isdartmode => currentthemedate == darkTheme;

  set ThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightTheme) {
      ThemeData = darkTheme;
    } else {
      ThemeData = lightTheme;
    }
  }
}
