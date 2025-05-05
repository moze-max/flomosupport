import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flomosupport/models/guidemodel.dart';

class Newguide extends StatefulWidget {
  const Newguide({super.key});

  @override
  NewguideState createState() => NewguideState();
}

class NewguideState extends State<Newguide> {
  final _fileName = 'templates.json';
  List<Template> templates = [];
  final _nameController = TextEditingController(); // 使用控制器管理输入
  List<String> useritems = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> saveTemplates() async {
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = '${directory.path}/flomosupport';
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final file = File('$dirPath/$_fileName');

    // 1. 读取现有文件中的模板数据（如果存在）
    List<Template> existingTemplates = [];
    if (await file.exists()) {
      final contents = await file.readAsString();
      final jsonList = json.decode(contents) as List;
      existingTemplates =
          jsonList.map((json) => Template.fromJson(json)).toList();
    }

    // 2. 合并现有模板和当前模板
    final mergedTemplates = existingTemplates + templates;

    // 3. 将合并后的列表写入文件
    final jsonList = mergedTemplates.map((e) => e.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('新建模板')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 表单标题
            Text(
              '添加模板',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // 模板名称输入框
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '模板名称',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            if (useritems.isNotEmpty) itemsList() else itemsListisempty(),

            // 添加条目按钮
            Center(child: addlist(context)),
            SizedBox(height: 16),
            // 保存按钮
            Center(child: saveButton(context)),
          ],
        ),
      ),
    );
  }

  Padding itemsListisempty() {
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: Text(
        '暂未添加任何条目',
        style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black54),
      ),
    );
  }

  Expanded itemsList() {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: useritems.length,
            itemBuilder: (context, index) {
              final item = useritems[index];
              return ListTile(
                title: Text(item),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // 删除条目
                    setState(() {
                      useritems.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  ElevatedButton saveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (_nameController.text.isNotEmpty) {
          final newTemplate = Template(
            name: _nameController.text,
            items: useritems,
          );
          setState(() {
            templates.add(newTemplate);
          });
          // 一定要使用await来确认已经完成保存之后再清空items
          if (mounted) {
            await saveTemplates();
            // 清空输入
            _nameController.clear();
            useritems.clear();
            if (mounted) {
              // ignore: use_build_context_synchronously
              Navigator.pop(context, true);
              //返回成功结果：
              // 返回 true 表示成功保存
            }
          }
        }
      },
      child: Text('保存模板'),
    );
  }

  ElevatedButton addlist(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (context) {
            final itemsinput = TextEditingController();
            return AlertDialog(
              title: Text('添加条目', style: TextStyle(color: Colors.black54)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: itemsinput,
                    decoration: InputDecoration(labelText: 'list'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('取消'),
                ),
                cancelButton(itemsinput, context),
              ],
            );
          },
        );
      },
      child: Text('添加条目'),
    );
  }

  ElevatedButton cancelButton(
    TextEditingController itemsinput,
    BuildContext context,
  ) {
    return ElevatedButton(
      onPressed: () {
        // items.add({itemsinput.text} as String);
        useritems.add(itemsinput.text);
        Navigator.pop(context);
        setState(() {}); // 更新UI
      },
      child: Text('保存'),
    );
  }
}
