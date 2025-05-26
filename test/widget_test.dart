import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import your Homepage file
// Replace 'your_app_name/homepage.dart' with the actual path to your file
import 'package:flomosupport/pages/Homepage.dart';

// --- Mock/Dummy Widgets for Testing ---
// 我们创建简单的虚拟 Widget 来代表 Guide 和 Article，
// 以便测试可以运行，而无需依赖实际复杂 Widget 的内部逻辑。
class Guide extends StatelessWidget {
  // 为测试添加一个 Key，方便查找
  const Guide({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Guide Page Content', key: Key('guidePageContent')));
  }
}

class Article extends StatelessWidget {
  // 为测试添加一个 Key，方便查找
  const Article({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Article Page Content', key: Key('articlePageContent')));
  }
}
// -------------------------------------

void main() {
  testWidgets(
      'Homepage displays BottomNavigationBar and switches pages correctly',
      (WidgetTester tester) async {
    // 构建我们的 Homepage Widget，并将其包装在 MaterialApp 中以提供必要的 context。
    await tester.pumpWidget(
      const MaterialApp(
        home: Homepage(),
      ),
    );

    // --- 测试 1: 验证初始状态 ---
    // 查找 BottomNavigationBar
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // 验证有两个 BottomNavigationBarItems
    expect(find.byType(BottomNavigationBarItem), findsNWidgets(2));

    // 验证第一个 Tab (Writing Guide) 及其 Key
    // 注意：你的原始代码中 'writing_guide_tab' 有拼写错误 'wirting_guide_tab'
    // 这里我们使用修正后的 Key，如果你在 Homepage 代码中保持了原始拼写，请在这里改回
    final writingGuideTabFinder = find.byKey(const Key('writing_guide_tab'));
    expect(writingGuideTabFinder, findsOneWidget,
        reason: 'Should find the writing guide tab by key');

    // 验证第二个 Tab (Article) 及其 Key
    final articleTabFinder = find.byKey(const Key("article_tab"));
    expect(articleTabFinder, findsOneWidget,
        reason: 'Should find the article tab by key');

    // 验证初始显示的页面是 Guide (通过查找 Guide 模拟 Widget 中的特定内容 Key)
    expect(find.byKey(const Key('guidePageContent')), findsOneWidget,
        reason: 'Initially, the Guide page should be displayed');
    expect(find.byKey(const Key('articlePageContent')), findsNothing,
        reason: 'Initially, the Article page should not be displayed');

    // 验证 BottomNavigationBar 的选中索引是 0
    final bottomNavBar =
        tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavBar.currentIndex, 0,
        reason: 'Initial selected index should be 0');

    // --- 测试 2: 点击第二个 Tab (Article) 并验证状态变化 ---

    // 模拟点击第二个 Tab (Article)
    await tester.tap(articleTabFinder);

    // 重建 Widget 树以反映状态变化
    await tester.pump();

    // 验证显示的页面切换到了 Article
    expect(find.byKey(const Key('guidePageContent')), findsNothing,
        reason:
            'After tapping Article tab, Guide page should not be displayed');
    expect(find.byKey(const Key('articlePageContent')), findsOneWidget,
        reason: 'After tapping Article tab, Article page should be displayed');

    // 验证 BottomNavigationBar 的选中索引更新为 1
    final bottomNavBarAfterTapArticle =
        tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavBarAfterTapArticle.currentIndex, 1,
        reason: 'After tapping Article tab, selected index should be 1');

    // --- 测试 3: 点击第一个 Tab (Writing Guide) 并验证状态变化 ---

    // 模拟点击第一个 Tab (Writing Guide)
    await tester.tap(writingGuideTabFinder);

    // 重建 Widget 树
    await tester.pump();

    // 验证显示的页面切换回了 Guide
    expect(find.byKey(const Key('guidePageContent')), findsOneWidget,
        reason:
            'After tapping Writing Guide tab again, Guide page should be displayed');
    expect(find.byKey(const Key('articlePageContent')), findsNothing,
        reason:
            'After tapping Writing Guide tab again, Article page should not be displayed');

    // 验证 BottomNavigationBar 的选中索引更新为 0
    final bottomNavBarAfterTapGuide =
        tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
    expect(bottomNavBarAfterTapGuide.currentIndex, 0,
        reason:
            'After tapping Writing Guide tab again, selected index should be 0');
  });
}
