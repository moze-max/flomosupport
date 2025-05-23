import 'package:flomosupport/pages/about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  final storage = FlutterSecureStorage();
  bool showSuccessMessage = false;
  String? savedKey;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await storage.read(key: 'APIkey');
    setState(() {
      savedKey = key;
    });
  }

  Future<void> saveKey() async {
    final key = textController.text;
    await storage.write(key: 'APIkey', value: key);
    setState(() {
      showSuccessMessage = true;
      savedKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => About()),
              );
            },
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: '请输入密钥',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: saveKey, child: Text('Save keys')),
            SizedBox(height: 20),
            if (showSuccessMessage)
              Text(
                '密钥保存成功！',
                style: TextStyle(color: const Color.fromARGB(255, 21, 79, 101)),
              ),
            SizedBox(height: 20),
            Text(
              '当前保存的密钥：$savedKey',
              style: TextStyle(
                color: const Color.fromARGB(255, 76, 175, 132),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
