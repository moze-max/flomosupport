import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flomosupport/pages/guide.dart';
import 'package:flomosupport/models/guidemodel.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flomosupport/l10n/app_localizations_en.dart';
import 'package:mocktail/mocktail.dart';

// Mock PathProviderPlatform
class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return 'mock_app_documents_directory';
  }

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
    return 'mock_app_cache_directory'; // Or Future.value(null) if not needed for your tests
  }
}

class MockFile extends Mock implements File {}

class MockDirectory extends Mock implements Directory {}

void verifybaseGuidePageUI(WidgetTester tester, AppLocalizations l10n,
    GlobalKey<ScaffoldState> guideScaffoldKey) {
  expect(find.byType(AppBar), findsOneWidget);
  expect(find.text(l10n.guidePageTitle), findsOneWidget);

  expect(find.byIcon(Icons.menu), findsOneWidget);
  expect(find.byIcon(Icons.arrow_back_ios_new), findsNothing);

  final addIconFinder = find.byIcon(Icons.add);
  expect(addIconFinder, findsOneWidget);

  expect(find.byIcon(Icons.folder_open), findsOneWidget);
  expect(find.text('暂无模板，点击右上角加号创建'), findsOneWidget);

  expect(find.byType(GridView), findsNothing);
}

void base_UI_test() {
  group('Guide Page Base UI Tests', () {
    late AppLocalizations l10n;
    late GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    Future<void> pumpGuidePage(WidgetTester tester,
        {Locale locale = const Locale('zh')}) async {
      scaffoldKey = GlobalKey<ScaffoldState>();
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
          home: Guide(scaffoldKey: scaffoldKey),
        ),
      );

      await tester.pumpAndSettle(); // 等待所有构建完成

      l10n = AppLocalizations.of(tester.element(find.byType(Guide)))!;
    }

    testWidgets('AppBar 显示正确标题', (tester) async {
      await pumpGuidePage(tester);

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(l10n.guidePageTitle), findsOneWidget);
    });

    testWidgets('AppBar 显示返回按钮或菜单按钮', (tester) async {
      await pumpGuidePage(tester);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('添加按钮显示且图标颜色正确', (tester) async {
      await pumpGuidePage(tester);

      final addIconFinder = find.byIcon(Icons.add);
      expect(addIconFinder, findsOneWidget);

      final iconData = tester.widget<Icon>(addIconFinder).icon;
      expect(iconData, Icons.add);
    });

    testWidgets('空状态提示显示正确图标和文本', (tester) async {
      await pumpGuidePage(tester);

      expect(find.byIcon(Icons.folder_open), findsOneWidget);
      expect(find.text('暂无模板，点击右上角加号创建'), findsOneWidget);
    });

    testWidgets('不显示 GridView 内容', (tester) async {
      await pumpGuidePage(tester);

      expect(find.byType(GridView), findsNothing);
    });
  });
}

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Required for services like path_provider

  late MockPathProviderPlatform mockPathProvider;
  late GlobalKey<ScaffoldState> scaffoldKey;
  late AppLocalizations appLocalizations;

  setUpAll(() {
    // Register fallbacks for common types if you're using mocktail extensively
    registerFallbackValue(File(''));
    registerFallbackValue(Directory(''));
  });

  setUp(() {
    scaffoldKey = GlobalKey<ScaffoldState>();
  });

  group('Guide Page Base UI Tests', () {
    base_UI_test();
  });
}
