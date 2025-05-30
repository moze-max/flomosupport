import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flomosupport/l10n/app_localizations.dart';

class ApiKeyManagementPage extends StatefulWidget {
  const ApiKeyManagementPage({super.key});
  @override
  State<ApiKeyManagementPage> createState() => _ApiKeyManagementPageState();
}

class _ApiKeyManagementPageState extends State<ApiKeyManagementPage> {
  final storage = const FlutterSecureStorage();
  String? _currentApiKey; // 用于显示当前保存的密钥
  final TextEditingController _textController = TextEditingController();
  bool _showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _textController.addListener(() {
      if (_showSuccessMessage) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  Future<void> _loadApiKey() async {
    final key = await storage.read(key: 'APIkey');
    setState(() {
      _currentApiKey = key;
      _textController.text = key ?? ''; // 将加载的密钥填充到文本框
    });
  }

  Future<void> _saveApiKey() async {
    final key = _textController.text.trim();
    if (key.isNotEmpty) {
      await storage.write(key: 'APIkey', value: key);
      setState(() {
        _showSuccessMessage = true;
        _currentApiKey = key; // 更新当前显示的密钥
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.keySavedSuccess)),
      );
      // 可以在保存后短暂显示消息，然后隐藏
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSuccessMessage = false;
          });
        }
      });
    } else {
      // 提示用户密钥不能为空
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(context)!.apiKeyEmptyWarning)), // 新增本地化字符串
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.apiKeyManagementPageTitle), // 新增本地化字符串
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
          children: [
            Text(
              appLocalizations.currentSavedKeyInfo, // "当前保存的密钥信息"
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentApiKey != null && _currentApiKey!.isNotEmpty
                  ? _currentApiKey! // 如果有密钥，直接显示密钥
                  : appLocalizations.keyStatusNotSet, // 否则显示“未设置”
              style: TextStyle(
                fontSize: 14,
                color: _currentApiKey != null && _currentApiKey!.isNotEmpty
                    ? Colors.green[700] // 密钥存在时显示绿色
                    : Colors.red[700], // 未设置时显示红色
              ),
              // overflow: TextOverflow.ellipsis, // 超出部分显示省略号
              maxLines: 3, // 限制为一行
            ),
            const SizedBox(height: 24),
            Text(
              appLocalizations.enterApiKey, // "请输入密钥"
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: appLocalizations.apiKeyInputLabel, // "密钥"
                hintText: appLocalizations.apiKeyHint,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
              obscureText: false, // 根据需要设置是否隐藏密钥
            ),
            const SizedBox(height: 20),
            Center(
              // 居中显示保存按钮
              child: ElevatedButton(
                onPressed: _saveApiKey,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(appLocalizations.saveButton),
              ),
            ),
            if (_showSuccessMessage)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    appLocalizations.keySavedSuccess,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 21, 79, 101), fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
