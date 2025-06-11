import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assuming your shareTemplate class is in 'lib/models/share_template.dart'
// Adjust this import path to match your project structure
import 'package:flomosupport/models/share_model.dart';

// A dummy builder function for testing the builder property
// This function mimics how a builder might create a simple UI.
Widget _dummyBuilder(BuildContext context, String title, String content) {
  return Column(
    children: [
      Text('Title: $title'),
      Text('Content: $content'),
    ],
  );
}

// Another dummy builder for testing different builder behaviors
Widget _anotherDummyBuilder(
    BuildContext context, String title, String content) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('$title - $content'),
    ),
  );
}

void main() {
  group('shareTemplate', () {
    // --- Constructor Initialization Tests ---
    test('shareTemplate constructor initializes all properties correctly', () {
      final shareTemplateInstance = shareTemplate(
        id: 'share-id-123',
        name: 'My Shareable Template',
        builder: _dummyBuilder,
      );

      expect(shareTemplateInstance.id, 'share-id-123');
      expect(shareTemplateInstance.name, 'My Shareable Template');
      expect(shareTemplateInstance.builder,
          isA<Widget Function(BuildContext, String, String)>());
      expect(shareTemplateInstance.builder,
          _dummyBuilder); // Check if the exact function reference is stored
    });

    // Test that required fields cannot be null
    test('shareTemplate constructor throws error if id is null', () {
      expect(
        () => shareTemplate(
            id: null as String, name: 'Test', builder: _dummyBuilder),
        throwsA(isA<TypeError>()),
      );
    });

    test('shareTemplate constructor throws error if name is null', () {
      expect(
        () => shareTemplate(
            id: 'some_id', name: null as String, builder: _dummyBuilder),
        throwsA(isA<TypeError>()),
      );
    });

    test('shareTemplate constructor throws error if builder is null', () {
      expect(
        () => shareTemplate(
            id: 'some_id',
            name: 'Test',
            builder: null as Widget Function(BuildContext, String, String)),
        throwsA(isA<TypeError>()),
      );
    });

    // --- Builder Functionality Tests (using testWidgets) ---

    testWidgets('shareTemplate builder creates a Widget with correct content',
        (WidgetTester tester) async {
      const String testTitle = 'Share Title';
      const String testContent = 'This is the shared content.';

      final shareTemplateInstance = shareTemplate(
        id: 'builder-test-id',
        name: 'Builder Test Template',
        builder: _dummyBuilder, // Using the dummy builder
      );

      // Pump the widget created by the builder into the test environment.
      // We wrap it in MaterialApp and Builder to provide a necessary BuildContext.
      await tester.pumpWidget(
        MaterialApp(
          // MaterialApp is often needed for descendant widgets like Text to find Directionality
          home: Builder(
            builder: (BuildContext context) {
              return shareTemplateInstance.builder(
                  context, testTitle, testContent);
            },
          ),
        ),
      );

      // Verify that the title and content text are found
      expect(find.text('Title: $testTitle'), findsOneWidget);
      expect(find.text('Content: $testContent'), findsOneWidget);

      // Verify the widget structure if the builder is predictable
      expect(find.byType(Column),
          findsOneWidget); // Expect a Column widget from _dummyBuilder
      expect(find.byType(Text),
          findsNWidgets(2)); // Expect two Text widgets inside
    });
  });
}
