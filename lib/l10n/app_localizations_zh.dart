// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '浮墨支持';

  @override
  String get homePageTitle => '首页';

  @override
  String get articlePageTitle => '文章';

  @override
  String get guidePageTitle => '指南';

  @override
  String get aboutPageTitle => '关于我们';

  @override
  String get notificationPageTitle => '通知';

  @override
  String helloMessage(Object userName) {
    return '你好，$userName！';
  }

  @override
  String get welcomeButton => '欢迎';

  @override
  String get bottomNavGuide => '写作指南';

  @override
  String get bottomNavArticle => '文章';

  @override
  String get aboutDeveloperIntro => '我只是一个路过的flomo使用者，没有他们那么强大的力量制作高级的产品';

  @override
  String get contactInfo => '定制联系:\nQQ:3023713469\n微信:同号';

  @override
  String get sponsorUs => '赞助我们:';
}
