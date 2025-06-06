import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/components/settings_list_item.dart'; // 调整为你实际的路径

void main() {
  group('SettingsListItem', () {
    // Helper function to pump the SettingsListItem into the test environment
    Future<void> pumpSettingsListItem(
      WidgetTester tester, {
      Key? key,
      required IconData icon,
      required String title,
      Widget? subtitle,
      Widget? trailing,
      VoidCallback? onTap,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListItem(
              key: key,
              icon: icon,
              title: title,
              subtitle: subtitle,
              trailing: trailing,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('renders icon and title correctly',
        (WidgetTester tester) async {
      await pumpSettingsListItem(
        tester,
        icon: Icons.settings,
        title: 'General Settings',
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('General Settings'), findsOneWidget);
    });

    testWidgets('renders default trailing arrow icon when trailing is null',
        (WidgetTester tester) async {
      await pumpSettingsListItem(
        tester,
        icon: Icons.settings,
        title: 'General Settings',
        trailing: null, // Explicitly null
      );

      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
    });

    testWidgets('renders custom trailing widget when provided',
        (WidgetTester tester) async {
      const customTrailingKey = Key('customTrailingText');
      await pumpSettingsListItem(
        tester,
        icon: Icons.color_lens,
        title: 'Mode Selection',
        trailing: const Text('Normal Mode', key: customTrailingKey),
      );

      expect(find.byIcon(Icons.keyboard_arrow_right),
          findsNothing); // Should not have default arrow
      expect(find.byKey(customTrailingKey), findsOneWidget);
      expect(find.text('Normal Mode'), findsOneWidget);
    });

    testWidgets('renders subtitle correctly when provided',
        (WidgetTester tester) async {
      await pumpSettingsListItem(
        tester,
        icon: Icons.vpn_key,
        title: 'Current Saved Key',
        subtitle: const Text('Key is saved'),
      );

      expect(find.text('Key is saved'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;
      await pumpSettingsListItem(
        tester,
        icon: Icons.person,
        title: 'Account',
        onTap: () {
          tapped = true;
        },
      );

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('can be found by its key', (WidgetTester tester) async {
      const itemKey = Key('testSettingsItem');
      await pumpSettingsListItem(
        tester,
        key: itemKey,
        icon: Icons.info,
        title: 'About App',
      );

      expect(find.byKey(itemKey), findsOneWidget);
    });
  });
}
