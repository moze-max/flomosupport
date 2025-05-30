// import 'package:flomosupport/pages/about.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flomosupport/l10n/app_localizations.dart';

// class Article extends StatefulWidget {
//   const Article({super.key, required this.scaffoldKey});
//   final GlobalKey<ScaffoldState> scaffoldKey;
//   @override
//   State<Article> createState() => _ArticleState();
// }

// class _ArticleState extends State<Article> {
//   final storage = FlutterSecureStorage();
//   bool showSuccessMessage = false;
//   String? savedKey;
//   final textController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadKey();
//   }

//   Future<void> _loadKey() async {
//     final key = await storage.read(key: 'APIkey');
//     setState(() {
//       savedKey = key;
//     });
//   }

//   Future<void> saveKey() async {
//     final key = textController.text;
//     await storage.write(key: 'APIkey', value: key);
//     setState(() {
//       showSuccessMessage = true;
//       savedKey = key;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(appLocalizations.articlePageTitle),
//         leading: Builder(
//           builder: (BuildContext context) {
//             return IconButton(
//               icon: const Icon(Icons.menu),
//               onPressed: () {
//                 // 打开最近的 Scaffold 的 Drawer
//                 widget.scaffoldKey.currentState?.openDrawer();
//               },
//               tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
//             );
//           },
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => About()),
//               );
//             },
//             icon: Icon(Icons.info_outline),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TextField(
//               controller: textController,
//               decoration: InputDecoration(
//                 labelText: '请输入密钥',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(onPressed: saveKey, child: Text('Save keys')),
//             SizedBox(height: 20),
//             if (showSuccessMessage)
//               Text(
//                 '密钥保存成功！',
//                 style: TextStyle(color: const Color.fromARGB(255, 21, 79, 101)),
//               ),
//             SizedBox(height: 20),
//             Text(
//               '当前保存的密钥：$savedKey',
//               style: TextStyle(
//                 color: const Color.fromARGB(255, 76, 175, 132),
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     textController.dispose();
//     super.dispose();
//   }
// }

import 'package:flomosupport/pages/article/APIkey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flomosupport/pages/article/about.dart'; // 确保导入了 About 页面
import 'dart:io'; // 导入 dart:io 用于 File
import 'package:path_provider/path_provider.dart'; // 导入 path_provider 获取应用目录
import 'package:path/path.dart' as path; // 导入 path 包处理路径

class Article extends StatefulWidget {
  const Article({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  final storage = const FlutterSecureStorage();
  bool showSuccessMessage = false;
  String? savedKey;
  final textController = TextEditingController();

  File? _localAvatarFile; // 新增：用于存储本地头像文件

  @override
  void initState() {
    super.initState();
    _loadKey();
    _loadLocalAvatar(); // 新增：加载本地头像
    textController.addListener(() {
      if (showSuccessMessage) {
        setState(() {
          showSuccessMessage = false;
        });
      }
    });
  }

  Future<void> _loadKey() async {
    final key = await storage.read(key: 'APIkey');
    setState(() {
      savedKey = key;
      textController.text = key ?? '';
    });
  }

  Future<void> _loadLocalAvatar() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir =
          Directory(path.join(appDir.path, 'flomosupport', 'avatars'));
      final String fileName = 'user_avatar.png';
      final String filePath = path.join(avatarsDir.path, fileName);
      final File savedFile = File(filePath);

      if (await savedFile.exists()) {
        setState(() {
          _localAvatarFile = savedFile; // 设置本地头像文件
        });
      }
    } catch (e) {
      if (mounted) {
        // 确保 Widget 仍然在树中，避免 setState 或 showSnackBar 在 Widget 销毁后调用
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载本地头像失败: ${e.toString()}'), // 显示具体的错误信息
            backgroundColor: Colors.red, // 错误提示可以使用红色背景
          ),
        );
      }
    }
  }

  Future<void> saveKey() async {
    final key = textController.text.trim();
    if (key.isNotEmpty) {
      await storage.write(key: 'APIkey', value: key);
      setState(() {
        showSuccessMessage = true;
        savedKey = key;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showSuccessMessage = false;
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密钥不能为空！')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.articlePageTitle),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                widget.scaffoldKey.currentState?.openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const About()),
              );
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: appLocalizations.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor ??
                    Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                // 搜索逻辑
              },
            ),
          ),

          // --- 账户与安全部分 ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(appLocalizations.accountAndSecurity),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  // **修改这里：根据 _localAvatarFile 来显示头像**
                  backgroundImage: _localAvatarFile != null
                      ? FileImage(_localAvatarFile!) // 如果本地头像文件存在，使用 FileImage
                      : null, // 否则不设置 backgroundImage
                  child: _localAvatarFile == null
                      ? const Icon(Icons.account_circle,
                          size: 28, color: Colors.grey) // 如果没有本地头像，显示默认图标
                      : null, // 如果有本地头像，不显示子组件
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_right),
              ],
            ),
            onTap: () {
              // 导航到账户与安全页面
              // 可以在这里 push 一个新的路由，例如 Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSecurityPage()));
            },
          ),
          const Divider(),

          // --- 功能部分 ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              appLocalizations.functionsSectionTitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(appLocalizations.messageNotifications),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到消息通知设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: Text(appLocalizations.modeSelection),
            trailing: Text(appLocalizations.normalMode),
            onTap: () {
              // 导航到模式选择设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.brush),
            title: Text(appLocalizations.personalization),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到个性装扮设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(appLocalizations.generalSettings),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到通用设置
            },
          ),
          const Divider(),

          // --- 密钥设置部分 ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              appLocalizations.apiKeySectionTitle, // "密钥管理"
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key_outlined),
            title: Text(appLocalizations.currentSavedKey), // "当前保存的密钥"
            // 根据 savedKey 的状态显示内容
            subtitle: Text(
              savedKey != null && savedKey!.isNotEmpty
                  ? appLocalizations.keyStatusSaved // "已保存"
                  : appLocalizations.keyStatusNotSet, // "未设置"
              style: TextStyle(
                color: savedKey != null && savedKey!.isNotEmpty
                    ? Colors.green[700]
                    : Colors.red[700],
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.keyboard_arrow_right), // 右侧箭头
            onTap: () async {
              // 点击时导航到新的密钥管理页面
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ApiKeyManagementPage()),
              );
              // 从新页面返回后，重新加载密钥状态，以更新显示
              _loadKey();
            },
          ),
          // 移除原有的成功消息和 Divider，因为它们都在新页面处理了
          // if (showSuccessMessage) ...
          const Divider(), // 仍然保留一个分隔线

          // --- 隐私部分 ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              appLocalizations.privacySectionTitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(appLocalizations.privacySettings),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到隐私设置
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(appLocalizations.personalInfoCollection),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到个人信息收集清单
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(appLocalizations.thirdPartyInfoSharing),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到第三方共享清单
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(appLocalizations.personalInfoProtection),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到个人信息保护设置
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
