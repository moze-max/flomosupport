import 'package:flomosupport/pages/user_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/l10n/app_localizations.dart';

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
      dynamicDrawerWidth = screenWidth * 0.75;
    } else {
      dynamicDrawerWidth = screenWidth * 0.5;
    }

    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      key: widget.homepagekey,
      drawerEnableOpenDragGesture: true,
      drawerScrimColor: Colors.black54,
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
            )
          ],
          onTap: onTabChanged,
        ),
      ),
    );
  }
}
