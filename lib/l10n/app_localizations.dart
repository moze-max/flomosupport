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
  /// **'浮墨支持者'**
  String get appTitle;

  /// 首页标题的名字
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get homePageTitle;

  /// No description provided for @articlePageTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get articlePageTitle;

  /// No description provided for @guidePageTitle.
  ///
  /// In zh, this message translates to:
  /// **'模板'**
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

  /// No description provided for @welcomeButton.
  ///
  /// In zh, this message translates to:
  /// **'欢迎'**
  String get welcomeButton;

  /// No description provided for @bottomNavGuide.
  ///
  /// In zh, this message translates to:
  /// **'写作模板'**
  String get bottomNavGuide;

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

  /// No description provided for @notSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get notSet;

  /// No description provided for @searchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索设置'**
  String get searchHint;

  /// No description provided for @accountAndSecurity.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get accountAndSecurity;

  /// No description provided for @functionsSectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'功能'**
  String get functionsSectionTitle;

  /// No description provided for @messageNotifications.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get messageNotifications;

  /// No description provided for @modeSelection.
  ///
  /// In zh, this message translates to:
  /// **'模式选择'**
  String get modeSelection;

  /// No description provided for @normalMode.
  ///
  /// In zh, this message translates to:
  /// **'普通模式'**
  String get normalMode;

  /// No description provided for @personalization.
  ///
  /// In zh, this message translates to:
  /// **'个性装扮与特权外显'**
  String get personalization;

  /// No description provided for @generalSettings.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get generalSettings;

  /// No description provided for @apiKeySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'密钥管理'**
  String get apiKeySectionTitle;

  /// No description provided for @currentSavedKey.
  ///
  /// In zh, this message translates to:
  /// **'当前保存的密钥'**
  String get currentSavedKey;

  /// No description provided for @keyStatusSaved.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get keyStatusSaved;

  /// No description provided for @keyStatusNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get keyStatusNotSet;

  /// No description provided for @apiKeyManagementPageTitle.
  ///
  /// In zh, this message translates to:
  /// **'API 密钥设置'**
  String get apiKeyManagementPageTitle;

  /// No description provided for @currentSavedKeyInfo.
  ///
  /// In zh, this message translates to:
  /// **'当前 API 密钥信息'**
  String get currentSavedKeyInfo;

  /// No description provided for @enterApiKey.
  ///
  /// In zh, this message translates to:
  /// **'输入/修改 API 密钥'**
  String get enterApiKey;

  /// No description provided for @apiKeyInputLabel.
  ///
  /// In zh, this message translates to:
  /// **'密钥'**
  String get apiKeyInputLabel;

  /// No description provided for @apiKeyHint.
  ///
  /// In zh, this message translates to:
  /// **'在此处输入您的密钥'**
  String get apiKeyHint;

  /// No description provided for @saveButton.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get saveButton;

  /// No description provided for @keySavedSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密钥保存成功！'**
  String get keySavedSuccess;

  /// No description provided for @apiKeyEmptyWarning.
  ///
  /// In zh, this message translates to:
  /// **'API 密钥不能为空！'**
  String get apiKeyEmptyWarning;

  /// No description provided for @privacySectionTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私'**
  String get privacySectionTitle;

  /// No description provided for @privacySettings.
  ///
  /// In zh, this message translates to:
  /// **'隐私设置'**
  String get privacySettings;

  /// No description provided for @personalInfoCollection.
  ///
  /// In zh, this message translates to:
  /// **'个人信息收集清单'**
  String get personalInfoCollection;

  /// No description provided for @thirdPartyInfoSharing.
  ///
  /// In zh, this message translates to:
  /// **'第三方个人信息共享清单'**
  String get thirdPartyInfoSharing;

  /// No description provided for @personalInfoProtection.
  ///
  /// In zh, this message translates to:
  /// **'个人信息保护设置'**
  String get personalInfoProtection;

  /// No description provided for @notificationsettingTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知设置'**
  String get notificationsettingTitle;

  /// No description provided for @classItemManagement.
  ///
  /// In zh, this message translates to:
  /// **'分类管理'**
  String get classItemManagement;
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
