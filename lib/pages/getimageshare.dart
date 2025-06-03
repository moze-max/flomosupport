// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/rendering.dart';
// import 'dart:developer' as developer;

// class ShareAppContentAsImageExample extends StatefulWidget {
//   const ShareAppContentAsImageExample({super.key});

//   @override
//   ShareAppContentAsImageExampleState createState() =>
//       ShareAppContentAsImageExampleState();
// }

// class ShareAppContentAsImageExampleState
//     extends State<ShareAppContentAsImageExample> {
//   final GlobalKey _cardKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('分享应用内容作为图片'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             RepaintBoundary(
//               key: _cardKey,
//               child: Card(
//                 elevation: 4,
//                 // margin: EdgeInsets.all(20),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.blue,
//                         const Color.fromARGB(224, 219, 149, 19)
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Column(
//                       children: [
//                         Icon(Icons.star, color: Colors.amber, size: 50),
//                         SizedBox(height: 10),
//                         Text(
//                           '恭喜！您已获得特别奖励！',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 5),
//                         Text('这是一个测试内容，可以被截图分享。'),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 _captureAndShareImage();
//               },
//               child: Text('截图并分享'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _captureAndShareImage() async {
//     try {
//       RenderRepaintBoundary? boundary =
//           _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

//       if (boundary == null) {
//         developer.log('无法找到要截图的 RenderObject');
//         return;
//       }

//       ui.Image image = await boundary.toImage(
//           pixelRatio: MediaQuery.of(context).devicePixelRatio);
//       ByteData? byteData =
//           await image.toByteData(format: ui.ImageByteFormat.png);

//       if (byteData == null) {
//         developer.log('无法获取字节数据');
//         return;
//       }

//       Uint8List pngBytes = byteData.buffer.asUint8List();
//       final Directory tempDir = await getTemporaryDirectory();
//       final File imageFile = File('${tempDir.path}/screenshot.png');
//       await imageFile.writeAsBytes(pngBytes);

//       // *** 关键修改点：将 files 列表作为 ShareParams 的 files 参数传递 ***
//       final List<XFile> files = [XFile(imageFile.path)];

//       SharePlus.instance.share(ShareParams(
//         text: '看看我在应用里发现的这个！', // 文本可选
//         files: files, // 文件列表在这里传递
//       ));

//       developer.log('截图并分享成功: ${imageFile.path}');
//     } catch (e) {
//       developer.log('截图或分享失败: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('截图或分享失败: $e')),
//         );
//       }
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:developer' as developer;

// 导入我们定义的模板和模板列表
import 'package:flomosupport/models/sharemodel.dart'; // 假设这个文件在 lib/templates 目录下
import 'package:flomosupport/components/sharemodel.dart'; // 假设这个文件在 lib/models 目录下

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '分享图片模板示例',
      theme: ThemeData.light(),
      home: ShareImageWithTemplatePage(),
    );
  }
}

class ShareImageWithTemplatePage extends StatefulWidget {
  const ShareImageWithTemplatePage({super.key});

  @override
  ShareImageWithTemplatePageState createState() =>
      ShareImageWithTemplatePageState();
}

class ShareImageWithTemplatePageState
    extends State<ShareImageWithTemplatePage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // 用于截图的 GlobalKey

  // 要分享的动态内容
  String _shareTitle = '恭喜！您已获得特别奖励！';
  String _shareContent = '这是一个测试内容，可以被截图分享。您可以替换成任何动态数据。';

  // 当前选中的模板
  Template _selectedTemplate = availableTemplates.first; // 默认选择第一个模板

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('分享图片模板示例'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _captureAndShareImage();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              '选择分享图片模板',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // 模板选择器 (使用 DropdownButton 或水平滚动列表)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButton<Template>(
                isExpanded: true,
                value: _selectedTemplate,
                onChanged: (Template? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTemplate = newValue;
                    });
                  }
                },
                items: availableTemplates
                    .map<DropdownMenuItem<Template>>((Template template) {
                  return DropdownMenuItem<Template>(
                    value: template,
                    child: Text(template.name),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 30),
            Text(
              '预览 (将被截图)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            // RepaintBoundary 包含动态渲染的模板内容
            RepaintBoundary(
              key: _repaintBoundaryKey,
              // 根据当前选中的模板，调用其 builder 函数来构建要截图的 Widget
              child: _selectedTemplate.builder(
                  context, _shareTitle, _shareContent),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _captureAndShareImage();
              },
              child: Text('截图并分享'),
            ),
            SizedBox(height: 20),
            // 示例：可以添加 TextField 让用户编辑分享内容
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: '分享标题'),
                    onChanged: (value) {
                      setState(() {
                        _shareTitle = value;
                      });
                    },
                    controller: TextEditingController(text: _shareTitle),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(labelText: '分享内容'),
                    onChanged: (value) {
                      setState(() {
                        _shareContent = value;
                      });
                    },
                    maxLines: 3,
                    controller: TextEditingController(text: _shareContent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndShareImage() async {
    try {
      RenderRepaintBoundary? boundary = _repaintBoundaryKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        developer.log('无法找到要截图的 RenderObject');
        return;
      }

      // 确保渲染完成，特别是对于可能需要加载网络图片或其他异步内容的模板
      // 这里可以添加延迟或等待图片加载完成的逻辑
      await Future.delayed(const Duration(milliseconds: 100)); // 简单延迟，等待渲染

      ui.Image image = await boundary.toImage(
          pixelRatio: MediaQuery.of(context).devicePixelRatio);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        developer.log('无法获取字节数据');
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      final Directory tempDir = await getTemporaryDirectory();
      final File imageFile = File('${tempDir.path}/screenshot.png');
      await imageFile.writeAsBytes(pngBytes);

      final List<XFile> files = [XFile(imageFile.path)];

      SharePlus.instance.share(ShareParams(
        text: '看看我在应用里发现的这个！',
        files: files,
      ));

      developer.log('截图并分享成功: ${imageFile.path}');
    } catch (e) {
      developer.log('截图或分享失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('截图或分享失败: $e')),
        );
      }
    }
  }
}
