import 'package:flutter/material.dart';
import 'article.dart';
import 'guide.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<Homepage> {
  int currentindex = 0;
  final List<Widget> _pages = [Guide(), Article()];

  void onTabChanged(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Flomo Support')),
      body: IndexedStack(index: currentindex, children: _pages),
      bottomNavigationBar: Theme(
        data: ThemeData(splashColor: Colors.transparent),
        child: BottomNavigationBar(
          currentIndex: currentindex,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_motion),
              label: 'wirting guide',
              tooltip: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: 'Article',
              tooltip: '',
            ),
          ],
          onTap: onTabChanged,
        ),
      ),
    );
  }
}
