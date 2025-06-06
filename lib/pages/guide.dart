import 'dart:convert';
import 'dart:io';
import 'package:flomosupport/components/currentguide.dart';
import 'package:flomosupport/components/newguide.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/models/guidemodel.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;
import 'package:flomosupport/l10n/app_localizations.dart';

class Guide extends StatefulWidget {
  const Guide({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  State<Guide> createState() => GuideState();
}

class GuideState extends State<Guide> {
  List<Template> templatesdata = [];
  final _fileName = 'templates.json';
  // final _imageDirName = 'guideimages'; // 图片文件夹名称，与 Newguide 保持一致

  @override
  void initState() {
    super.initState();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final appDirPath = path.join(directory.path, 'flomosupport');
      final dir = Directory(appDirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File(path.join(appDirPath, _fileName));
      if (await file.exists()) {
        developer.log("Attempting to read templates file.");
        final contents = await file.readAsString();
        final list = json.decode(contents);
        if (list is! List) {
          throw const FormatException('JSON内容不是列表类型');
        }
        if (mounted) {
          setState(() {
            templatesdata = list.map((e) => Template.fromJson(e)).toList();
          });
          developer.log("Successfully loaded templates data.");
        }
      } else {
        developer
            .log("Templates file does not exist, initializing empty list.");
        setState(() {
          templatesdata = []; // 文件不存在时，初始化为空列表
        });
      }
    } catch (e) {
      developer.log('加载模板失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载模板失败: ${e.toString()}',
                style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    // 获取当前路由是否可以被pop，用于 AppBar leading 按钮的显示
    final bool canPop = Navigator.of(context).canPop();
    final ThemeData currentTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.guidePageTitle),
        centerTitle: true, // 标题居中
        // 根据 canPop 动态显示 leading 按钮
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.pop(context); // 返回上一页
                },
              )
            : IconButton(
                icon: const Icon(Icons.menu), // 抽屉菜单图标
                onPressed: () {
                  widget.scaffoldKey.currentState
                      ?.openDrawer(); // 通过 HomePage 的 ScaffoldKey 打开抽屉
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
        actions: [
          IconButton(
            icon: Icon(Icons.add,
                color: currentTheme
                    .appBarTheme.foregroundColor), // 确保图标颜色与 AppBar 匹配
            onPressed: () async {
              // 注意：这里我们使用 MaterialPageRoute 而不是 pushNamed，因为 Newguide 是一个独立的页面
              // 这样可以确保 Newguide 页面有一个自己的导航堆栈
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Newguide()),
              );
              // 如果 Newguide 页面返回 true，则刷新模板列表
              if (result != null && result == true) {
                await loadTemplates();
                // setState 已经在 loadTemplates 中调用，这里不需要重复
              }
            },
          ),
        ],
        // AppBar 的颜色应该从主题中获取
        backgroundColor: currentTheme.appBarTheme.backgroundColor,
        foregroundColor: currentTheme.appBarTheme.foregroundColor,
      ),
      body: templatesdata.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 80,
                    color: currentTheme.colorScheme.onSurface
                        .withValues(alpha: 90),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '暂无模板，点击右上角加号创建',
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      color: currentTheme.colorScheme.onSurface.withAlpha(90),
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8), // 为 GridView 添加内边距
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.0, // 使卡片保持正方形
              ),
              itemCount: templatesdata.length,
              itemBuilder: (context, index) {
                final template = templatesdata[index];
                return buildTemplateCard(template, currentTheme); // 传递主题数据
              },
            ),
    );
  }

  Widget buildTemplateCard(Template template, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Currentguide(template: template), // 传递模板数据
          ),
        );
        if (refresh == true) {
          await loadTemplates();
        }
      },
      child: Card(
        elevation: 4,
        color: theme.colorScheme.surface, // 卡片背景色
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)), // 圆角
        clipBehavior: Clip.antiAlias, // 裁剪图片以适应圆角
        child: Column(
          children: [
            Expanded(
              child: template.imagePath != null &&
                      template.imagePath!.isNotEmpty
                  ? FutureBuilder<bool>(
                      // 使用 FutureBuilder 确保图片文件存在再加载，避免 FileSystemException
                      future: File(template.imagePath!).exists(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data == true) {
                          return Image.file(
                            File(template.imagePath!),
                            fit: BoxFit.cover, // 居中裁剪并填充
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              developer.log(
                                  '图片加载失败: ${template.imagePath}, 错误: $error');
                              return Container(
                                color: theme.colorScheme
                                    .surfaceContainerHighest, // 错误时显示一个背景色
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: theme.colorScheme.error,
                                    size: 48,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          // 文件不存在或加载中，显示默认图标
                          return Container(
                            color:
                                theme.colorScheme.primaryContainer, // 默认图标背景色
                            child: Center(
                              child: Icon(
                                Icons.article, // 默认图标
                                color: theme.colorScheme.onPrimaryContainer,
                                size: 64,
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : Container(
                      color: theme.colorScheme.primaryContainer, // 默认图标背景色
                      child: Center(
                        child: Icon(
                          Icons.article, // 默认图标
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 64,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                template.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface, // 确保文本颜色与背景对比明显
                ),
                maxLines: 1, // 限制名称只显示一行
                overflow: TextOverflow.ellipsis, // 超出部分显示省略号
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
  }
}
