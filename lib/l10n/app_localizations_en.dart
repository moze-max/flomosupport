// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flomo Support';

  @override
  String get homePageTitle => 'Homepage';

  @override
  String get articlePageTitle => 'Articles';

  @override
  String get guidePageTitle => 'Guides';

  @override
  String get aboutPageTitle => 'About Us';

  @override
  String get notificationPageTitle => 'Notifications';

  @override
  String helloMessage(Object userName) {
    return 'Hello, $userName!';
  }

  @override
  String get welcomeButton => 'Welcome';

  @override
  String get bottomNavGuide => 'Writing Guide';

  @override
  String get bottomNavArticle => 'Article';

  @override
  String get aboutDeveloperIntro =>
      'I am just a passing Flomo user, not possessing their powerful ability to create advanced products.';

  @override
  String get contactInfo =>
      'Custom Contact:\nQQ:3023713469\nWeChat: Same as QQ';

  @override
  String get sponsorUs => 'Sponsor Us:';
}
