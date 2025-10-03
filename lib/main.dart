import 'package:flomosupport/functions/avatar_notifier.dart';
import 'package:flomosupport/functions/class_items_notification.dart';
import 'package:flomosupport/functions/nickname_notifier.dart';
import 'package:flomosupport/pages/class_items_management.dart';
import 'package:flomosupport/pages/newguide.dart';
import 'package:flomosupport/pages/article/about.dart';
import 'package:flomosupport/pages/article/notificationsetting.dart';
import 'package:flomosupport/pages/homepage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flomosupport/theme/theme_data.dart';
import 'package:flomosupport/theme/theme_menager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/article.dart';
import 'pages/guide.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 加载theme保存值
  final themeManager = ThemeManager();
  await themeManager.loadThemeMode();
  // 创建一个 NicknameNotifier 的实例
  final nicknameNotifier = NicknameNotifier();
  await nicknameNotifier.initLoad();
  runApp(MyApp(
    nicknameNotifier: nicknameNotifier,
    themeManager: themeManager,
  ));
}

class MyApp extends StatelessWidget {
  final NicknameNotifier nicknameNotifier;
  MyApp({super.key, required this.nicknameNotifier, required themeManager});
  final GlobalKey<ScaffoldState> homepageScaffoldKey =
      GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AvatarNotifier()),
        ChangeNotifierProvider.value(
          value: nicknameNotifier,
        ),
        ChangeNotifierProvider(create: (_) => ClassItemNotifier()),
        ChangeNotifierProvider(create: (_) => ThemeManager())
      ],
      child: Consumer<ThemeManager>(builder: (context, themeManager, child) {
        return MaterialApp(
          routes: {
            '/article': (context) => Article(
                  scaffoldKey: homepageScaffoldKey,
                ),
            '/guide': (context) => Guide(
                  scaffoldKey: homepageScaffoldKey,
                ),
            '/newguide': (context) => Newguide(),
            '/about': (context) => About(),
            '/notificationsetting': (context) => Notificationsetting(),
            '/classItemManagement': (context) =>
                const ClassItemManagementPage(),
          },
          title: AppLocalizations.of(context)?.appTitle ?? 'Flomo Support',
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // theme: ThemeData(
          //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          //   fontFamily: 'NotoSansSC',
          // ),
          theme:
              lightTheme, // 假设 lightTheme 是从你的 theme_data.dart 导入的 ThemeData 实例
          darkTheme: darkTheme,
          themeMode: themeManager.currentThemeMode,
          debugShowCheckedModeBanner: false,
          home: Homepage(
            pages: [
              Guide(scaffoldKey: homepageScaffoldKey),
              Article(scaffoldKey: homepageScaffoldKey),
            ],
            homepagekey: homepageScaffoldKey,
          ),
        );
      }),
    );
  }
}
