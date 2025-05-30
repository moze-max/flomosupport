// 我希望在这个组件里面输入内容，然后组合之后通过API发送到服务器
// 如果服务器返回成功，那么就弹窗显示发送成功。
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flomosupport/models/guidemodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class Currentguide extends StatefulWidget {
  final Template template;
  const Currentguide({super.key, required this.template});

  @override
  State<Currentguide> createState() => _CurrentguideState();
}

class _CurrentguideState extends State<Currentguide> {
  final storage = FlutterSecureStorage();
  String? savedKey;
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    _loadKey();
    controllers = {
      for (var item in widget.template.items) item: TextEditingController(),
    };
  }

  Future<void> _loadKey() async {
    final key = await storage.read(key: 'APIkey');
    setState(() {
      savedKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.name), // 显示模板名称作为标题
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('确认删除'),
                      content: Text('确定要删除"${widget.template.name}"吗？此操作不可撤销。'),
                      actions: [
                        TextButton(
                          child: Text('取消'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: Text(
                            '删除',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                deleteTemplate();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.template.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ...widget.template.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[item],
                  decoration: InputDecoration(
                    labelText: item,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // 添加一些间距
            ElevatedButton(
              onPressed: () {
                sendFormData(); // 当按钮被点击时发送表单数据
                Navigator.pop(context);
              },
              child: Text('提交'),
            ),
          ],
        ),
      ),
    );
  }

  void sendFormData() {
    Map<String, dynamic> formData = {};
    controllers.forEach((key, value) {
      formData[key] = value.text; // 将每个 item 和其对应的输入框内容存入 map
    });

    String formattedContent = formData.entries
        .map((entry) => "${entry.key}\n${entry.value}\n")
        .join("\n");
    sendData(formattedContent); // 发送数据
  }

  Future<void> sendData(String data) async {
    final url = Uri.parse('$savedKey');
    int retryCount = 0;
    const maxRetries = 3;

    Map<String, dynamic> requestBody = {"content": data};

    while (retryCount < maxRetries) {
      try {
        // Convert the Map to a JSON string correctly.
        final response = await http.post(
          url,
          body: jsonEncode(requestBody), // 序列化map为json字符串
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (response.statusCode == 200) {
          // 请求成功，处理响应
          developer.log("Response:\n${response.body}");
          break; // 成功后退出循环
        } else {
          throw Exception('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          developer.log("请求失败: $e");
          return; // 达到最大重试次数后退出
        }
        developer.log("\n[警告] 上传失败，5秒后重试（剩余尝试次数：$retryCount/$maxRetries）...");
        await Future.delayed(Duration(seconds: 5)); // 等待5秒后重试
      }
    }
  }

  Future<void> deleteTemplate() async {
    final contextCopy = context; // 复制 context
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = path.join(directory.path, 'flomosupport');
      final file = File(path.join(dirPath, 'templates.json'));

      if (!await file.exists()) {
        throw Exception('Templates file does not exist');
      }

      final contents = await file.readAsString();
      List<dynamic> templatesList = json.decode(contents);

      templatesList.removeWhere(
        (template) => template['name'] == widget.template.name,
      );

      await file.writeAsString(json.encode(templatesList));

      developer.log("Template deleted successfully from local storage.");

      // 显示成功提示
      if (contextCopy.mounted) {
        ScaffoldMessenger.of(
          contextCopy,
        ).showSnackBar(const SnackBar(content: Text('模板已删除')));

        if (contextCopy.mounted) {
          Navigator.pop(contextCopy, true);
        }
      }
    } catch (e) {
      developer.log("Error deleting template locally: $e");

      // 显示错误提示
      if (contextCopy.mounted) {
        ScaffoldMessenger.of(
          contextCopy,
        ).showSnackBar(const SnackBar(content: Text('删除模板失败')));
      }
    }
  }

  @override
  void dispose() {
    // 确保释放所有 TextEditingController
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
