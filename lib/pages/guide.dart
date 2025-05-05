import 'dart:convert';
import 'dart:io';
import 'package:flomosupport/components/currentguide.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flomosupport/components/newguide.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/models/guidemodel.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;

class Guide extends StatefulWidget {
  const Guide({super.key});

  @override
  State<Guide> createState() => _GuideState();
}

class _GuideState extends State<Guide> {
  List<Template> templatesdata = [];
  final _fileName = 'templates.json';

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = path.join(directory.path, 'flomosupport');
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File(path.join(dirPath, _fileName));
      if (await file.exists()) {
        developer.log("enable to read file.");
        final contents = await file.readAsString();
        final list = json.decode(contents);
        if (list is! List) {
          throw FormatException('JSON内容不是列表类型');
        }
        if (mounted) {
          setState(() {
            templatesdata = list.map((e) => Template.fromJson(e)).toList();
          });
          developer.log("Sucessful to write templatesdata");
        }
      }
    } catch (e) {
      developer.log('加载模板失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Writing Guide'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              // 使用 await 获取返回结果
              final result = await Navigator.pushNamed(context, '/newguide');
              if (result != null && result == true) {
                // 成功保存后重新加载模板
                await loadTemplates(); // 调用 loadTemplates() 刷新数据
              }
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.0,
        ),
        itemCount: templatesdata.length,
        itemBuilder: (context, index) {
          final template = templatesdata[index];
          return buildTemplateCard(template);
        },
      ),
    );
  }

  Widget buildTemplateCard(Template template) {
    return InkWell(
      onTap: () async {
        // 等待 Currentguide 页面的返回结果
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Currentguide(template: template), // 传递模板数据
          ),
        );

        // 如果 Currentguide 页面返回 true，则刷新模板列表
        if (refresh == true) {
          await loadTemplates();
          setState(() {});
        }
      },
      child: Card(
        elevation: 4,
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: const Color.fromARGB(255, 76, 116, 175),
                child: Center(
                  child: Icon(
                    Icons.all_inclusive,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                template.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // 确保文本颜色与背景对比明显
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
    super.dispose();
    // saveTemplates();
  }
}
