// lib/pages/Nickname_Setting_Page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flomosupport/functions/nickname_notifier.dart';

class NicknameSettingPage extends StatefulWidget {
  const NicknameSettingPage({super.key});

  @override
  State<NicknameSettingPage> createState() => _NicknameSettingPageState();
}

class _NicknameSettingPageState extends State<NicknameSettingPage> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    // 确保在 initState 中安全地获取 Provider 数据
    final nicknameNotifier =
        Provider.of<NicknameNotifier>(context, listen: false);

    // 检查昵称是否已加载并且不为空
    if (nicknameNotifier.currentNickname != null &&
        nicknameNotifier.currentNickname!.isNotEmpty &&
        nicknameNotifier.currentNickname! != '未设置昵称') {
      _nicknameController =
          TextEditingController(text: nicknameNotifier.currentNickname);
    } else {
      // 如果没有昵称或昵称是默认值，则不设置任何文本，以显示 hintText
      _nicknameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更改名字'),
        actions: [
          TextButton(
            onPressed: () async {
              // 获取 notifier 实例并更新昵称
              final nicknameNotifier =
                  Provider.of<NicknameNotifier>(context, listen: false);
              await nicknameNotifier.updateNickname(_nicknameController.text);
              // 保存后返回上一页
              if (mounted) {
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).pop();
              }
            },
            child: const Text('保存', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 昵称输入框
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: '输入新昵称',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            // 提示文本
            const Text(
              '好名字可以让你的朋友更容易记住你。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
