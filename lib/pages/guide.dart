import 'dart:convert';
import 'dart:io';
import 'package:flomosupport/components/guide_card.dart';
import 'package:flomosupport/pages/newguide.dart';
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
  // 新增的状态变量
  String? _selectedClassItem; // null 表示选中 "全部"
  List<String> _uniqueClassItems = []; // 存储所有不重复的 classItems

  @override
  void initState() {
    super.initState();
    _selectedClassItem = null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadTemplates(); // 等待模板数据加载完成
    _extractUniqueClassItems(); // 数据加载完成后再提取分类
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
        _extractUniqueClassItems();
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
      _extractUniqueClassItems();
    }
  }

  void _extractUniqueClassItems() {
    final Set<String> classItemsSet = {};
    for (final template in templatesdata) {
      if (template.classitems != null) {
        for (final item in template.classitems!) {
          classItemsSet.add(item);
        }
      }
    }
    setState(() {
      _uniqueClassItems = classItemsSet.toList()..sort();
    });
  }

  List<Template> get _filteredTemplates {
    if (_selectedClassItem == null) {
      // 如果选中“全部”，返回所有模板
      return templatesdata;
    } else {
      // 否则，只返回包含选中 classItem 的模板
      return templatesdata.where((template) {
        // 只有当模板的 classitems 不为 null 且包含选中的 classItem 时才显示
        return template.classitems != null &&
            template.classitems!.contains(_selectedClassItem!);
      }).toList();
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
      body: Column(
        children: [
          SizedBox(
            height: 50, // 定义分类行的高度
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // 水平滚动
              padding: const EdgeInsets.symmetric(horizontal: 8.0), // 左右内边距
              itemCount: _uniqueClassItems.length + 1, // +1 用于“全部”选项
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 第一个选项是“全部”
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('全部'), // "全部" 的本地化字符串
                      selected: _selectedClassItem ==
                          null, // 如果 _selectedClassItem 为 null，则选中
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedClassItem = null; // 选中“全部”类别
                          });
                        }
                      },
                    ),
                  );
                } else {
                  // 其他选项是具体的 classItem
                  final classItem =
                      _uniqueClassItems[index - 1]; // 获取对应的 classItem
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(classItem),
                      selected: _selectedClassItem ==
                          classItem, // 如果当前 classItem 匹配，则选中
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedClassItem = classItem; // 选中这个 classItem
                          });
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: _filteredTemplates.isEmpty
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
                          _selectedClassItem == null &&
                                  templatesdata
                                      .isEmpty // 只有当“全部”被选中且原始数据为空时才显示这个
                              ? '暂无模板，点击右上角加号创建'
                              : '当前分类下暂无模板', // 如果选中了特定分类但过滤后为空
                          style: currentTheme.textTheme.titleMedium?.copyWith(
                            color: currentTheme.colorScheme.onSurface
                                .withAlpha(90),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(8), // 为 GridView 添加内边距
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0, // 使卡片保持正方形
                    ),
                    itemCount: _filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _filteredTemplates[index];
                      // return buildTemplateCard(template, currentTheme); // 传递主题数据
                      return TemplateCard(
                          template: template,
                          theme: currentTheme,
                          onRefresh: loadTemplates);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
