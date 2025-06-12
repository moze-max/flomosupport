import 'package:flomosupport/functions/class_items_notification.dart';
import 'package:flomosupport/pages/class_items_management.dart';
import 'package:flomosupport/pages/newguide.dart';
import 'package:flomosupport/pages/article/about.dart';
import 'package:flomosupport/pages/article/notificationsetting.dart';
import 'package:flomosupport/pages/homepage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/article.dart';
import 'pages/guide.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ClassItemNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<ScaffoldState> homepageScaffoldKey =
      GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
        '/classItemManagement': (context) => const ClassItemManagementPage(),
      },
      title: AppLocalizations.of(context)?.appTitle ?? 'Flomo Support',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'NotoSansSC',
      ),
      debugShowCheckedModeBanner: false,
      home: Homepage(
        pages: [
          Guide(scaffoldKey: homepageScaffoldKey),
          Article(scaffoldKey: homepageScaffoldKey),
        ],
        homepagekey: homepageScaffoldKey,
      ),
    );
  }
}
