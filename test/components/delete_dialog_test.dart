import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assuming your Template class is defined in guidemodel.dart
import 'package:flomosupport/models/guidemodel.dart';

// Import the dialog function you want to test
import 'package:flomosupport/components/dialog_components.dart'; // Adjust this import path if needed

void main() {
  group('showDeleteConfirmationDialog', () {
    // A mock Template instance for testing
    final testTemplate = Template(
      id: 'test-template-id',
      name: 'Test Template Name',
      items: [],
      imagePath: null,
    );

    testWidgets('dialog shows with correct title and content',
        (WidgetTester tester) async {
      // Build a widget that will call our dialog function.
      // We need a MaterialApp and a Scaffold for the dialog to display correctly.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDeleteConfirmationDialog(
                        context: context,
                        template: testTemplate,
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Tap the button to show the dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle(); // Wait for the dialog to appear

      // Verify that the AlertDialog is present
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify the title text
      expect(find.text('确认删除'), findsOneWidget);

      // Verify the content text, including the template name
      expect(
          find.text('确定要删除"${testTemplate.name}"吗？此操作不可撤销。'), findsOneWidget);

      // Verify the presence of action buttons
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
    });

    testWidgets('tapping "取消" button returns false and dismisses dialog',
        (WidgetTester tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      dialogResult = await showDeleteConfirmationDialog(
                        context: context,
                        template: testTemplate,
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle(); // Dialog appears

      // Tap the "取消" button
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle(); // Dialog dismisses

      // Verify the dialog is no longer on screen
      expect(find.byType(AlertDialog), findsNothing);
      // Verify the returned result is false
      expect(dialogResult, isFalse);
    });

    testWidgets('tapping "删除" button returns true and dismisses dialog',
        (WidgetTester tester) async {
      bool? dialogResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      dialogResult = await showDeleteConfirmationDialog(
                        context: context,
                        template: testTemplate,
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle(); // Dialog appears

      // Tap the "删除" button
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle(); // Dialog dismisses

      // Verify the dialog is no longer on screen
      expect(find.byType(AlertDialog), findsNothing);
      // Verify the returned result is true
      expect(dialogResult, isTrue);
    });

    testWidgets('delete button text has red color style',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDeleteConfirmationDialog(
                        context: context,
                        template: testTemplate,
                      );
                    },
                    child: const Text('Show Dialog'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle(); // Dialog appears

      // Find the "删除" Text widget
      final deleteTextFinder = find.text('删除');
      expect(deleteTextFinder, findsOneWidget);

      // Get the Text widget and check its style
      final Text deleteTextWidget = tester.widget(deleteTextFinder);
      expect(deleteTextWidget.style?.color, Colors.red);
    });
  });
}
