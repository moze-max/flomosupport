import 'package:flomosupport/pages/user_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
// import 'package:flomosupport/pages/getimageshare.dart';
// import 'article.dart';
// import 'guide.dart';

class Homepage extends StatefulWidget {
  final List<Widget> pages;
  final GlobalKey<ScaffoldState> homepagekey;
  const Homepage({
    super.key,
    required this.pages,
    required this.homepagekey,
  });
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Homepage> {
  int currentindex = 0;
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _pages;
  @override
  void initState() {
    super.initState();
    _pages = widget.pages;
  }

  void onTabChanged(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double dynamicDrawerWidth;
    final screenWidth = MediaQuery.of(context).size.width;

    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      // 例如，手机上抽屉宽度可以是屏幕宽度的 75%
      dynamicDrawerWidth = screenWidth * 0.75;
    } else {
      // 在桌面或平板上，可能仍然保持屏幕一半，或者更大的固定值
      dynamicDrawerWidth = screenWidth * 0.5;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      key: widget.homepagekey,
      drawerEnableOpenDragGesture: true,
      // 设置抽屉打开时主页面的蒙版颜色和透明度
      drawerScrimColor: Colors.black54, // 黑色半透明蒙版
      drawer: Drawer(
        width: dynamicDrawerWidth,
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
              label: appLocalizations.bottomNavGuide,
              tooltip: appLocalizations.bottomNavGuide,
            ),
            BottomNavigationBarItem(
              key: Key("article_tab"),
              icon: Icon(Icons.article_outlined),
              label: appLocalizations.articlePageTitle,
              tooltip: appLocalizations.articlePageTitle,
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.abc), label: 'getImage', tooltip: 'getImage')
          ],
          onTap: onTabChanged,
        ),
      ),
    );
  }
}
