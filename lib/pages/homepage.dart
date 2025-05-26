import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'article.dart';
import 'guide.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Homepage> {
  int currentindex = 0;
  final List<Widget> _pages = [
    Guide(),
    Article(),
  ];

  void onTabChanged(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
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
