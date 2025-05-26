import 'package:flomosupport/components/newguide.dart';
import 'package:flomosupport/pages/about.dart';
import 'package:flomosupport/pages/homepage.dart';
import 'package:flomosupport/pages/notification.dart' as ntfic;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'pages/article.dart';
import 'pages/guide.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/article': (context) => const Article(),
        '/guide': (context) => const Guide(),
        '/newguide': (context) => Newguide(),
        '/about': (context) => About(),
        '/notification': (context) => ntfic.Notification(),
      },
      // title: 'Flomo Support',
      title: AppLocalizations.of(context)?.appTitle,
      // localizationsDelegates: [
      //   // 本地化的代理类
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: [
      //   const Locale('en', 'US'), // 美国英语
      //   const Locale('zh', 'CN'), // 中文简体
      //   //其他Locales
      // ],
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'NotoSansSC',
      ),
      debugShowCheckedModeBanner: false,
      home: Homepage(),
    );
  }
}
