import 'package:flomosupport/components/settings_list_item.dart';
import 'package:flomosupport/pages/article.dart';
import 'package:flomosupport/pages/article/AccountSecurity.dart';
import 'package:flomosupport/pages/article/GeneralSettings.dart';
import 'package:flomosupport/pages/article/privacy/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'article_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
class ExpectedSettingsItem {
  final Key key; // The unique key for the SettingsListItem
  final String l10nTitle; // The localized title string
  final bool shouldHaveArrow; // True if it should have keyboard_arrow_right
  final String? customTrailingText; // If it has custom text instead of arrow

  const ExpectedSettingsItem({
    required this.key,
    required this.l10nTitle,
    this.shouldHaveArrow = true, // Default to true for arrow
    this.customTrailingText,
  });
}

void main() {
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    // Provide a default behavior for read method to avoid null issues in tests
    when(mockStorage.read(key: anyNamed('key'))).thenAnswer((_) async => null);
  });

  // Helper function to pump the widget with necessary ancestors
  Future<AppLocalizations> pumpArticleWidget(WidgetTester tester,
      {Locale locale = const Locale('zh')}) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('zh'),
        ],
        locale: locale,
        home: Scaffold(
          key: GlobalKey<ScaffoldState>(), // Provide a scaffoldKey
          body: Article(scaffoldKey: GlobalKey<ScaffoldState>()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final articleFinder = find.byType(Article);
    expect(articleFinder, findsOneWidget);

    final BuildContext context = tester.element(find.byType(Article));
    return AppLocalizations.of(context)!;
  }

  group('Article Widget Tests', () {
    testWidgets('renders search text field', (WidgetTester tester) async {
      final AppLocalizations l10n = await pumpArticleWidget(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text(l10n.searchHint), findsOneWidget);
    });

    testWidgets(
      'navigates to AccountSecurityPage when "Account and Security" is tapped',
      (WidgetTester tester) async {
        final AppLocalizations l10n = await pumpArticleWidget(tester);
        await tester.pumpAndSettle();

        // Step 1: 确保 ListView 存在
        final mainListView =
            find.byKey(const ValueKey('mainSettingsScrollView'));
        expect(mainListView, findsOneWidget);

        // Step 2: 找到主列表的 Scrollable（✅ 使用 axisDirection 过滤）
        final verticalScrollable = find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
          description: 'vertical Scrollable',
        );

        // Step 3: 定位目标 SettingsListItem
        final targetFinder = find.byKey(ValueKey('personalInfoProtectionItem'));

        final targetListItemFinder = find.descendant(
          of: find.byType(ListView), // Find within the ListView
          matching: find.widgetWithText(ListTile, l10n.personalInfoProtection),
        );
        final targetIconFinder = find.descendant(
          of: targetListItemFinder,
          matching: find.byIcon(Icons.security),
        );

        await tester.scrollUntilVisible(
          targetIconFinder, // Scroll to the icon as a clear target
          500.0,
          scrollable:
              verticalScrollable, // This is your uniquely identified ListView's Scrollable
          continuous: true, // Keep scrolling until visible
        );
        await tester.pumpAndSettle();

        expect(targetFinder, findsOneWidget);

        // Step 5: 点击 "Account and Security"
        final personalInfoProtectionFinder =
            find.text(l10n.personalInfoProtection);
        expect(personalInfoProtectionFinder, findsOneWidget);
        await tester.tap(personalInfoProtectionFinder);
        await tester.pumpAndSettle();

        // Step 6: 验证是否导航到了 AccountsecurityPage
        expect(find.byType(Security), findsOneWidget);
      },
    );

    testWidgets(
        'renders all expected SettingsListItems titles, icons and special properties',
        (WidgetTester tester) async {
      final AppLocalizations l10n = await pumpArticleWidget(tester);
      await tester.pumpAndSettle();

      final mainScrollableFinder =
          find.byKey(const ValueKey('mainSettingsScrollView'));
      expect(mainScrollableFinder, findsOneWidget);

      final verticalScrollable = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical Scrollable',
      );

      // 定义所有预期的列表项数据，包括特殊属性
      final List<Map<String, dynamic>> expectedItems = [
        {
          'title': l10n.accountAndSecurity,
          'icon': Icons.person_outline,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.messageNotifications,
          'icon': Icons.notifications_none,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.modeSelection,
          'icon': Icons.color_lens_outlined,
          'trailing_text': l10n.normalMode
        }, // 特殊：trailing 是 Text
        {
          'title': l10n.personalization,
          'icon': Icons.brush,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.generalSettings,
          'icon': Icons.settings_outlined,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.currentSavedKey,
          'icon': Icons.vpn_key_outlined,
          'subtitle_present': true
        }, // 特殊：有 subtitle
        {
          'title': l10n.privacySettings,
          'icon': Icons.privacy_tip_outlined,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.personalInfoCollection,
          'icon': Icons.info_outline,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.thirdPartyInfoSharing,
          'icon': Icons.share_outlined,
          'trailing_type': 'arrow'
        },
        {
          'title': l10n.personalInfoProtection,
          'icon': Icons.security,
          'trailing_type': 'arrow'
        },
      ];

      for (var itemData in expectedItems) {
        final title = itemData['title'] as String;
        final icon = itemData['icon'] as IconData;

        // 构建目标 Finder
        final listItemFinder = find.widgetWithText(SettingsListItem, title);
        final iconFinder =
            find.descendant(of: listItemFinder, matching: find.byIcon(icon));

        // 滚动到该项可见
        await tester.scrollUntilVisible(
          iconFinder,
          200.0, // 每次滚动少量，以便更好地跟踪进度
          scrollable: verticalScrollable,
          continuous: true,
        );
        await tester.pumpAndSettle();

        // 验证基本渲染：标题和图标
        expect(listItemFinder, findsOneWidget,
            reason: 'Expected to find SettingsListItem with title: "$title"');
        expect(iconFinder, findsOneWidget,
            reason:
                'Expected to find icon ${icon.toString()} for title: "$title"');

        // 验证特殊属性
        if (itemData.containsKey('trailing_type')) {
          if (itemData['trailing_type'] == 'arrow') {
            expect(
                find.descendant(
                    of: listItemFinder,
                    matching: find.byIcon(Icons.keyboard_arrow_right)),
                findsOneWidget,
                reason: 'Expected default arrow for "$title"');
          }
        } else if (itemData.containsKey('trailing_text')) {
          expect(
              find.descendant(
                  of: listItemFinder,
                  matching: find.text(itemData['trailing_text'])),
              findsOneWidget,
              reason:
                  'Expected custom trailing text "${itemData['trailing_text']}" for "$title"');
          expect(
              find.descendant(
                  of: listItemFinder,
                  matching: find.byIcon(Icons.keyboard_arrow_right)),
              findsNothing,
              reason:
                  'Should not have default arrow for "$title" with custom trailing');
        }

        if (itemData.containsKey('subtitle_present') &&
            itemData['subtitle_present'] == true) {
          // 对于 subtitle，你需要知道具体的文本才能断言，或者只断言它的存在
          expect(
              find.descendant(of: listItemFinder, matching: find.byType(Text)),
              findsWidgets,
              reason: 'Expected subtitle for "$title"');
          // 如果你知道 subtitle 的具体文本，可以这样断言：
          // expect(find.descendant(of: listItemFinder, matching: find.text('Key is saved')), findsOneWidget, reason: 'Expected specific subtitle for "$title"');
        }
      }
    });

    testWidgets(
        'verifies each SettingsListItem conforms to design (arrow or custom text)',
        (WidgetTester tester) async {
      final AppLocalizations l10n = await pumpArticleWidget(tester);
      await tester.pumpAndSettle();

      final verticalScrollableFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical Scrollable',
      );
      expect(verticalScrollableFinder, findsOneWidget,
          reason: 'Should find exactly one vertical Scrollable.');

      // Define the expected properties for all SettingsListItems
      final List<ExpectedSettingsItem> expectedItems = [
        ExpectedSettingsItem(
            key: const Key('accountAndSecurityItem'),
            l10nTitle: l10n.accountAndSecurity),
        ExpectedSettingsItem(
            key: const Key('messageNotificationsItem'),
            l10nTitle: l10n.messageNotifications),
        ExpectedSettingsItem(
          key: const Key('modeSelectionItem'),
          l10nTitle: l10n.modeSelection,
          shouldHaveArrow: false,
          customTrailingText: l10n.normalMode, // 确保这个文本与实际渲染的尾部文本一致
        ),
        ExpectedSettingsItem(
            key: const Key('personalizationItem'),
            l10nTitle: l10n.personalization),
        ExpectedSettingsItem(
            key: const Key('generalSettingsItem'),
            l10nTitle: l10n.generalSettings),
        ExpectedSettingsItem(
            key: const Key('currentSavedKeyItem'),
            l10nTitle: l10n.currentSavedKey),
        ExpectedSettingsItem(
            key: const Key('privacySettingsItem'),
            l10nTitle: l10n.privacySettings),
        ExpectedSettingsItem(
            key: const Key('personalInfoCollectionItem'),
            l10nTitle: l10n.personalInfoCollection),
        ExpectedSettingsItem(
            key: const Key('thirdPartyInfoSharingItem'),
            l10nTitle: l10n.thirdPartyInfoSharing),
        ExpectedSettingsItem(
            key: const Key('personalInfoProtectionItem'),
            l10nTitle: l10n.personalInfoProtection),
      ];

      int actualArrowCount = 0; // 用于统计实际找到的箭头数量

      for (final item in expectedItems) {
        final itemFinder = find.byKey(item.key);

        // 1. 确保该项存在
        expect(itemFinder, findsOneWidget,
            reason: 'Expected to find item with key: ${item.key}');

        // 2. 滚动到该项可见
        await tester.scrollUntilVisible(
          itemFinder,
          100.0, // 滚动量
          scrollable: verticalScrollableFinder,
          continuous: true,
        );
        await tester.pumpAndSettle(); // 等待滚动和渲染完成

        // 3. 断言标题是否正确（可选，但推荐）
        expect(
            find.descendant(
                of: itemFinder, matching: find.text(item.l10nTitle)),
            findsOneWidget,
            reason:
                'Expected item with key ${item.key} to have title "${item.l10nTitle}"');

        // 4. 根据预期检查箭头的存在或自定义尾部文本
        if (item.shouldHaveArrow) {
          expect(
              find.descendant(
                  of: itemFinder,
                  matching: find.byIcon(Icons.keyboard_arrow_right)),
              findsOneWidget,
              reason:
                  'Item with key ${item.key} ("${item.l10nTitle}") should have a keyboard_arrow_right icon.');
          actualArrowCount++; // 统计找到的箭头
        } else {
          expect(
              find.descendant(
                  of: itemFinder,
                  matching: find.byIcon(Icons.keyboard_arrow_right)),
              findsNothing,
              reason:
                  'Item with key ${item.key} ("${item.l10nTitle}") should NOT have a keyboard_arrow_right icon.');

          if (item.customTrailingText != null) {
            expect(
                find.descendant(
                    of: itemFinder,
                    matching: find.text(item.customTrailingText!)),
                findsOneWidget,
                reason:
                    'Item with key ${item.key} ("${item.l10nTitle}") should have custom trailing text: "${item.customTrailingText}".');
          }
        }
      }

      // 5. 最终断言总箭头数量
      // 根据您的设计，如果总共有 10 个 SettingsListItem，其中 1 个没有箭头 (模式选择)，
      // 那么最终的箭头数量应该是 9。
      expect(actualArrowCount, 9,
          reason:
              'Expected total count of keyboard_arrow_right icons to be 9.');
    });
  });
}
