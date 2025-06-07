import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:developer' as developer;
import 'package:flomosupport/models/guidemodel.dart';

class GuideitemshareTemplate {
  final String name;
  final Widget Function(BuildContext context, Template data)
      builder; // <--- Takes your 'Template' data

  GuideitemshareTemplate({required this.name, required this.builder});
}

// Dummy GuideitemshareTemplate builders for demonstration purposes
// These functions will receive your 'Template' data object and build the UI.
Widget _buildGuideitemshareTemplate1(BuildContext context, Template data) {
  return Container(
    padding: const EdgeInsets.all(20),
    color: Colors.blue.shade100,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (data.imagePath != null && data.imagePath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                // <--- Changed from Image.network to Image.file
                File(data.imagePath!), // <--- Wrap the path in a File object
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.items
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child:
                        Text('- $item', style: const TextStyle(fontSize: 16)),
                  ))
              .toList(),
        ),
      ],
    ),
  );
}

Widget _buildGuideitemshareTemplate2(BuildContext context, Template data) {
  return Container(
    padding: const EdgeInsets.all(20),
    color: Colors.green.shade100,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${data.name} - Details',
          style: const TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        if (data.imagePath != null && data.imagePath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                // <--- Changed from Image.network to Image.file
                File(data.imagePath!), // <--- Wrap the path in a File object
                height: 120,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80),
              ),
            ),
          ),
        Wrap(
          // Using Wrap for potentially many items
          spacing: 8.0, // gap between adjacent chips
          runSpacing: 4.0, // gap between lines
          children:
              data.items.map((item) => Chip(label: Text('$item'))).toList(),
        ),
      ],
    ),
  );
}

// Available GuideitemshareTemplates list
final List<GuideitemshareTemplate> availableGuideitemshareTemplates = [
  GuideitemshareTemplate(
    name: '奖励通知模板',
    builder: (context, data) => _buildGuideitemshareTemplate1(context, data),
  ),
  GuideitemshareTemplate(
    name: '项目详情模板',
    builder: (context, data) => _buildGuideitemshareTemplate2(context, data),
  ),
  // Add more GuideitemshareTemplates as needed
];

class ShareImageWithTemplatePage extends StatefulWidget {
  final Template
      initialTemplateData; // <--- This now explicitly takes your 'Template' data

  const ShareImageWithTemplatePage(
      {super.key, required this.initialTemplateData});

  @override
  ShareImageWithTemplatePageState createState() =>
      ShareImageWithTemplatePageState();
}

class ShareImageWithTemplatePageState
    extends State<ShareImageWithTemplatePage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // Used for screenshot

  late Template _currentTemplateData; // <--- Holds your 'Template' data
  late GuideitemshareTemplate
      _selectedGuideitemshareTemplate; // <--- Holds the selected visual layout/style

  @override
  void initState() {
    super.initState();
    _currentTemplateData = widget.initialTemplateData;
    // Default to the first available visual template style
    _selectedGuideitemshareTemplate = availableGuideitemshareTemplates.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分享'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _captureAndShareImage();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '选择模板样式',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // GuideitemshareTemplate style selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton<GuideitemshareTemplate>(
                      // <--- Dropdown of GuideitemshareTemplate
                      isExpanded: true,
                      value: _selectedGuideitemshareTemplate,
                      onChanged: (GuideitemshareTemplate? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedGuideitemshareTemplate = newValue;
                          });
                        }
                      },
                      items: availableGuideitemshareTemplates
                          .map<DropdownMenuItem<GuideitemshareTemplate>>(
                              (GuideitemshareTemplate shareTemplate) {
                        return DropdownMenuItem<GuideitemshareTemplate>(
                          value: shareTemplate,
                          child: Text(shareTemplate.name),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '预览',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  // RepaintBoundary containing dynamically rendered template content
                  RepaintBoundary(
                    key: _repaintBoundaryKey,
                    // Call the builder function of the currently selected GuideitemshareTemplate
                    // and pass it the _currentTemplateData (your original data model).
                    child: _selectedGuideitemshareTemplate.builder(context,
                        _currentTemplateData), // <--- Correctly passing 'Template' data
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                _captureAndShareImage();
              },
              child: const Text('分享'),
            ),
          ),
        ],
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

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
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

        await SharePlus.instance.share(ShareParams(
          text: '看看我在应用里发现的这个！',
          files: files,
        ));

        developer.log('截图并分享成功: ${imageFile.path}');
      }
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
