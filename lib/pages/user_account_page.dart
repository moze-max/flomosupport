import 'package:flomosupport/components/getAvataImage.dart';
import 'package:flutter/material.dart';

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
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 75, 158, 227),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0), // 为 DrawerHeader 内容添加内边距
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中对齐
                children: [
                  UserAvatarManager(
                    radius: 50,
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: Text(
                      'moze',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis, // 昵称过长时显示省略号
                    ),
                  ),
                ],
              ),
            ),
          ),
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
