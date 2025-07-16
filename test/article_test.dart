// test/article_test.dart

import 'package:flomosupport/components/settings_list_item.dart';
import 'package:flomosupport/components/settings_section_header.dart';
import 'package:flomosupport/pages/article.dart';
import 'package:flomosupport/pages/article/APIkey.dart';
import 'package:flomosupport/pages/article/GeneralSettings.dart';
import 'package:flomosupport/pages/article/notificationsetting.dart';
import 'package:flomosupport/pages/article/AccountSecurity.dart';
import 'package:flomosupport/pages/article/privacy/info.dart';
import 'package:flomosupport/pages/article/privacy/privacy_tip.dart';
import 'package:flomosupport/pages/article/privacy/security.dart';
import 'package:flomosupport/pages/article/privacy/sharelist.dart';
import 'package:flomosupport/pages/class_items_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flomosupport/pages/article/about.dart';
import 'package:provider/provider.dart';
import 'package:flomosupport/functions/avatar_notifier.dart';
import 'dart:io'; // Import dart:io for File

// Import mocktail
import 'package:mocktail/mocktail.dart';

// --- Mock Classes using Mocktail ---
class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAvatarNotifier extends Mock implements AvatarNotifier {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late MockAvatarNotifier mockAvatarNotifier;
  late MockNavigatorObserver
      mockNavigatorObserver; // Add mock navigator observer

  // Use setUpAll to register fallbacks for non-primitive types
  setUpAll(() {
    registerFallbackValue(File('dummy_path.png')); // For File type
    registerFallbackValue(MaterialPageRoute<dynamic>(
        builder: (_) =>
            Container())); // For Route<dynamic> or MaterialPageRoute
  });

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    mockAvatarNotifier = MockAvatarNotifier();
    mockNavigatorObserver =
        MockNavigatorObserver(); // Initialize mock navigator observer

    // Provide a default behavior for read method to avoid null issues in tests
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    // Provide a default behavior for AvatarNotifier: initially no avatar
    when(() => mockAvatarNotifier.currentAvatar).thenReturn(null);
    // Mocktail: Use thenAnswer for void methods, no explicit casting needed for `any()`
    when(() => mockAvatarNotifier.addListener(any())).thenAnswer((_) {});
    when(() => mockAvatarNotifier.removeListener(any())).thenAnswer((_) {});

    // Mock NavigatorObserver for navigation tests
    when(() => mockNavigatorObserver.didPush(any(), any())).thenAnswer((_) {});
    when(() => mockNavigatorObserver.didPop(any(), any())).thenAnswer((_) {});
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
          key: GlobalKey<
              ScaffoldState>(), // Provide a scaffoldKey for the outer Scaffold
          body: ChangeNotifierProvider<AvatarNotifier>.value(
            value: mockAvatarNotifier, // Provide the mock AvatarNotifier
            child: Article(
                scaffoldKey: GlobalKey<
                    ScaffoldState>()), // Provide a scaffoldKey for the Article widget
          ),
        ),
        navigatorObservers: [mockNavigatorObserver], // Add navigator observer
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

        // Find the "Account and Security" list item
        final accountAndSecurityItemFinder =
            find.byKey(const Key('accountAndSecurityItem'));
        expect(accountAndSecurityItemFinder, findsOneWidget);

        // Tap the item
        await tester.tap(accountAndSecurityItemFinder);
        await tester.pumpAndSettle();

        // Verify navigation to AccountsecurityPage
        expect(find.byType(AccountsecurityPage), findsOneWidget);
        // Verify didPush was called with AccountsecurityPage route
        verify(() => mockNavigatorObserver.didPush(
              any(that: isA<MaterialPageRoute<dynamic>>()),
              any(),
            )).called(1);
      },
    );

    testWidgets(
      'navigates to Security page when "Personal Info Protection" is tapped',
      (WidgetTester tester) async {
        final AppLocalizations l10n = await pumpArticleWidget(tester);
        await tester.pumpAndSettle();

        // Find the main scrollable area
        final verticalScrollable = find.byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
          description: 'vertical Scrollable',
        );
        expect(verticalScrollable, findsOneWidget);

        // Find the "Personal Info Protection" list item by its key
        final personalInfoProtectionItemFinder =
            find.byKey(const ValueKey('personalInfoProtectionItem'));
        expect(personalInfoProtectionItemFinder, findsOneWidget);

        // Scroll until the item is visible
        await tester.scrollUntilVisible(
          personalInfoProtectionItemFinder,
          500.0,
          scrollable: verticalScrollable,
          continuous: true,
        );
        await tester.pumpAndSettle();

        // Tap the item
        await tester.tap(personalInfoProtectionItemFinder);
        await tester.pumpAndSettle();

        // Verify navigation to Security page
        expect(find.byType(Security), findsOneWidget);
        // Verify didPush was called with Security route
        verify(() => mockNavigatorObserver.didPush(
              any(that: isA<MaterialPageRoute<dynamic>>()),
              any(),
            )).called(1);
      },
    );

    testWidgets(
        'renders all expected SettingsListItems titles, icons and special properties',
        (WidgetTester tester) async {
      final AppLocalizations l10n = await pumpArticleWidget(tester);
      await tester.pumpAndSettle();

      final mainScrollableFinder =
          find.byKey(const Key('mainSettingsScrollView'));
      expect(mainScrollableFinder, findsOneWidget);

      final verticalScrollable = find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
        description: 'vertical Scrollable',
      );

      // Define all expected list item data, matching the Article widget's actual content
      final List<Map<String, dynamic>> expectedItems = [
        {
          'key': const Key('accountAndSecurityItem'),
          'title': l10n.accountAndSecurity,
          'icon': Icons.person_outline,
          'trailing_type':
              'custom_row', // Indicates a custom Row with avatar and arrow
        },
        {
          'key': const Key('messageNotificationsItem'),
          'title': l10n.messageNotifications,
          'icon': Icons.notifications_none,
          'trailing_type': 'arrow',
        },
        {
          'key': const Key('modeSelectionItem'),
          'title': l10n.modeSelection,
          'icon': Icons.color_lens_outlined,
          'trailing_text': l10n.normalMode, // Special: trailing is Text
        },
        {
          'key': const Key('ClassItemManagement'), // Added missing item
          'title': l10n.classItemManagement,
          'icon': Icons.align_horizontal_left_rounded,
          'trailing_type': 'arrow',
        },
        {
          'key': const Key('generalSettingsItem'),
          'title': l10n.generalSettings,
          'icon': Icons.settings_outlined,
          'trailing_type': 'arrow',
        },
        {
          'key': const Key('currentSavedKeyItem'),
          'title': l10n.currentSavedKey,
          'icon': Icons.vpn_key_outlined,
          'subtitle_text':
              l10n.keyStatusNotSet, // Special: has specific subtitle text
          'trailing_type':
              'arrow', // Assuming SettingsListItem adds arrow by default if trailing is null
        },
        {
          'key': const Key('privacySettingsItem'),
          'title': l10n.privacySettings,
          'icon': Icons.privacy_tip_outlined,
          'trailing_type': 'arrow',
        },
        {
          'key': const Key('personalInfoCollectionItem'),
          'title': l10n.personalInfoCollection,
          'icon': Icons.info_outline,
          'trailing_type': 'arrow',
        },
        {
          'key': const Key('thirdPartyInfoSharingItem'),
          'title': l10n.thirdPartyInfoSharing,
          'icon': Icons.share_outlined,
          'trailing_type': 'arrow',
        },
        {
          'key': const ValueKey(
              'personalInfoProtectionItem'), // Use ValueKey as in widget
          'title': l10n.personalInfoProtection,
          'icon': Icons.security,
          'trailing_type': 'arrow',
        },
      ];

      for (var itemData in expectedItems) {
        final key = itemData['key'] as Key;
        final title = itemData['title'] as String;
        final icon = itemData['icon'] as IconData;

        // Build target Finder using the item's key
        final listItemFinder = find.byKey(key);

        // Scroll to the item to ensure visibility
        await tester.scrollUntilVisible(
          listItemFinder,
          100.0, // Scroll amount
          scrollable: verticalScrollable,
          continuous: true,
        );
        await tester.pumpAndSettle(); // Wait for scroll and render to complete

        // Verify basic rendering: title and icon
        expect(listItemFinder, findsOneWidget,
            reason: 'Expected to find SettingsListItem with key: "$key"');
        expect(find.descendant(of: listItemFinder, matching: find.byIcon(icon)),
            findsOneWidget,
            reason:
                'Expected to find icon ${icon.toString()} for item with key: "$key"');
        expect(find.descendant(of: listItemFinder, matching: find.text(title)),
            findsOneWidget,
            reason:
                'Expected to find title "$title" for item with key: "$key"');

        // Verify special properties
        if (itemData.containsKey('trailing_type')) {
          if (itemData['trailing_type'] == 'arrow') {
            expect(
                find.descendant(
                    of: listItemFinder,
                    matching: find.byIcon(Icons.keyboard_arrow_right)),
                findsOneWidget,
                reason: 'Expected default arrow for item with key: "$key"');
          } else if (itemData['trailing_type'] == 'custom_row') {
            // For 'Account and Security', check for CircleAvatar and arrow
            expect(
                find.descendant(
                    of: listItemFinder, matching: find.byType(CircleAvatar)),
                findsOneWidget,
                reason:
                    'Expected CircleAvatar in trailing for item with key: "$key"');
            expect(
                find.descendant(
                    of: listItemFinder,
                    matching: find.byIcon(Icons.keyboard_arrow_right)),
                findsOneWidget,
                reason: 'Expected arrow in trailing for item with key: "$key"');
          }
        } else if (itemData.containsKey('trailing_text')) {
          expect(
              find.descendant(
                  of: listItemFinder,
                  matching: find.text(itemData['trailing_text'])),
              findsOneWidget,
              reason:
                  'Expected custom trailing text "${itemData['trailing_text']}" for item with key: "$key"');
          expect(
              find.descendant(
                  of: listItemFinder,
                  matching: find.byIcon(Icons.keyboard_arrow_right)),
              findsNothing,
              reason:
                  'Should not have default arrow for item with key: "$key" with custom trailing');
        }

        if (itemData.containsKey('subtitle_text')) {
          expect(
              find.descendant(
                  of: listItemFinder,
                  matching: find.text(itemData['subtitle_text'])),
              findsOneWidget,
              reason:
                  'Expected specific subtitle "${itemData['subtitle_text']}" for item with key: "$key"');
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

      // Define the expected properties for all SettingsListItems, matching the widget
      final List<Map<String, dynamic>> expectedItems = [
        {
          'key': const Key('accountAndSecurityItem'),
          'title': l10n.accountAndSecurity,
          'hasArrow': true,
          'hasCustomTrailing':
              true, // Indicates presence of CircleAvatar + Arrow
          'hasSubtitle': false,
        },
        {
          'key': const Key('messageNotificationsItem'),
          'title': l10n.messageNotifications,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
        {
          'key': const Key('modeSelectionItem'),
          'title': l10n.modeSelection,
          'hasArrow': false,
          'hasCustomTrailing': true,
          'customTrailingText': l10n.normalMode,
          'hasSubtitle': false,
        },
        {
          'key': const Key('ClassItemManagement'), // Added missing item
          'title': l10n.classItemManagement,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
        {
          'key': const Key('generalSettingsItem'),
          'title': l10n.generalSettings,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
        {
          'key': const Key('currentSavedKeyItem'),
          'title': l10n.currentSavedKey,
          'hasArrow': true, // SettingsListItem likely adds arrow by default
          'hasCustomTrailing': false,
          'hasSubtitle': true, // Has a subtitle
        },
        {
          'key': const Key('privacySettingsItem'),
          'title': l10n.privacySettings,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
        {
          'key': const Key('personalInfoCollectionItem'),
          'title': l10n.personalInfoCollection,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
        {
          'key': const Key('thirdPartyInfoSharingItem'),
          'title': l10n.thirdPartyInfoSharing,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
        {
          'key': const ValueKey('personalInfoProtectionItem'), // Use ValueKey
          'title': l10n.personalInfoProtection,
          'hasArrow': true,
          'hasCustomTrailing': false,
          'hasSubtitle': false,
        },
      ];

      for (final item in expectedItems) {
        final itemFinder = find.byKey(item['key'] as Key);
        final title = item['title'] as String;

        // 1. Ensure the item exists
        expect(itemFinder, findsOneWidget,
            reason: 'Expected to find item with key: ${item['key']}');

        // 2. Scroll to the item to ensure visibility
        await tester.scrollUntilVisible(
          itemFinder,
          100.0, // Scroll amount
          scrollable: verticalScrollableFinder,
          continuous: true,
        );
        await tester.pumpAndSettle(); // Wait for scroll and render to complete

        // 3. Assert title is correct
        expect(find.descendant(of: itemFinder, matching: find.text(title)),
            findsOneWidget,
            reason:
                'Expected item with key ${item['key']} to have title "$title"');

        // 4. Check for arrow or custom trailing text
        if (item['hasArrow'] as bool) {
          expect(
              find.descendant(
                  of: itemFinder,
                  matching: find.byIcon(Icons.keyboard_arrow_right)),
              findsOneWidget,
              reason:
                  'Item with key ${item['key']} ("$title") should have a keyboard_arrow_right icon.');
        } else {
          expect(
              find.descendant(
                  of: itemFinder,
                  matching: find.byIcon(Icons.keyboard_arrow_right)),
              findsNothing,
              reason:
                  'Item with key ${item['key']} ("$title") should NOT have a keyboard_arrow_right icon.');
        }

        if (item['hasCustomTrailing'] as bool) {
          if (item.containsKey('customTrailingText')) {
            expect(
                find.descendant(
                    of: itemFinder,
                    matching: find.text(item['customTrailingText'] as String)),
                findsOneWidget,
                reason:
                    'Item with key ${item['key']} ("$title") should have custom trailing text: "${item['customTrailingText']}".');
          } else if (item['key'] == const Key('accountAndSecurityItem')) {
            // Special check for Account and Security item's custom trailing (CircleAvatar + Arrow)
            expect(
                find.descendant(
                    of: itemFinder, matching: find.byType(CircleAvatar)),
                findsOneWidget,
                reason:
                    'Account and Security item should have a CircleAvatar.');
          }
        } else {
          // If no custom trailing is expected, ensure no other specific trailing widgets are present
          expect(
              find.descendant(
                  of: itemFinder, matching: find.byType(Text).at(1)),
              findsNothing,
              reason:
                  'Item with key ${item['key']} ("$title") should not have unexpected custom trailing text.');
          expect(
              find.descendant(
                  of: itemFinder, matching: find.byType(CircleAvatar)),
              findsNothing,
              reason:
                  'Item with key ${item['key']} ("$title") should not have a CircleAvatar.');
        }

        // 5. Check for subtitle presence and content
        if (item['hasSubtitle'] as bool) {
          expect(
              find.descendant(
                  of: itemFinder, matching: find.byType(Text).at(1)),
              findsOneWidget,
              reason:
                  'Item with key ${item['key']} ("$title") should have a subtitle.');
          if (item['key'] == const Key('currentSavedKeyItem')) {
            expect(
                find.descendant(
                    of: itemFinder, matching: find.text(l10n.keyStatusNotSet)),
                findsOneWidget,
                reason:
                    'Current Saved Key item should have subtitle "${l10n.keyStatusNotSet}".');
          }
        } else {
          // Ensure no unexpected subtitle
          final allTexts = tester
              .widgetList(
                  find.descendant(of: itemFinder, matching: find.byType(Text)))
              .toList();
          expect(allTexts.length, lessThanOrEqualTo(1),
              reason:
                  'Item with key ${item['key']} ("$title") should not have an unexpected subtitle.');
        }
      }
    });

    testWidgets(
      'updates avatar when AvatarNotifier changes',
      (WidgetTester tester) async {
        // Initial pump with no avatar
        await pumpArticleWidget(tester);
        await tester.pumpAndSettle();

        // Verify initial state: default icon is shown
        final initialAvatarFinder = find.descendant(
          of: find.byKey(const Key('accountAndSecurityItem')),
          matching: find.byIcon(Icons.account_circle),
        );
        expect(initialAvatarFinder, findsOneWidget,
            reason: 'Expected default avatar icon initially.');
        expect(find.byType(CircleAvatar),
            findsOneWidget); // Ensure CircleAvatar is present

        // Simulate a new avatar being set
        final testFile = File('test_avatar.png'); // Create a dummy file path
        when(() => mockAvatarNotifier.currentAvatar).thenReturn(testFile);

        // Trigger a rebuild by calling notifyListeners on the mock.
        await tester
            .pump(); // This re-reads the provider and triggers a rebuild
        await tester
            .pumpAndSettle(); // Wait for animations/rebuilds to complete

        // Verify the avatar has updated to the FileImage
        final updatedAvatarFinder = find.descendant(
          of: find.byKey(const Key('accountAndSecurityItem')),
          matching: find.byType(CircleAvatar),
        );
        expect(updatedAvatarFinder, findsOneWidget,
            reason: 'Expected CircleAvatar to be present after update.');

        final CircleAvatar avatarWidget = tester.widget(updatedAvatarFinder);
        expect(avatarWidget.backgroundImage, isA<FileImage>(),
            reason: 'Expected FileImage as background after avatar update.');
        expect((avatarWidget.backgroundImage as FileImage).file.path,
            testFile.path,
            reason: 'Expected background image to match the test file path.');
        expect(
            find.descendant(
                of: updatedAvatarFinder,
                matching: find.byIcon(Icons.account_circle)),
            findsNothing,
            reason: 'Default icon should be gone after avatar update.');
      },
    );
  });
}
