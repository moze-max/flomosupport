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
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = screenWidth * 0.12;
    final drawerHeaderHeight = avatarRadius * 2 + 64.0;
    EdgeInsets.zero;
    return ListTileTheme(
      selectedTileColor: Colors.blueAccent.withAlpha(128),
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: drawerHeaderHeight,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 75, 158, 227),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 12, left: 8, right: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // 垂直居中对齐
                  children: [
                    UserAvatarManager(
                      radius: avatarRadius,
                    ),
                    const SizedBox(width: 30),
                    const Expanded(
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
              // Navigator.pop(context);
              Navigator.pushNamed(context, '/article');
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
