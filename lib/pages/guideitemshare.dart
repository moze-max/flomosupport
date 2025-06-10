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
  final Widget Function(BuildContext context, Template data) builder;

  GuideitemshareTemplate({required this.name, required this.builder});
}

// Dummy GuideitemshareTemplate builders for demonstration purposes
// These functions will receive your 'Template' data object and build the UI.
Widget _buildGuideitemshareTemplate1(BuildContext context, Template data) {
  final double screenWidth = MediaQuery.of(context).size.width;
  // Define a desired base width for the content, aiming for wider usage
  final double contentWidth =
      screenWidth * 0.85; // Now 85% of screen width for a slightly wider look

  // Define proportions for elements relative to contentWidth
  final double imageSize =
      contentWidth * 0.4; // Image takes 40% of content width
  final double titleMaxWidth =
      contentWidth * 0.95; // Title can be almost full content width

  // Define your custom black and gold colors
  const Color backgroundColor = Colors.black; // Deep black background
  const Color goldenBorderColor =
      Color.fromARGB(255, 162, 128, 13); // Classic gold color
  const Color goldenTextColor = Color(0xFFD4AF37); // Gold for title
  const Color itemTextColor = Colors.white; // White for list items
  const Color subtleFooterColor = Colors.grey; // Subtle grey for the footer

  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16),
    child: Container(
      // The outer container for the golden border effect
      decoration: BoxDecoration(
        color: backgroundColor, // Inner fill color
        borderRadius: BorderRadius.circular(
            15), // Slightly more rounded corners for the overall card
        border: Border.all(
          color: goldenBorderColor, // Golden border
          width: 3, // Thicker golden border
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(
          15), // Reduced padding here to give more space for inner content due to border
      child: SizedBox(
        width: contentWidth, // Use the calculated contentWidth here
        child: Padding(
          padding:
              const EdgeInsets.all(8.0), // Padding inside the main content area
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content tightly
            children: [
              // Template Title
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: titleMaxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: goldenTextColor, // Golden title text
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Template Image (if available)
              if (data.imagePath != null && data.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(data.imagePath!),
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors
                            .grey, // Error icon can remain grey or match theme
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Template Items
              SizedBox(
                width:
                    contentWidth, // Ensure this inner Column takes the full contentWidth
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align items to the start
                  children: data.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- $item',
                            style: const TextStyle(
                              fontSize: 20,
                              color: itemTextColor, // White text for items
                            ),
                            softWrap: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 15),
              // Footer text "来自 FlomoSupport"
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '来自 FlomoSupport',
                  style: TextStyle(
                      color: subtleFooterColor,
                      fontSize: 10), // Subtle grey footer
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
// Ensure your Template model is imported

Widget _buildGuideitemshareTemplate2(BuildContext context, Template data) {
  final double screenWidth = MediaQuery.of(context).size.width;
  // Define a desired base width for the content, aiming for wider usage
  final double contentWidth =
      screenWidth * 0.85; // Now 85% of screen width for a slightly wider look

  // Define proportions for elements relative to contentWidth
  final double imageSize =
      contentWidth * 0.4; // Image takes 40% of content width
  final double titleMaxWidth =
      contentWidth * 0.95; // Title can be almost full content width

  // Define your custom black and gold colors
  // For the gradient, we'll define a list of colors
  const Color gradientStartColor =
      Color.fromARGB(255, 0, 0, 0); // Very dark grey/near black
  const Color gradientEndColor =
      Color.fromARGB(255, 60, 60, 60); // Slightly lighter dark grey
  const Color goldenBorderColor = Color(0xFFD4AF37); // Classic gold color
  const Color goldenTextColor = Color(0xFFD4AF37); // Gold for title
  const Color itemTextColor = Colors.white; // White for list items
  const Color subtleFooterColor = Colors.grey; // Subtle grey for the footer

  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16),
    child: Container(
      // The outer container for the gradient background and golden border
      decoration: BoxDecoration(
        // Use gradient instead of solid color
        gradient: const LinearGradient(
          begin: Alignment.topLeft, // Gradient starts from top-left
          end: Alignment.bottomRight, // Ends at bottom-right
          colors: [
            gradientStartColor,
            gradientEndColor,
          ],
          // You can add stops for more control over color distribution
          // stops: [0.0, 1.0], // Optional, default is even distribution
        ),
        borderRadius: BorderRadius.circular(
            15), // Slightly more rounded corners for the overall card
        border: Border.all(
          color: goldenBorderColor, // Golden border
          width: 3, // Thicker golden border
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(
          15), // Reduced padding here to give more space for inner content due to border
      child: SizedBox(
        width: contentWidth, // Use the calculated contentWidth here
        child: Padding(
          padding:
              const EdgeInsets.all(8.0), // Padding inside the main content area
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content tightly
            children: [
              // Template Title
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: titleMaxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: goldenTextColor, // Golden title text
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Template Image (if available)
              if (data.imagePath != null && data.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(data.imagePath!),
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors
                            .grey, // Error icon can remain grey or match theme
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Template Items
              SizedBox(
                width:
                    contentWidth, // Ensure this inner Column takes the full contentWidth
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align items to the start
                  children: data.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- $item',
                            style: const TextStyle(
                              fontSize: 20,
                              color: itemTextColor, // White text for items
                            ),
                            softWrap: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 15),
              // Footer text "来自 FlomoSupport"
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '来自 FlomoSupport',
                  style: TextStyle(
                      color: subtleFooterColor,
                      fontSize: 10), // Subtle grey footer
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildGuideitemshareTemplate3(BuildContext context, Template data) {
  final double screenWidth = MediaQuery.of(context).size.width;
  // Define a desired base width for the content, aiming for wider usage
  final double contentWidth = screenWidth * 0.85; // 85% of screen width

  // Define proportions for elements relative to contentWidth
  final double imageSize =
      contentWidth * 0.4; // Image takes 40% of content width
  final double titleMaxWidth =
      contentWidth * 0.95; // Title can be almost full content width

  // Define your vibrant blue to pink gradient colors
  const Color gradientStartColor =
      Color(0xFF89CFF0); // A cheerful light blue (Baby Blue)
  const Color gradientEndColor =
      Color(0xFFF08080); // A soft coral pink (Light Coral)

  // Text colors to complement the gradient
  const Color titleTextColor =
      Color(0xFF333333); // Dark grey/near black for good contrast
  const Color itemTextColor =
      Color(0xFF555555); // Slightly lighter dark grey for items
  const Color subtleFooterColor =
      Color.fromARGB(234, 3, 64, 68); // Even lighter grey for the footer

  return Padding(
    padding: const EdgeInsets.only(left: 16, right: 16),
    child: Container(
      // The outer container for the gradient background and a subtle border
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientStartColor,
            gradientEndColor,
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        // Adding a subtle border for definition, maybe a darker shade of the gradient start/end
        border: Border.all(
          color: gradientEndColor
              .withOpacity(0.5), // A subtle border using the pink with opacity
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(15),
      child: SizedBox(
        width: contentWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Template Title
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: titleMaxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: titleTextColor, // Dark text for good contrast
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Template Image (if available)
              if (data.imagePath != null && data.imagePath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(data.imagePath!),
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey, // Error icon remains neutral
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Template Items
              SizedBox(
                width: contentWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.items
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Text(
                            '- $item',
                            style: const TextStyle(
                              fontSize: 20,
                              color: itemTextColor, // Dark grey text for items
                            ),
                            softWrap: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 15),
              // Footer text "来自 FlomoSupport"
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '来自 FlomoSupport',
                  style: TextStyle(
                      color: subtleFooterColor,
                      fontSize: 10), // Light grey footer
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// Available GuideitemshareTemplates list
final List<GuideitemshareTemplate> availableGuideitemshareTemplates = [
  GuideitemshareTemplate(
    name: '黑金模板',
    builder: (context, data) => _buildGuideitemshareTemplate1(context, data),
  ),
  GuideitemshareTemplate(
    name: '渐变色背景',
    builder: (context, data) => _buildGuideitemshareTemplate2(context, data),
  ),
  GuideitemshareTemplate(
    name: '渐变色背景',
    builder: (context, data) => _buildGuideitemshareTemplate3(context, data),
  ),
];

class ShareImageWithTemplatePage extends StatefulWidget {
  final Template initialTemplateData;

  const ShareImageWithTemplatePage(
      {super.key, required this.initialTemplateData});

  @override
  ShareImageWithTemplatePageState createState() =>
      ShareImageWithTemplatePageState();
}

class ShareImageWithTemplatePageState
    extends State<ShareImageWithTemplatePage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey(); // Used for screenshot

  late Template _currentTemplateData;
  late GuideitemshareTemplate _selectedGuideitemshareTemplate;

  @override
  void initState() {
    super.initState();
    _currentTemplateData = widget.initialTemplateData;
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
                    child: _selectedGuideitemshareTemplate.builder(
                        context, _currentTemplateData),
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
