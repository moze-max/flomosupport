// ignore_for_file: cast_from_null_always_fails

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Assuming your ShareTemplate class is in 'lib/models/share_template.dart'
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

void main() {
  group('ShareTemplate', () {
    // --- Constructor Initialization Tests ---
    test('ShareTemplate constructor initializes all properties correctly', () {
      final ShareTemplateInstance = ShareTemplate(
        id: 'share-id-123',
        name: 'My Shareable Template',
        builder: _dummyBuilder,
      );

      expect(ShareTemplateInstance.id, 'share-id-123');
      expect(ShareTemplateInstance.name, 'My Shareable Template');
      expect(ShareTemplateInstance.builder,
          isA<Widget Function(BuildContext, String, String)>());
      expect(ShareTemplateInstance.builder,
          _dummyBuilder); // Check if the exact function reference is stored
    });

    // Test that required fields cannot be null
    test('ShareTemplate constructor throws error if id is null', () {
      expect(
        () => ShareTemplate(
            id: null as String, name: 'Test', builder: _dummyBuilder),
        throwsA(isA<TypeError>()),
      );
    });

    test('ShareTemplate constructor throws error if name is null', () {
      expect(
        () => ShareTemplate(
            id: 'some_id', name: null as String, builder: _dummyBuilder),
        throwsA(isA<TypeError>()),
      );
    });

    test('ShareTemplate constructor throws error if builder is null', () {
      expect(
        () => ShareTemplate(
            id: 'some_id',
            name: 'Test',
            builder: null as Widget Function(BuildContext, String, String)),
        throwsA(isA<TypeError>()),
      );
    });

    // --- Builder Functionality Tests (using testWidgets) ---

    testWidgets('ShareTemplate builder creates a Widget with correct content',
        (WidgetTester tester) async {
      const String testTitle = 'Share Title';
      const String testContent = 'This is the shared content.';

      final ShareTemplateInstance = ShareTemplate(
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
              return ShareTemplateInstance.builder(
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
