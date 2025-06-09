import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the function you want to test
import 'package:flomosupport/components/show_snackbar.dart'; // Adjust this import path if needed

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

      // Verify default background color (should be null, meaning it takes theme default)
      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, isNull);

      // Dismiss the SnackBar to clean up for potential subsequent tests (optional but good practice)
      ScaffoldMessenger.of(tester.element(find.byType(Scaffold)))
          .hideCurrentSnackBar();
      await tester.pumpAndSettle();
    });

    testWidgets('shows SnackBar with red background color for error messages',
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

      // Verify the background color is red.shade700
      final SnackBar snackBar = tester.widget(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red.shade700);

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

      await tester.pumpWidget(const SizedBox.shrink());
      await tester
          .pumpAndSettle(); // Ensure the previous tree is fully dismantled

      showSnackbar(unmountedContext, message);

      // Pump to allow any potential SnackBar building to happen
      await tester.pump();
      await tester.pumpAndSettle(); // Ensure no SnackBar appears

      // Verify that no SnackBar is present
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}

// A helper StatefulWidget to simulate context mounting/unmounting scenarios
class _TestUnmountedContextWidget extends StatefulWidget {
  final String message;
  final bool shouldMountContext;

  const _TestUnmountedContextWidget({
    required this.message,
    required this.shouldMountContext,
  });

  @override
  State<_TestUnmountedContextWidget> createState() =>
      _TestUnmountedContextWidgetState();
}

class _TestUnmountedContextWidgetState
    extends State<_TestUnmountedContextWidget> {
  @override
  void initState() {
    super.initState();
    // This part is for demonstrating the context.mounted concept.
    // In actual test, the rebuild handles the unmounting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.shouldMountContext) {
        // If shouldMountContext is false, we are simulating a context that was
        // previously mounted but is now in the process of being unmounted or is stale.
        // We can't directly "unmount" a context for a direct call to `showSnackbar`
        // without rebuilding the tree.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shouldMountContext) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // This button is just to trigger the showSnackbar for initial testing.
              // The main unmounted context test is in the main testWidgets block.
              showSnackbar(context, widget.message);
            },
            child: const Text('Simulate Mounted Context'),
          ),
        ),
      );
    } else {
      // Return an empty container to simulate the previous context being unmounted.
      return Container();
    }
  }
}
