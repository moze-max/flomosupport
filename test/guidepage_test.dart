// test/guidepage_test.dart

import 'dart:io';
import 'package:flomosupport/components/guide_card.dart';
import 'package:flomosupport/pages/newguide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart'; // Import provider for ChangeNotifierProvider
import 'package:mocktail/mocktail.dart'; // Mocking library
import 'package:flomosupport/pages/guide.dart'; // The widget under test
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flomosupport/functions/class_items_notification.dart'; // ClassItemNotifier
import 'package:flomosupport/models/guidemodel.dart'; // Assuming TemplateModel is here or similar

// --- Mock Classes ---
class FakeRoute<T> extends Fake implements Route<T> {}

// Mock PathProviderPlatform - existing from your code
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return 'mock_app_documents_directory';
  }

  // Add more overrides as needed by your actual code that uses path_provider
  @override
  Future<String?> getTemporaryPath() => Future.value(null);
  @override
  Future<String?> getApplicationSupportPath() => Future.value(null);
  @override
  Future<String?> getLibraryPath() => Future.value(null);
  @override
  Future<String?> getExternalStoragePath() => Future.value(null);
  @override
  Future<List<String>?> getExternalCachePaths() => Future.value(null);
  @override
  Future<List<String>?> getExternalStoragePaths({StorageDirectory? type}) =>
      Future.value(null);
  @override
  Future<String?> getDownloadsPath() => Future.value(null);
  @override
  Future<String?> getApplicationCachePath() async {
    return 'mock_app_cache_directory';
  }
}

// Mock for ClassItemNotifier
class MockClassItemNotifier extends Mock implements ClassItemNotifier {}

// Mock for NavigatorObserver to capture navigation events
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// --- Helper Functions (for UI verification) ---

// You can keep your verifybaseGuidePageUI if you like, but I'll integrate checks directly into tests for clarity.

// --- Main Test Function ---

void main() {
  // Ensure the Flutter test environment is initialized
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockClassItemNotifier mockClassItemNotifier;
  late MockPathProviderPlatform mockPathProviderPlatform;
  late MockNavigatorObserver mockNavigatorObserver;
  late GlobalKey<ScaffoldState> scaffoldKey;
  late AppLocalizations l10n;

  // Set up mocktail fallbacks for complex types if they are passed as 'any()'
  setUpAll(() {
    registerFallbackValue(File('dummy_path.txt'));
    registerFallbackValue(Directory('dummy_path'));
    // If your TemplateModel is not simple, you might need to register its fallback too
    // registerFallbackValue(TemplateModel(id: 'any', title: 'any', content: 'any', classItem: 'any'));
    registerFallbackValue(FakeRoute<dynamic>());
  });

  // Setup mocks before each test
  setUp(() {
    mockClassItemNotifier = MockClassItemNotifier();
    mockPathProviderPlatform = MockPathProviderPlatform();
    mockNavigatorObserver = MockNavigatorObserver();
    scaffoldKey = GlobalKey<ScaffoldState>();

    // Register the mock PathProviderPlatform instance
    PathProviderPlatform.instance = mockPathProviderPlatform;

    // --- Mock ClassItemNotifier initial behaviors ---
    when(() => mockClassItemNotifier.uniqueClassItems)
        .thenReturn([]); // Initially no categories
    when(() => mockClassItemNotifier.allTemplates)
        .thenReturn([]); // Initially no templates
    when(() => mockClassItemNotifier.filteredTemplates)
        .thenReturn([]); // Initially no filtered templates
    when(() => mockClassItemNotifier.selectedClassItem)
        .thenReturn(null); // Initially 'All' selected

    // Mock void methods
    when(() => mockClassItemNotifier.setSelectedClassItem(any()))
        .thenAnswer((_) {});
    when(() => mockClassItemNotifier.refreshAllData()).thenAnswer((_) {
      return Future<void>.value();
    });

    // Mock NavigatorObserver to capture push/pop events
    when(() => mockNavigatorObserver.didPush(any(), any())).thenAnswer((_) {});
    when(() => mockNavigatorObserver.didPop(any(), any())).thenAnswer((_) {});
  });

  // Helper function to pump the Guide page with necessary providers and mocks
  // Helper function to pump the Guide page with necessary providers and mocks
  Future<void> pumpGuidePage(WidgetTester tester,
      {Locale locale = const Locale('zh')}) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<ClassItemNotifier>.value(
        // <--- MOVED PROVIDER HERE
        value: mockClassItemNotifier, // Provide the mock ClassItemNotifier
        child: MaterialApp(
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
            // Outer Scaffold for the Drawer
            key:
                scaffoldKey, // Attach scaffoldKey to the outer Scaffold for drawer access
            body: Guide(
                scaffoldKey:
                    scaffoldKey), // Pass the scaffoldKey to Guide widget
          ),
          // Add navigatorObserver to catch navigation events
          navigatorObservers: [mockNavigatorObserver],
        ),
      ),
    );
    await tester
        .pumpAndSettle(); // Wait for all animations and rebuilds to complete

    // Get AppLocalizations instance after pumping
    l10n = AppLocalizations.of(tester.element(find.byType(Guide)))!;
  }

  // --- Test Group for Guide Page UI and Interactions ---

  group('Guide Page Tests', () {
    testWidgets('AppBar displays correct title and menu icon', (tester) async {
      await pumpGuidePage(tester);

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(l10n.guidePageTitle), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new),
          findsNothing); // Confirm no back button
    });

    testWidgets('Add button displays correctly and navigates to Newguide',
        (tester) async {
      await pumpGuidePage(tester);

      final addIconFinder = find.byIcon(Icons.add);
      expect(addIconFinder, findsOneWidget);

      // Verify initial navigation state (no push occurred yet)
      verifyNever(() => mockNavigatorObserver.didPush(any(), any()));

      // Tap the add button
      await tester.tap(addIconFinder);
      await tester.pumpAndSettle(); // Pump to allow navigation

      // Verify Newguide page is pushed
      verify(() => mockNavigatorObserver.didPush(
          any(that: isA<MaterialPageRoute<dynamic>>()), any())).called(1);
      expect(find.byType(Newguide), findsOneWidget);
    });

    testWidgets('Empty state message and icon are displayed when no templates',
        (tester) async {
      // Mock ClassItemNotifier to return empty lists for this test
      when(() => mockClassItemNotifier.uniqueClassItems).thenReturn([]);
      when(() => mockClassItemNotifier.allTemplates).thenReturn([]);
      when(() => mockClassItemNotifier.filteredTemplates).thenReturn([]);

      await pumpGuidePage(tester);

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.text('暂无模板，点击右上角加号创建'), findsOneWidget);
      expect(
          find.byType(GridView), findsNothing); // GridView should not be shown
    });

    testWidgets(
        'Empty state message changes when a specific category is selected and empty',
        (tester) async {
      // Mock ClassItemNotifier with some unique categories, but no templates
      when(() => mockClassItemNotifier.uniqueClassItems)
          .thenReturn(['Category A', 'Category B']);
      when(() => mockClassItemNotifier.allTemplates).thenReturn([]);
      when(() => mockClassItemNotifier.filteredTemplates)
          .thenReturn([]); // Still empty after filter

      await pumpGuidePage(tester);

      // Verify '全部' chip is selected and '暂无模板' text is shown initially
      expect(find.text('全部'), findsOneWidget);
      expect(tester.widget<ChoiceChip>(find.text('全部')).selected, isTrue);
      expect(find.text('暂无模板，点击右上角加号创建'), findsOneWidget);
      expect(find.text('当前分类下暂无模板'), findsNothing); // Should not be present yet

      // Simulate selecting a category chip
      when(() => mockClassItemNotifier.selectedClassItem)
          .thenReturn('Category A'); // Mock notifier state change
      await tester.tap(find.text('Category A'));
      await tester.pumpAndSettle(); // Pump for UI update

      // Verify 'Category A' chip is selected and the empty state text changes
      expect(
          tester.widget<ChoiceChip>(find.text('Category A')).selected, isTrue);
      expect(find.text('暂无模板，点击右上角加号创建'), findsNothing); // Should be gone
      expect(find.text('当前分类下暂无模板'), findsOneWidget); // New empty message
    });

    testWidgets(
        'ListView of ChoiceChips and GridView displayed when templates exist',
        (tester) async {
      final mockTemplate1 = Template(
          id: '1',
          name: 'Mock Template 1',
          items: ['content'],
          classitems: ['Category A']);
      final mockTemplate2 = Template(
          id: '2',
          name: 'Mock Template 2',
          items: ['content'],
          classitems: ['Category B']);

      // Mock ClassItemNotifier to return data
      when(() => mockClassItemNotifier.uniqueClassItems)
          .thenReturn(['Category A', 'Category B']);
      when(() => mockClassItemNotifier.allTemplates)
          .thenReturn([mockTemplate1, mockTemplate2]);
      when(() => mockClassItemNotifier.filteredTemplates)
          .thenReturn([mockTemplate1, mockTemplate2]);
      when(() => mockClassItemNotifier.selectedClassItem)
          .thenReturn(null); // 'All' selected

      await pumpGuidePage(tester);

      // Verify ListView of ChoiceChips is present and has expected items
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ChoiceChip),
          findsNWidgets(3)); // '全部', 'Category A', 'Category B'
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('Category A'), findsOneWidget);
      expect(find.text('Category B'), findsOneWidget);

      // Verify GridView is displayed and contains template cards
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(TemplateCard), findsNWidgets(2));
      expect(find.text('Mock Template 1'), findsOneWidget);
      expect(find.text('Mock Template 2'), findsOneWidget);

      // Verify empty state messages are NOT displayed
      expect(find.text('暂无模板，点击右上角加号创建'), findsNothing);
      expect(find.text('当前分类下暂无模板'), findsNothing);
      expect(find.byIcon(Icons.folder_open),
          findsNothing); // Empty folder icon should not be there
    });

    testWidgets('Selecting a category filters templates in GridView',
        (tester) async {
      final mockTemplate1 = Template(
          id: '1',
          name: 'Mock Template 1',
          items: ['content'],
          classitems: ['Category A']);
      final mockTemplate2 = Template(
          id: '2',
          name: 'Mock Template 2',
          items: ['content'],
          classitems: ['Category B']);

      when(() => mockClassItemNotifier.uniqueClassItems)
          .thenReturn(['Category A', 'Category B']);
      when(() => mockClassItemNotifier.allTemplates)
          .thenReturn([mockTemplate1, mockTemplate2]);
      when(() => mockClassItemNotifier.selectedClassItem)
          .thenReturn(null); // Start with 'All' selected

      await pumpGuidePage(tester);

      // Verify initial state: both templates shown
      expect(find.text('Mock Template 1'), findsOneWidget);
      expect(find.text('Mock Template 2'), findsOneWidget);

      // Simulate selecting 'Category A'
      when(() => mockClassItemNotifier.selectedClassItem)
          .thenReturn('Category A'); // Mock notifier state
      when(() => mockClassItemNotifier.filteredTemplates)
          .thenReturn([mockTemplate1]); // Mock filtered result

      await tester.tap(find.text('Category A'));
      await tester.pumpAndSettle(); // Pump for UI update

      // Verify only 'Mock Template 1' is shown
      expect(find.text('Mock Template 1'), findsOneWidget);
      expect(find.text('Mock Template 2'),
          findsNothing); // Mock Template 2 should be filtered out
      verify(() => mockClassItemNotifier.setSelectedClassItem('Category A'))
          .called(1); // Verify method call
    });

    testWidgets(
        'refreshAllData is called when returning from Newguide page with result',
        (tester) async {
      await pumpGuidePage(tester);

      // Simulate pushing Newguide page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // Start navigation to Newguide

      // Verify that Newguide page is now on top of the stack
      expect(find.byType(Newguide), findsOneWidget);

      // Get the NavigatorState from the current context
      final NavigatorState navigator = tester.state(find.byType(Navigator));

      // Simulate popping the Newguide page with a 'true' result
      // This will complete the Future returned by Navigator.push in the widget code.
      navigator.pop(true);
      await tester.pumpAndSettle(); // Complete the pop animation and rebuild

      // Verify refreshAllData was called
      verify(mockClassItemNotifier.refreshAllData() as Function()).called(1);
    });

    testWidgets(
        'refreshAllData is NOT called when returning from Newguide page with no result',
        (tester) async {
      await pumpGuidePage(tester);

      // Simulate pushing Newguide page
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); // Start navigation to Newguide

      // Verify that Newguide page is now on top of the stack
      expect(find.byType(Newguide), findsOneWidget);

      // Get the NavigatorState from the current context
      final NavigatorState navigator = tester.state(find.byType(Navigator));

      // Simulate popping the Newguide page with a 'null' result
      navigator.pop(null); // Or just navigator.pop()
      await tester.pumpAndSettle(); // Complete the pop animation and rebuild

      // Verify refreshAllData was NOT called
      verifyNever(mockClassItemNotifier.refreshAllData() as Function());
    });
  });
}
