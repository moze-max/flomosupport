import 'package:flomosupport/components/getAvataImage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class UserAccountPage extends StatefulWidget {
  const UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override
  Widget build(BuildContext context) {
    EdgeInsets.zero;
    return ListTileTheme(
      // tileColor: const Color.fromARGB(255, 108, 187, 240).withAlpha(255),
      selectedTileColor: Colors.blueAccent.withAlpha(128),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(padding: EdgeInsets.zero),
          const DrawerHeader(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 75, 158, 227),
            ),
            child: Align(
              // 使用 Align 来控制子组件的位置
              alignment: Alignment.bottomLeft, // 将文本对齐到底部左侧
              child: Padding(
                padding: EdgeInsets.all(16.0), // 为文本添加你想要的内边距
                child: Text(
                  '未来的账户预留', // 你的标题
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0), // 添加一些垂直间距
            child: UserAvatarManager(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white70),
            title: Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.white70),
            title: Text(
              'My Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to My Profile page
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.white70),
            title: Text(
              'Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              // Navigate to Settings page
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white70),
            title: Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pop(context);
              // Logout logic here
            },
          ),
        ],
      ),
    );
  }
}
