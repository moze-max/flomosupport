// // themes.dart
// import 'package:flutter/material.dart';

// // 亮色主题
// final ThemeData lightTheme = ThemeData(
//   useMaterial3: true, // 启用 Material 3 设计语言
//   fontFamily: 'NotoSansSC',
//   brightness: Brightness.light,
//   colorScheme: ColorScheme.light(
//     primary: Colors.blue, // 主要品牌色
//     onPrimary: Colors.white, // 主要品牌色上的内容颜色 (例如：AppBar 标题)
//     primaryContainer: Colors.blue.shade100, // 主要品牌色的容器色
//     onPrimaryContainer: Colors.black, // 主要品牌色容器上的内容颜色

//     secondary: Colors.amber, // 次要强调色
//     onSecondary: Colors.black, // 次要强调色上的内容颜色
//     secondaryContainer: Colors.amber.shade100, // 次要强调色的容器色
//     onSecondaryContainer: Colors.black, // 次要强调色容器上的内容颜色

//     tertiary: Colors.purple, // 第三色 (可选，用于辅助强调或区分)
//     onTertiary: Colors.white,
//     tertiaryContainer: Colors.purple.shade100,
//     onTertiaryContainer: Colors.black,

//     error: Colors.red.shade700, // 错误色
//     onError: Colors.white, // 错误色上的内容颜色
//     errorContainer: Colors.red.shade100,
//     onErrorContainer: Colors.black, // 背景色上的内容颜色

//     surface: Colors.white, // 卡片、Sheet、菜单等表面的背景色
//     onSurface: Colors.black, // 表面背景色上的内容颜色
//     surfaceContainerHighest: Colors.grey.shade200, // 表面的变体色 (例如：输入框填充色)
//     onSurfaceVariant: Colors.grey.shade700, // 表面变体色上的内容颜色

//     outline: Colors.grey.shade400, // 边框颜色
//     shadow: Colors.black.withValues(alpha: 25.5), // 阴影颜色
//     inverseSurface: Colors.grey.shade900, // 与 surface 对比的颜色 (用于深色模式下的亮色元素)
//     onInverseSurface: Colors.white, // inverseSurface 上的内容颜色
//     inversePrimary: Colors.blue.shade200, // 与 primary 对比的颜色 (用于深色模式下的亮色主要色)
//     // 其他颜色属性...
//   ),
//   appBarTheme: const AppBarTheme(
//     backgroundColor: Colors.blue,
//     foregroundColor: Colors.white, // 替代旧的 brightness
//     // titleTextStyle 替代旧的 TextTheme.headline6
//     titleTextStyle: TextStyle(
//       color: Colors.white,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//     iconTheme: IconThemeData(color: Colors.white),
//   ),
//   cardTheme: CardThemeData(
//     color: Colors.white,
//     elevation: 2,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   ),
//   // TextTheme 更新了命名规范，例如 bodyText1 -> bodyLarge, bodyText2 -> bodyMedium
//   textTheme: const TextTheme(
//     displayLarge: TextStyle(
//         fontSize: 57, fontWeight: FontWeight.normal, color: Colors.black),
//     displayMedium: TextStyle(
//         fontSize: 45, fontWeight: FontWeight.normal, color: Colors.black),
//     displaySmall: TextStyle(
//         fontSize: 36, fontWeight: FontWeight.normal, color: Colors.black),

//     headlineLarge: TextStyle(
//         fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
//     headlineMedium: TextStyle(
//         fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
//     headlineSmall: TextStyle(
//         fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),

//     titleLarge: TextStyle(
//         fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
//     titleMedium: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w500,
//         color: Colors.black), // 对应之前的 subtitle1
//     titleSmall: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: Colors.black), // 对应之前的 subtitle2

//     bodyLarge: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.normal,
//         color: Colors.black87), // 对应之前的 bodyText1
//     bodyMedium: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.normal,
//         color: Colors.black54), // 对应之前的 bodyText2
//     bodySmall: TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.normal,
//         color: Colors.black54), // 对应之前的 caption

//     labelLarge: TextStyle(
//         fontSize: 14,
//         fontWeight: FontWeight.w500,
//         color: Colors.black), // 对应之前的 button
//     labelMedium: TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.normal,
//         color: Colors.black), // 对应之前的 overline
//     labelSmall: TextStyle(
//         fontSize: 11, fontWeight: FontWeight.normal, color: Colors.black),
//   ),
//   // 其他亮色模式下的样式配置
// );

// // 暗色主题
// final ThemeData darkTheme = ThemeData(
//   useMaterial3: true, // 启用 Material 3 设计语言
//   fontFamily: 'NotoSansSC',
//   brightness: Brightness.dark,
//   colorScheme: ColorScheme.dark(
//     primary: Colors.blue.shade200, // 暗色模式下的主要品牌色
//     onPrimary: Colors.black,
//     primaryContainer: Colors.blue.shade700,
//     onPrimaryContainer: Colors.white,

//     secondary: Colors.orange.shade200,
//     onSecondary: Colors.black,
//     secondaryContainer: Colors.orange.shade700,
//     onSecondaryContainer: Colors.white,

//     tertiary: Colors.purple.shade200,
//     onTertiary: Colors.black,
//     tertiaryContainer: Colors.purple.shade700,
//     onTertiaryContainer: Colors.white,

//     error: Colors.red.shade400,
//     onError: Colors.black,
//     errorContainer: Colors.red.shade900,
//     onErrorContainer: Colors.white,

//     surface: Colors.grey.shade900, // 卡片、Sheet、菜单等表面的背景色
//     onSurface: Colors.white, // 表面背景色上的内容颜色
//     surfaceContainerHighest: Colors.grey.shade800, // 表面的变体色
//     onSurfaceVariant: Colors.grey.shade300,

//     outline: Colors.grey.shade600,
//     shadow: Colors.black.withOpacity(0.3),
//     inverseSurface: Colors.grey.shade200,
//     onInverseSurface: Colors.black,
//     inversePrimary: Colors.blue.shade800,
//     // 其他颜色属性...
//   ),
//   appBarTheme: AppBarTheme(
//     backgroundColor: Colors.grey.shade900, // AppBar 的深色背景
//     foregroundColor: Colors.white,
//     titleTextStyle: const TextStyle(
//       color: Colors.white,
//       fontSize: 20,
//       fontWeight: FontWeight.bold,
//     ),
//     iconTheme: const IconThemeData(color: Colors.white),
//   ),
//   cardTheme: CardThemeData(
//     color: Colors.grey.shade800, // 卡片背景色
//     elevation: 2,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   ),
//   textTheme: const TextTheme(
//     displayLarge: TextStyle(
//         fontSize: 57, fontWeight: FontWeight.normal, color: Colors.white),
//     displayMedium: TextStyle(
//         fontSize: 45, fontWeight: FontWeight.normal, color: Colors.white),
//     displaySmall: TextStyle(
//         fontSize: 36, fontWeight: FontWeight.normal, color: Colors.white),
//     headlineLarge: TextStyle(
//         fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
//     headlineMedium: TextStyle(
//         fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
//     headlineSmall: TextStyle(
//         fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
//     titleLarge: TextStyle(
//         fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
//     titleMedium: TextStyle(
//         fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
//     titleSmall: TextStyle(
//         fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
//     bodyLarge: TextStyle(
//         fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white70),
//     bodyMedium: TextStyle(
//         fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white54),
//     bodySmall: TextStyle(
//         fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white54),
//     labelLarge: TextStyle(
//         fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
//     labelMedium: TextStyle(
//         fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
//     labelSmall: TextStyle(
//         fontSize: 11, fontWeight: FontWeight.normal, color: Colors.white),
//   ),
//   // ... 更多暗色主题配置
// );

// themes.dart
import 'package:flutter/material.dart';

// 定义通用的字体家族
const String appFontFamily = 'NotoSansSC';

// 亮色主题
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  // ✨ 1. 全局字体设置：确保所有组件都默认使用此字体 ✨
  fontFamily: appFontFamily,
  brightness: Brightness.light,

  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    onPrimary: Colors.white,
    primaryContainer: Colors.blue.shade100,
    onPrimaryContainer: Colors.black,

    secondary: Colors.amber,
    onSecondary: Colors.black,
    secondaryContainer: Colors.amber.shade100,
    onSecondaryContainer: Colors.black,

    tertiary: Colors.purple,
    onTertiary: Colors.white,
    tertiaryContainer: Colors.purple.shade100,
    onTertiaryContainer: Colors.black,

    error: Colors.red.shade700,
    onError: Colors.white,
    errorContainer: Colors.red.shade100,
    onErrorContainer: Colors.black,

    surface: Colors.white,
    onSurface: Colors.black,
    surfaceContainerHighest: Colors.grey.shade200,
    onSurfaceVariant: Colors.grey.shade700,

    outline: Colors.grey.shade400,
    shadow: Colors.black.withOpacity(0.15), // 使用 withOpacity 确保类型正确
    inverseSurface: Colors.grey.shade900,
    onInverseSurface: Colors.white,
    inversePrimary: Colors.blue.shade200,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      // 注意: 这里不需要重复设置 fontFamily，它会继承根配置
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // ✨ 2. 底部导航栏主题配置 (日间模式) ✨
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white, // 背景使用 surface
    selectedItemColor: Colors.blue, // 选中项颜色使用 primary
    unselectedItemColor: Colors.grey.shade600, // 未选中项颜色
    elevation: 8,
    type: BottomNavigationBarType.fixed, // 避免切换主题时重新计算布局
  ),

  // ✨ 3. 修正 CardTheme 类名并使用合适的颜色 ✨
  cardTheme: CardThemeData(
    color: Colors.white, // 使用 colorScheme.surface
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),

  // 4. TextTheme 修正: 保持颜色配置，但依赖根部的 fontFamily
  textTheme: const TextTheme(
    // ... 保持你原有的颜色配置，但不再需要重复的 fontFamily ...
    displayLarge: TextStyle(
        fontSize: 57, fontWeight: FontWeight.normal, color: Colors.black),
    displayMedium: TextStyle(
        fontSize: 45, fontWeight: FontWeight.normal, color: Colors.black),
    // ... (其他文本样式) ...
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black87),
    // ...
  ),

  // 额外补充：按钮主题 (可选)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
    ),
  ),
);

// ---------------------------------------------------------------------

// 暗色主题
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  // ✨ 1. 全局字体设置：确保所有组件都默认使用此字体 ✨
  fontFamily: appFontFamily,
  brightness: Brightness.dark,

  colorScheme: ColorScheme.dark(
    primary: Colors.blue.shade200,
    onPrimary: Colors.black,
    primaryContainer: Colors.blue.shade700,
    onPrimaryContainer: Colors.white,
    secondary: Colors.orange.shade200,
    onSecondary: Colors.black,
    secondaryContainer: Colors.orange.shade700,
    onSecondaryContainer: Colors.white,
    tertiary: Colors.purple.shade200,
    onTertiary: Colors.black,
    tertiaryContainer: Colors.purple.shade700,
    onTertiaryContainer: Colors.white,
    error: Colors.red.shade400,
    onError: Colors.black,
    errorContainer: Colors.red.shade900,
    onErrorContainer: Colors.white,
    surface: Colors.grey.shade900,
    onSurface: Colors.white,
    surfaceContainerHighest: Colors.grey.shade800,
    onSurfaceVariant: Colors.grey.shade300,
    outline: Colors.grey.shade600,
    shadow: Colors.black.withOpacity(0.3),
    inverseSurface: Colors.grey.shade200,
    onInverseSurface: Colors.black,
    inversePrimary: Colors.blue.shade800,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
    foregroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      // 注意: 这里不需要重复设置 fontFamily
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),

  // ✨ 2. 底部导航栏主题配置 (暗色模式) ✨
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.grey.shade900, // 背景使用 surface
    selectedItemColor: Colors.blue.shade200, // 选中项颜色使用 primary (暗色友好的变体)
    unselectedItemColor: Colors.grey.shade400, // 未选中项颜色
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),

  // ✨ 3. 修正 CardTheme 类名并使用合适的颜色 ✨
  cardTheme: CardThemeData(
    color: Colors.grey.shade800, // 使用 colorScheme.surfaceContainer
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),

  // 4. TextTheme 修正: 保持颜色配置，但依赖根部的 fontFamily
  textTheme: const TextTheme(
    // ... 保持你原有的颜色配置，但不再需要重复的 fontFamily ...
    bodyLarge: TextStyle(
        fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white70),
    // ...
  ),

  // 额外补充：按钮主题 (可选)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade200, // 使用亮色 primary 变体
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
    ),
  ),
);
