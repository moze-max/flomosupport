import 'package:flomosupport/components/settings_list_item.dart';
import 'package:flomosupport/components/settings_section_header.dart';
import 'package:flomosupport/pages/article/APIkey.dart';
import 'package:flomosupport/pages/article/GeneralSettings.dart';
import 'package:flomosupport/pages/article/notificationsetting.dart';
import 'package:flomosupport/pages/article/AccountSecurity.dart';
import 'package:flomosupport/pages/article/privacy/info.dart';
import 'package:flomosupport/pages/article/privacy/privacy_tip.dart';
import 'package:flomosupport/pages/article/privacy/security.dart';
import 'package:flomosupport/pages/article/privacy/sharelist.dart';
import 'package:flomosupport/pages/class_items_management.dart';
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
  static const Key endOfArticlePage = Key('keyOfEndOfArticlePage');
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
    _loadLocalAvatar();
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

      // Check if the directory exists
      if (!await avatarsDir.exists()) {
        // developer.log('Avatar directory does not exist: ${avatarsDir.path}');
        if (mounted) {
          setState(() {
            _localAvatarFile = null; // No directory, so no avatar
          });
        }
        return;
      }

      // List all files in the directory
      final files = avatarsDir.listSync().whereType<File>().toList();

      File? latestAvatarFile;

      // Filter for avatar files (based on your new naming convention)
      // and find the most recent one
      if (files.isNotEmpty) {
        final avatarFiles = files.where((file) {
          final fileName = path.basename(file.path);
          // Assuming your new files are like 'user_avatar_TIMESTAMP.png'
          return fileName.startsWith('user_avatar_') &&
              path.extension(fileName) == '.png';
        }).toList();

        if (avatarFiles.isNotEmpty) {
          // Sort by last modified date to find the latest
          avatarFiles.sort(
              (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
          latestAvatarFile = avatarFiles.first;
        }
      }

      if (latestAvatarFile != null && await latestAvatarFile.exists()) {
        if (mounted) {
          setState(() {
            _localAvatarFile =
                latestAvatarFile; // Set the local avatar file to the latest one found
          });
        }
        // developer
        //     .log('Successfully loaded local avatar: ${latestAvatarFile.path}');
      } else {
        if (mounted) {
          setState(() {
            _localAvatarFile = null; // No avatar found or file doesn't exist
          });
        }
        // developer.log('No local avatar file found or it does not exist.');
      }
    } catch (e) {
      // developer.log(
      //     'Failed to load local avatar: $e'); // Use developer.log for debugging
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
    final bool canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.articlePageTitle),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: canPop
                  ? const Icon(Icons.arrow_back_ios_new)
                  : const Icon(Icons.menu),
              onPressed: () {
                if (canPop) {
                  Navigator.pop(context); // 返回上一页
                } else {
                  // 打开抽屉
                  widget.scaffoldKey.currentState?.openDrawer();
                }
              },
              tooltip: canPop
                  ? MaterialLocalizations.of(context).backButtonTooltip
                  : MaterialLocalizations.of(context).openAppDrawerTooltip,
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
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 16.0),
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
          Expanded(
            child: ListView(
              key: const Key('mainSettingsScrollView'),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: [
                // --- 账户与安全部分 ---
                SettingsListItem(
                  key: const Key('accountAndSecurityItem'),
                  icon: Icons.person_outline,
                  title: appLocalizations.accountAndSecurity,
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AccountsecurityPage()));
                  },
                ),
                const Divider(),

                // --- 功能部分 ---
                SettingsSectionHeader(
                    title: appLocalizations.functionsSectionTitle),
                SettingsListItem(
                  key: const Key('messageNotificationsItem'),
                  icon: Icons.notifications_none,
                  title: appLocalizations.messageNotifications,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Notificationsetting()),
                    );
                  },
                ),
                SettingsListItem(
                  key: const Key('modeSelectionItem'),
                  icon: Icons.color_lens_outlined,
                  title: appLocalizations.modeSelection,
                  trailing: Text(appLocalizations.normalMode),
                  onTap: () {
                    // 导航到模式选择设置
                  },
                ),
                SettingsListItem(
                  key: const Key('ClassItemManagement'),
                  icon: Icons.align_horizontal_left_rounded,
                  title: appLocalizations.classItemManagement,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ClassItemManagementPage()),
                    );
                  },
                ),
                SettingsListItem(
                  key: const Key('generalSettingsItem'),
                  icon: Icons.settings_outlined,
                  title: appLocalizations.generalSettings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Generalsettings()),
                    );
                  },
                ),
                const Divider(),

                // --- 密钥设置部分 ---
                SettingsSectionHeader(
                    title: appLocalizations.apiKeySectionTitle),
                SettingsListItem(
                  key: const Key('currentSavedKeyItem'),
                  icon: Icons.vpn_key_outlined,
                  title: appLocalizations.currentSavedKey,
                  subtitle: Text(
                    savedKey != null && savedKey!.isNotEmpty
                        ? appLocalizations.keyStatusSaved
                        : appLocalizations.keyStatusNotSet,
                    style: TextStyle(
                      color: savedKey != null && savedKey!.isNotEmpty
                          ? Colors.green[700]
                          : Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                  onTap: () async {
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
                SettingsSectionHeader(
                    title: appLocalizations.privacySectionTitle),
                SettingsListItem(
                  key: const Key('privacySettingsItem'),
                  icon: Icons.privacy_tip_outlined,
                  title: appLocalizations.privacySettings,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyTip()),
                    );
                  },
                ),
                SettingsListItem(
                  key: const Key('personalInfoCollectionItem'),
                  icon: Icons.info_outline,
                  title: appLocalizations.personalInfoCollection,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Info()),
                    );
                  },
                ),
                SettingsListItem(
                  key: const Key('thirdPartyInfoSharingItem'),
                  icon: Icons.share_outlined,
                  title: appLocalizations.thirdPartyInfoSharing,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Sharelist()),
                    );
                  },
                ),
                SettingsListItem(
                  key: ValueKey('personalInfoProtectionItem'),
                  icon: Icons.security,
                  title: appLocalizations.personalInfoProtection,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Security()),
                    );
                  },
                ),
                const Divider(),
              ],
            ),
          ),
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
