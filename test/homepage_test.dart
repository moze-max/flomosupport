import 'package:flomosupport/pages/guide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flomosupport/pages/homepage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'guidepage_test.dart';

// Mock or minimal implementations of dependent pages
class MockGuide extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey; // Made nullable for mocks
  const MockGuide({super.key, this.scaffoldKey});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Guide Page Content'));
  }
}

class MockArticle extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey; // Made nullable for mocks
  const MockArticle({super.key, this.scaffoldKey});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Article Page Content'));
  }
}

class MockShareImageWithTemplatePage extends StatelessWidget {
  const MockShareImageWithTemplatePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Share Image Page Content'));
  }
}

void main() {
  group('Homepage Widget Tests', () {
    final GlobalKey<ScaffoldState> testHomepageKey = GlobalKey<ScaffoldState>();

    // 修改 pumpHomepage，使其返回 AppLocalizations 实例
    Future<AppLocalizations> pumpHomepage(WidgetTester tester,
        {Locale locale = const Locale('zh')}) async {
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
          home: Homepage(
            homepagekey: testHomepageKey,
            pages: [
              MockGuide(scaffoldKey: GlobalKey<ScaffoldState>()),
              MockArticle(scaffoldKey: GlobalKey<ScaffoldState>()),
              const MockShareImageWithTemplatePage(),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final BuildContext context = tester.element(find.byType(Homepage));
      return AppLocalizations.of(context)!;
    }

    testWidgets(
        'Homepage displays BottomNavigationBar and initial tab (dynamic text)',
        (WidgetTester tester) async {
      final AppLocalizations l10n = await pumpHomepage(tester); // 获取本地化实例

      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // 使用 l10n 实例获取文本
      expect(find.text(l10n.bottomNavGuide), findsOneWidget);
      expect(find.text(l10n.articlePageTitle), findsOneWidget);
      expect(find.text('getImage'), findsOneWidget); // 这个没有本地化

      expect(find.text('Guide Page Content'), findsOneWidget);
      expect(find.text('Article Page Content'), findsNothing);
      expect(find.text('Share Image Page Content'), findsNothing);
    });

    testWidgets('Tapping on Article tab switches page (dynamic text)',
        (WidgetTester tester) async {
      final AppLocalizations l10n = await pumpHomepage(tester);

      // 使用 l10n 实例来点击
      await tester.tap(find.text(l10n.articlePageTitle));
      await tester.pumpAndSettle();

      expect(find.text('Article Page Content'), findsOneWidget);
      expect(find.text('Guide Page Content'), findsNothing);
      expect(find.text('Share Image Page Content'), findsNothing);

      final BottomNavigationBar bottomNav =
          tester.widget(find.byType(BottomNavigationBar));
      expect(bottomNav.currentIndex, 1);
    });

    testWidgets('Tapping on share tab switches page (dynamic text)',
        (WidgetTester tester) async {
      await pumpHomepage(tester);
      await tester.tap(find.text('getImage'));
      await tester.pumpAndSettle();

      expect(find.text('Article Page Content'), findsNothing);
      expect(find.text('Guide Page Content'), findsNothing);
      expect(find.text('Share Image Page Content'), findsOneWidget);
    });
  });
  group('Standalone Guide Page GUI Tests (Using real Guide)', () {
    testWidgets('测试真实情况下的基本guide页面是否工作正常', (tester) async {
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
          locale: const Locale('zh'), // 单独测试时指定 locale
          home: Guide(scaffoldKey: scaffoldKey), // **这里使用真实的 Guide 页面**
        ),
      );
      await tester.pumpAndSettle();
      final AppLocalizations l10n =
          AppLocalizations.of(tester.element(find.byType(Guide)))!;
      verifybaseGuidePageUI(tester, l10n, scaffoldKey);
    });
  });
}
