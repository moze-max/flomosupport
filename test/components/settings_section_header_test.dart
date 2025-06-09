import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 假设你的 SettingsSectionHeader 在此路径
// import 'package:your_app_name/widgets/settings_section_header.dart';
import 'package:flomosupport/components/settings_section_header.dart'; // 假设的路径

void main() {
  group('SettingsSectionHeader', () {
    // Test case 1: Displays the provided title text
    testWidgets('displays the provided title text',
        (WidgetTester tester) async {
      const String testTitle = 'Account Settings';

      await tester.pumpWidget(
        const MaterialApp(
          // MaterialApp is needed for inherited widgets like Theme, TextDirection
          home: Scaffold(
            // Scaffold provides a basic material design layout
            body: SettingsSectionHeader(
              title: testTitle,
            ),
          ),
        ),
      );

      // Verify that the title text is displayed
      expect(find.text(testTitle), findsOneWidget);
    });

    // Test case 2: Applies the correct text style
    testWidgets('applies the correct text style', (WidgetTester tester) async {
      const String testTitle = 'Privacy Controls';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(
              title: testTitle,
            ),
          ),
        ),
      );

      // Find the Text widget
      final Finder textFinder = find.text(testTitle);
      expect(textFinder, findsOneWidget);

      // Get the Text widget from the tree and check its style
      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.style?.color, Colors.grey[600]);
      expect(textWidget.style?.fontSize, 14);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    // Test case 3: Applies the correct vertical padding
    testWidgets('applies the correct vertical padding',
        (WidgetTester tester) async {
      const String testTitle = 'App Preferences';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(
              title: testTitle,
            ),
          ),
        ),
      );

      // Find the Padding widget
      final Finder paddingFinder = find.byType(Padding);
      expect(paddingFinder, findsOneWidget);

      // Get the Padding widget from the tree
      final Padding paddingWidget = tester.widget(paddingFinder);

      // Check the padding values
      // Note: EdgeInsets.symmetric(vertical: 16.0) means 16.0 top and 16.0 bottom, 0.0 left/right
      expect(paddingWidget.padding, const EdgeInsets.symmetric(vertical: 16.0));
    });

    // Test case 4: Ensures only one Text widget is present
    testWidgets('contains only one Text widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(
              title: 'Header',
            ),
          ),
        ),
      );

      // Verify that there is exactly one Text widget with the given title
      expect(find.byType(Text), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
    });

    // Test case 4: Handles empty title string
    testWidgets('handles empty title string gracefully',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(title: ''),
          ),
        ),
      );
      // Verify that the Text widget exists but contains an empty string
      final Finder textFinder = find.byType(Text);
      expect(textFinder,
          findsOneWidget); // The Text widget itself should be present
      final Text textWidget = tester.widget(textFinder);
      expect(textWidget.data, ''); // Its content should be empty

      // Verify that its style is still applied
      expect(textWidget.style?.color, Colors.grey[600]);
    });

    // Test case 5: Handles a very long title string
    testWidgets('handles a very long title string',
        (WidgetTester tester) async {
      const String longTitle =
          'This is a very, very, very, very, very, very, very, very, very, '
          'very, very, very, very, very, very, very, very, very, very, very, '
          'very, very, very, very, very, very, very, very, very, very, very, '
          'long title that should ideally wrap or truncate without crashing the app.';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SettingsSectionHeader(title: longTitle),
          ),
        ),
      );

      // Verify that the text is still present (Flutter's Text widget handles wrapping by default)
      expect(find.text(longTitle), findsOneWidget);

      // You could add more advanced checks for overflow if your design explicitly handles it (e.g., using FittedBox)
      // For a simple Text widget within Padding, overflow is usually handled internally by Flutter (wrapping or ellipsis).
    });

    // Test case 6: Renders correctly in a Right-to-Left (RTL) text direction
    testWidgets('renders correctly in RTL text direction',
        (WidgetTester tester) async {
      const String testTitle = 'RTL Test Title';

      await tester.pumpWidget(
        const Directionality(
          // Use Directionality to set text direction
          textDirection: TextDirection.rtl,
          child: MaterialApp(
            home: Scaffold(
              body: SettingsSectionHeader(title: testTitle),
            ),
          ),
        ),
      );

      // Verify text is present
      expect(find.text(testTitle), findsOneWidget);

      // You might add checks for layout alignment if your widget changes based on direction.
      // For a simple centered or left-aligned Text within Padding, the visual change might be minimal for this test.
      // The main goal is to ensure it doesn't crash or behave unexpectedly.
    });

    // Test case 7: Verify specific styling when a custom Theme is provided (less critical for hardcoded styles)
    // This test is more useful if your Text style comes from Theme.of(context).textTheme
    // For current hardcoded style, this mostly verifies Text widget behavior within a Theme.
    testWidgets('respects surrounding Theme data (basic check)',
        (WidgetTester tester) async {
      const String testTitle = 'Themed Header';
      final Color customColor = Colors.blue.shade900;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: TextTheme(
              // This won't directly affect your hardcoded style, but demonstrates Theme context
              headlineSmall: TextStyle(color: customColor, fontSize: 20.0),
            ),
          ),
          home: const Scaffold(
            body: SettingsSectionHeader(title: testTitle),
          ),
        ),
      );

      final Finder textFinder = find.text(testTitle);
      expect(textFinder, findsOneWidget);
      final Text textWidget = tester.widget(textFinder);

      // Verify its hardcoded style is still applied, not the theme's headlineSmall
      expect(textWidget.style?.color,
          Colors.grey[600]); // Still expects hardcoded grey
      expect(textWidget.style?.fontSize, 14);
      expect(textWidget.style?.fontWeight, FontWeight.bold);

      // This test highlights that the current TextStyle is hardcoded.
      // If you wanted it to respect the theme, you'd change your widget to:
      // style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      // Then this test would check against the theme's color.
    });

    // Test case 8: Renders correctly when constrained by parent (e.g., small width)
    testWidgets('renders correctly with limited parent width',
        (WidgetTester tester) async {
      const String testTitle =
          'A moderately long title that should wrap within constraints.';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              // Constrain the width
              width: 150.0,
              child: SettingsSectionHeader(title: testTitle),
            ),
          ),
        ),
      );

      // Verify that the text is still found, meaning it rendered without fatal errors
      expect(find.text(testTitle), findsOneWidget);

      // For more advanced layout testing, you could inspect the RenderBox to check for overflow properties.
      // However, for simple Text wrapping, just finding the text confirms basic functionality.
    });
  });
}
