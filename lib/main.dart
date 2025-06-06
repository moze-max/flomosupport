import 'package:flomosupport/components/newguide.dart';
import 'package:flomosupport/pages/article/about.dart';
import 'package:flomosupport/pages/article/notificationsetting.dart';
import 'package:flomosupport/pages/getimageshare.dart';
import 'package:flomosupport/pages/homepage.dart';
import 'package:flomosupport/pages/notification.dart' as ntfic;
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'pages/article.dart';
import 'pages/guide.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<ScaffoldState> homepageScaffoldKey =
      GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return MaterialApp(
      routes: {
        '/article': (context) => Article(
              scaffoldKey: scaffoldKey,
            ),
        '/guide': (context) => Guide(
              scaffoldKey: scaffoldKey,
            ),
        '/newguide': (context) => Newguide(),
        '/about': (context) => About(),
        '/notification': (context) => ntfic.Notification(),
        '/notificationsetting': (context) => Notificationsetting(),
      },
      title: AppLocalizations.of(context)?.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'NotoSansSC',
      ),
      debugShowCheckedModeBanner: false,
      home: Homepage(
        pages: [
          Guide(scaffoldKey: homepageScaffoldKey), // Pass the key
          Article(scaffoldKey: homepageScaffoldKey), // Pass the key
          ShareImageWithTemplatePage(),
        ],
        homepagekey: homepageScaffoldKey,
      ),
    );
  }
}
