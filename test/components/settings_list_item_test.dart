import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flomosupport/components/settings_list_item.dart'; // Using the assumed path from your project

void main() {
  group('SettingsListItem', () {
    // Test case 1: Basic rendering of icon, title, and default trailing
    testWidgets('displays icon, title, and default trailing icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          // MaterialApp is needed for inherited widgets like Theme, Navigator
          home: Scaffold(
            // Scaffold provides a basic material design layout
            body: SettingsListItem(
              icon: Icons.settings,
              title: 'General Settings',
            ),
          ),
        ),
      );

      // Verify if the icon is displayed
      expect(find.byIcon(Icons.settings), findsOneWidget);
      // Verify if the title text is displayed
      expect(find.text('General Settings'), findsOneWidget);
      // Verify if the default trailing icon (Icons.keyboard_arrow_right) is displayed
      expect(find.byIcon(Icons.keyboard_arrow_right), findsOneWidget);
      // Verify subtitle is NOT present when not provided
      expect(find.byKey(const Key('subtitle_text')), findsNothing);
    });

    // Test case 2: Custom trailing widget
    testWidgets('displays custom trailing widget when provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListItem(
              icon: Icons.info,
              title: 'About App',
              trailing: const Text('Version 1.0'),
            ),
          ),
        ),
      );

      // Verify if the custom trailing widget (Text('Version 1.0')) is displayed
      expect(find.text('Version 1.0'), findsOneWidget);
      // Verify that the default arrow icon is NOT displayed
      expect(find.byIcon(Icons.keyboard_arrow_right), findsNothing);
    });

    // Test case 3: onTap callback is triggered
    testWidgets('calls onTap callback when tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListItem(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap on the ListTile (which is the main interactive part of SettingsListItem)
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle(); // Rebuild the widget tree after the tap

      // Verify that the onTap callback was triggered
      expect(tapped, isTrue);
    });

    // Test case 4: onTap callback is null (no tap functionality)
    testWidgets('does not call onTap callback when onTap is null',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListItem(
              icon: Icons.lock,
              title: 'Privacy',
              // onTap is intentionally left null
            ),
          ),
        ),
      );

      // Attempt to tap on the ListTile
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      // Verify that the onTap callback was NOT triggered
      expect(tapped, isFalse);
    });

    // Test case 5: Subtitle rendering
    testWidgets('displays subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListItem(
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: const Text('Manage your notification preferences'),
            ),
          ),
        ),
      );

      // Verify if the subtitle text is displayed
      expect(find.text('Manage your notification preferences'), findsOneWidget);
    });

    // Test case 6: Combination of subtitle and custom trailing
    testWidgets('displays subtitle and custom trailing together',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsListItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: const Text('English (US)'),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English (US)'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_right),
          findsNothing); // Ensure default is not there
    });
  });
}
