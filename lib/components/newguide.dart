// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'dart:convert';
// import 'package:flomosupport/models/guidemodel.dart';

// class Newguide extends StatefulWidget {
//   const Newguide({super.key});

//   @override
//   NewguideState createState() => NewguideState();
// }

// class NewguideState extends State<Newguide> {
//   final _fileName = 'templates.json';
//   List<Template> templates = [];
//   final _nameController = TextEditingController(); // 使用控制器管理输入
//   List<String> useritems = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   Future<void> saveTemplates() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final dirPath = '${directory.path}/flomosupport';
//     final dir = Directory(dirPath);
//     if (!await dir.exists()) {
//       await dir.create(recursive: true);
//     }
//     final file = File('$dirPath/$_fileName');

//     // 1. 读取现有文件中的模板数据（如果存在）
//     List<Template> existingTemplates = [];
//     if (await file.exists()) {
//       final contents = await file.readAsString();
//       final jsonList = json.decode(contents) as List;
//       existingTemplates =
//           jsonList.map((json) => Template.fromJson(json)).toList();
//     }

//     // 2. 合并现有模板和当前模板
//     final mergedTemplates = existingTemplates + templates;

//     // 3. 将合并后的列表写入文件
//     final jsonList = mergedTemplates.map((e) => e.toJson()).toList();
//     await file.writeAsString(json.encode(jsonList));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('新建模板')),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 表单标题
//             Text(
//               '添加模板',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),

//             // 模板名称输入框
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: '模板名称',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             if (useritems.isNotEmpty) itemsList() else itemsListisempty(),

//             // 添加条目按钮
//             Center(child: addlist(context)),
//             SizedBox(height: 16),
//             // 保存按钮
//             Center(child: saveButton(context)),
//           ],
//         ),
//       ),
//     );
//   }

//   Padding itemsListisempty() {
//     return Padding(
//       padding: EdgeInsets.only(left: 8),
//       child: Text(
//         '暂未添加任何条目',
//         style: TextStyle(fontWeight: FontWeight.normal, color: Colors.black54),
//       ),
//     );
//   }

//   // Expanded itemsList() {
//   //   return Expanded(
//   //     child: Card(
//   //       elevation: 4,
//   //       child: Padding(
//   //         padding: EdgeInsets.all(8),
//   //         child: ListView.builder(
//   //           itemCount: useritems.length,
//   //           itemBuilder: (context, index) {
//   //             final item = useritems[index];
//   //             return ListTile(
//   //               title: Text(item),
//   //               trailing: IconButton(
//   //                 icon: Icon(Icons.delete, color: Colors.red),
//   //                 onPressed: () {
//   //                   // 删除条目
//   //                   setState(() {
//   //                     useritems.removeAt(index);
//   //                   });
//   //                 },
//   //               ),
//   //             );
//   //           },
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//   Expanded itemsList() {
//     return Expanded(
//       child: Card(
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(8),
//           child: useritems.isEmpty // 如果列表为空，显示提示
//               ? const Center(
//                   child: Text(
//                     '暂未添加任何条目',
//                     style: TextStyle(
//                         fontWeight: FontWeight.normal, color: Colors.black54),
//                   ),
//                 )
//               : Scrollbar(
//                   // 如果列表不为空，显示可滚动的列表
//                   child: ListView.builder(
//                     itemCount: useritems.length,
//                     itemBuilder: (context, index) {
//                       final item = useritems[index];
//                       return ListTile(
//                         title: Text(item),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () {
//                             setState(() {
//                               // 确保索引有效，避免删除时越界
//                               if (index < useritems.length) {
//                                 useritems.removeAt(index);
//                               }
//                             });
//                           },
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   ElevatedButton saveButton(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         if (_nameController.text.isNotEmpty) {
//           final newTemplate = Template(
//             name: _nameController.text,
//             items: useritems,
//           );
//           setState(() {
//             templates.add(newTemplate);
//           });
//           // 一定要使用await来确认已经完成保存之后再清空items
//           if (mounted) {
//             await saveTemplates();
//             // 清空输入
//             _nameController.clear();
//             useritems.clear();
//             Navigator.pop(context, true);
//             //返回成功结果：
//             // 返回 true 表示成功保存
//           }
//         }
//       },
//       child: Text('保存模板'),
//     );
//   }

//   ElevatedButton addlist(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () async {
//         await showDialog(
//           context: context,
//           builder: (context) {
//             final itemsinput = TextEditingController();
//             return AlertDialog(
//               title: Text('添加条目', style: TextStyle(color: Colors.black54)),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextFormField(
//                     controller: itemsinput,
//                     decoration: InputDecoration(labelText: 'list'),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('取消'),
//                 ),
//                 cancelButton(itemsinput, context),
//               ],
//             );
//           },
//         );
//       },
//       child: Text('添加条目'),
//     );
//   }

//   ElevatedButton cancelButton(
//     TextEditingController itemsinput,
//     BuildContext context,
//   ) {
//     return ElevatedButton(
//       onPressed: () {
//         useritems.add(itemsinput.text);
//         Navigator.pop(context);
//         setState(() {}); // 更新UI
//       },
//       child: Text('保存'),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
// 假设你的 guidemodel.dart 包含上述 Template 类定义
import 'package:flomosupport/models/guidemodel.dart'; // 确保路径正确

class Newguide extends StatefulWidget {
  const Newguide({super.key});

  @override
  NewguideState createState() => NewguideState();
}

class NewguideState extends State<Newguide> {
  final _fileName = 'templates.json';
  // 保持你原有的变量名，但使用下划线表示私有
  List<Template> _templates = []; // 存储所有模板，保持与你原有代码一致
  final TextEditingController _nameController = TextEditingController();
  List<String> _useritems = []; // 使用下划线表示私有，存储当前正在编辑的模板的条目

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  // 加载模板的逻辑保持不变
  Future<void> _loadTemplates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = '${directory.path}/flomosupport';
      final file = File('$dirPath/$_fileName');

      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonList = json.decode(contents) as List;
        setState(() {
          _templates = jsonList.map((json) => Template.fromJson(json)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('模板加载失败，$e')),
        );
      }
    }
  }

  // 保存模板的逻辑保持不变
  Future<void> _saveTemplates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = '${directory.path}/flomosupport';
      final dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('$dirPath/$_fileName');

      // 注意：这里需要确保保存的是包含所有模板的列表
      // 如果你的 _saveTemplateButton 已经把新模板添加到 _templates 了
      // 那么这里直接保存 _templates 即可
      final jsonList = _templates.map((e) => e.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('模板保存失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新建模板')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加模板',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '模板名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _useritems.isEmpty
                      ? const Center(
                          child: Text(
                            '暂未添加任何条目',
                            style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: Colors.black54),
                          ),
                        )
                      : Scrollbar(
                          // **这里是关键的修改！**
                          child: ListView.builder(
                            primary: true, // **添加这一行！**
                            itemCount: _useritems.length,
                            itemBuilder: (context, index) {
                              final item = _useritems[index];
                              return ListTile(
                                title: Text(item),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      if (index < _useritems.length) {
                                        _useritems.removeAt(index);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showAddItemDialog(context),
                    child: const Text('添加条目'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTemplate,
                    child: const Text('保存模板'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 显示添加条目对话框
  Future<void> _showAddItemDialog(BuildContext context) async {
    final itemsInputController = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('添加条目', style: TextStyle(color: Colors.black54)),
          content: TextField(
            controller: itemsInputController,
            decoration: const InputDecoration(labelText: '条目内容'),
            autofocus: true, // 自动获取焦点
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (itemsInputController.text.isNotEmpty) {
                  setState(() {
                    _useritems.add(itemsInputController.text.trim());
                  });
                  Navigator.pop(dialogContext); // 关闭对话框
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('条目内容不能为空！')),
                  );
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
    itemsInputController.dispose(); // 对话框关闭后释放控制器
  }

  // 保存当前模板的逻辑
  Future<void> _saveTemplate() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板名称不能为空！')),
      );
      return;
    }
    if (_useritems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板条目不能为空！')),
      );
      return;
    }

    final newTemplate = Template(
      name: _nameController.text.trim(),
      // 这里的 _useritems 已经是 List<String> 类型
      // 你的 Template 类的 items 是 List<dynamic>，可以直接赋值
      items: List<dynamic>.from(_useritems), // 创建副本，确保安全
    );

    setState(() {
      _templates.add(newTemplate); // 将新模板添加到总模板列表
    });

    if (mounted) {
      await _saveTemplates(); // 调用 _saveTemplates 将所有模板保存到文件
      _nameController.clear(); // 清空名称输入框
      _useritems.clear(); // 清空当前条目列表

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模板保存成功！')),
      );
      Navigator.pop(context, true); // 返回上一页并传递成功结果
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
