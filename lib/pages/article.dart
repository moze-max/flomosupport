import 'package:flomosupport/pages/article/APIkey.dart';
import 'package:flomosupport/pages/article/GeneralSettings.dart';
import 'package:flomosupport/pages/article/notificationsetting.dart';
import 'package:flomosupport/pages/article/AccountSecurity.dart';
import 'package:flomosupport/pages/article/privacy/info.dart';
import 'package:flomosupport/pages/article/privacy/privacy_tip.dart';
import 'package:flomosupport/pages/article/privacy/security.dart';
import 'package:flomosupport/pages/article/privacy/share.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flomosupport/pages/article/about.dart';
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

  File? _localAvatarFile;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载本地头像失败: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            padding:
                const EdgeInsets.only(bottom: 24.0, left: 10.0, right: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: appLocalizations.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
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
                  backgroundImage: _localAvatarFile != null
                      ? FileImage(_localAvatarFile!)
                      : null,
                  child: _localAvatarFile == null
                      ? const Icon(Icons.account_circle,
                          size: 28, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_right),
              ],
            ),
            onTap: () {
              // 导航到账户与安全页面
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountsecurityPage()));
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Notificationsetting()),
              );
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Generalsettings()),
              );
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
              _loadKey();
            },
          ),
          const Divider(),
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

          // 隐私设置
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(appLocalizations.privacySettings),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到隐私设置
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyTip()),
              );
            },
          ),

          // 个人信息收集清单
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(appLocalizations.personalInfoCollection),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到个人信息收集清单
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Info()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: Text(appLocalizations.thirdPartyInfoSharing),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到第三方共享清单
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Share()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(appLocalizations.personalInfoProtection),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // 导航到个人信息保护设置
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Security()),
              );
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
