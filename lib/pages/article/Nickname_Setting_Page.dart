import 'package:flutter/material.dart';

class NicknameSettingPage extends StatefulWidget {
  final String currentNickname;

  const NicknameSettingPage({
    super.key,
    required this.currentNickname,
  });

  @override
  State<NicknameSettingPage> createState() => _NicknameSettingPageState();
}

class _NicknameSettingPageState extends State<NicknameSettingPage> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.currentNickname);
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
            onPressed: () {
              // 返回新昵称给上一页
              Navigator.of(context).pop(_nicknameController.text);
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
