import 'package:flomosupport/pages/user_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'article.dart';
import 'guide.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Homepage> {
  int currentindex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      Guide(scaffoldKey: _scaffoldKey), // Pass the key
      Article(scaffoldKey: _scaffoldKey), // Pass the key
    ];
  }

  void onTabChanged(int index) {
    setState(() {
      currentindex = index;
    });
  }

  double get _drawerWidth => MediaQuery.of(context).size.width / 2;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: true,
      // 设置抽屉打开时主页面的蒙版颜色和透明度
      drawerScrimColor: Colors.black54, // 黑色半透明蒙版
      drawer: Drawer(
        width: _drawerWidth, // 宽度设置为屏幕的一半
        backgroundColor:
            const Color.fromARGB(255, 185, 211, 228).withAlpha(255),
        child: const UserAccountPage(),
      ),
      body: IndexedStack(index: currentindex, children: _pages),
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          currentIndex: currentindex,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              key: Key('writing_guide_tab'),
              icon: Icon(Icons.auto_awesome_motion),
              // label: 'writing guide',
              label: appLocalizations.bottomNavGuide,
              tooltip: '',
            ),
            BottomNavigationBarItem(
              key: Key("article_tab"),
              icon: Icon(Icons.article_outlined),
              label: appLocalizations.articlePageTitle,
              tooltip: '',
            ),
          ],
          onTap: onTabChanged,
        ),
      ),
    );
  }
}
