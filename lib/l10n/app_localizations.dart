import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// App的标题
  ///
  /// In zh, this message translates to:
  /// **'浮墨支持'**
  String get appTitle;

  /// 首页标题的名字
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homePageTitle;

  /// No description provided for @articlePageTitle.
  ///
  /// In zh, this message translates to:
  /// **'文章'**
  String get articlePageTitle;

  /// No description provided for @guidePageTitle.
  ///
  /// In zh, this message translates to:
  /// **'指南'**
  String get guidePageTitle;

  /// No description provided for @aboutPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于我们'**
  String get aboutPageTitle;

  /// No description provided for @notificationPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notificationPageTitle;

  /// No description provided for @helloMessage.
  ///
  /// In zh, this message translates to:
  /// **'你好，{userName}！'**
  String helloMessage(Object userName);

  /// No description provided for @welcomeButton.
  ///
  /// In zh, this message translates to:
  /// **'欢迎'**
  String get welcomeButton;

  /// No description provided for @bottomNavGuide.
  ///
  /// In zh, this message translates to:
  /// **'写作指南'**
  String get bottomNavGuide;

  /// No description provided for @bottomNavArticle.
  ///
  /// In zh, this message translates to:
  /// **'文章'**
  String get bottomNavArticle;

  /// No description provided for @aboutDeveloperIntro.
  ///
  /// In zh, this message translates to:
  /// **'我只是一个路过的flomo使用者，没有他们那么强大的力量制作高级的产品'**
  String get aboutDeveloperIntro;

  /// No description provided for @contactInfo.
  ///
  /// In zh, this message translates to:
  /// **'定制联系:\nQQ:3023713469\n微信:同号'**
  String get contactInfo;

  /// No description provided for @sponsorUs.
  ///
  /// In zh, this message translates to:
  /// **'赞助我们:'**
  String get sponsorUs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
