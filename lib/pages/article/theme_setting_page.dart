import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flomosupport/theme/theme_menager.dart'; // 导入你的 ThemeManager

class ThemeSettingPage extends StatelessWidget {
  const ThemeSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 来监听 ThemeManager 的变化，并获取实例
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) {
        // 当前选择的模式，用于高亮按钮
        final currentMode = themeManager.currentThemeMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('主题设置'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '选择应用主题模式',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                // ------------------------------------
                // 按钮组
                // ------------------------------------
                _buildThemeModeButton(
                  context,
                  themeManager,
                  mode: ThemeMode.system,
                  label: '跟随系统',
                  isSelected: currentMode == ThemeMode.system,
                ),
                const SizedBox(height: 10),
                _buildThemeModeButton(
                  context,
                  themeManager,
                  mode: ThemeMode.light,
                  label: '日间模式 (Light)',
                  isSelected: currentMode == ThemeMode.light,
                ),
                const SizedBox(height: 10),
                _buildThemeModeButton(
                  context,
                  themeManager,
                  mode: ThemeMode.dark,
                  label: '夜间模式 (Dark)',
                  isSelected: currentMode == ThemeMode.dark,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 构建单个主题切换按钮的辅助方法
  Widget _buildThemeModeButton(
    BuildContext context,
    ThemeManager themeManager, {
    required ThemeMode mode,
    required String label,
    required bool isSelected,
  }) {
    // 根据是否选中来调整颜色和样式
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color buttonColor = isSelected
        ? primaryColor
        : Theme.of(context).colorScheme.surfaceVariant;
    final Color textColor = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // 调用 ThemeManager 的方法来设置新的模式
          themeManager.setThemeMode(mode);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            // 如果选中，添加边框以增强效果
            side: isSelected
                ? BorderSide(color: primaryColor, width: 2)
                : BorderSide.none,
          ),
          elevation: isSelected ? 4 : 1, // 选中时稍微提高阴影
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
