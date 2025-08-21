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
    // 使用 Provider 获取当前的昵称
    final nicknameNotifier =
        Provider.of<NicknameNotifier>(context, listen: false);
    _nicknameController =
        TextEditingController(text: nicknameNotifier.currentNickname);
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
