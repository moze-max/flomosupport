import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The showSnackbar function (modified to include context.mounted check)
void showSnackbar(BuildContext context, String message,
    {bool isError = false, bool isFloating = true, bool isClosedAble = false}) {
  // IMPORTANT: Add this check to prevent errors if the context is no longer mounted.
  if (!context.mounted) {
    return;
  }

  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final ThemeData theme = Theme.of(context);
  final Color backgroundColor = isError
      ? theme.colorScheme.errorContainer // Error message background color
      : theme.colorScheme.primaryContainer; // Normal message background color

  final Color foregroundColor = isError
      ? theme.colorScheme.onErrorContainer // Error message text color
      : theme.colorScheme.onPrimaryContainer; // Normal message text color

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: foregroundColor),
      ),
      backgroundColor: backgroundColor,
      behavior: isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.all(16.0), // Margin for floating SnackBar
      duration: const Duration(milliseconds: 1000),
      action: isClosedAble
          ? SnackBarAction(
              label: '关闭', // Close button
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              textColor: foregroundColor,
            )
          : null,
    ),
  );
}

void main() {
  group('showSnackbar', () {
    testWidgets(
        'shows SnackBar with correct message and default background color',
        (WidgetTester tester) async {
      const String testMessage = 'This is a test message.';

      // Build a widget tree that includes a Scaffold, as SnackBar needs a ScaffoldMessenger.
      // Builder is used to get a BuildContext that is within the MaterialApp.
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showSnackbar(context, testMessage);
                    },
                    child: const Text('Show Snackbar'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Verify that no SnackBar is initially present
      expect(find.byType(SnackBar), findsNothing);

      // Tap the button to trigger showSnackbar
      await tester.tap(find.text('Show Snackbar'));
      // Pump the frame to allow the SnackBar to be built
      await tester.pump();
      // Pump again to allow the SnackBar animation to start and settle for `find.byType(SnackBar)`
      await tester.pumpAndSettle();

      // Verify that the SnackBar is now present
      expect(find.byType(SnackBar), findsOneWidget);
      // Verify the message content
      expect(find.text(testMessage), findsOneWidget);

      // Get the theme from the widget tree to compare colors accurately
      final ThemeData theme =
          Theme.of(tester.element(find.byType(MaterialApp)));
      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      // Correct assertion: expect the background color to be the primaryContainer color from the theme
      expect(snackBar.backgroundColor, theme.colorScheme.primaryContainer);

      // Dismiss the SnackBar to clean up for potential subsequent tests (optional but good practice)
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
    });

    testWidgets('shows SnackBar with error background color for error messages',
        (WidgetTester tester) async {
      const String errorMessage = 'An error occurred!';

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showSnackbar(context, errorMessage, isError: true);
                    },
                    child: const Text('Show Error Snackbar'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Error Snackbar'));
      await tester.pumpAndSettle();

      // Verify the SnackBar is present
      expect(find.byType(SnackBar), findsOneWidget);
      // Verify the message content
      expect(find.text(errorMessage), findsOneWidget);

      // Get the theme from the widget tree to compare colors accurately
      final ThemeData theme =
          Theme.of(tester.element(find.byType(MaterialApp)));
      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      // Correct assertion: expect the background color to be the errorContainer color from the theme
      expect(snackBar.backgroundColor, theme.colorScheme.errorContainer);

      ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'does not show SnackBar if context is not mounted when showSnackbar is called',
        (WidgetTester tester) async {
      const String message = 'This message should not be shown.';
      late BuildContext
          unmountedContext; // To store the context of the widget that will be unmounted

      // 1. Pump a widget that will give us a context
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Store this context. Later, this context will become unmounted.
                unmountedContext = context;
                return const Text('Test Setup');
              },
            ),
          ),
        ),
      );

      expect(find.byType(SnackBar), findsNothing);

      // 2. Unmount the previous widget tree by pumping an empty widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester
          .pumpAndSettle(); // Ensure the previous tree is fully dismantled

      // 3. Call showSnackbar with the now unmounted context.
      // Since showSnackbar now has `if (!context.mounted) return;`, it should not throw an error
      // and should simply not show the snackbar.
      showSnackbar(unmountedContext, message);

      // Pump to allow any potential SnackBar building to happen (which it shouldn't)
      await tester.pump();
      await tester.pumpAndSettle(); // Ensure no SnackBar appears

      // Verify that no SnackBar is present
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
