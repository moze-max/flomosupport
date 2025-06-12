import 'package:flomosupport/components/guide_card.dart';
import 'package:flomosupport/functions/class_items_notification.dart';
import 'package:flomosupport/pages/newguide.dart';
import 'package:flutter/material.dart';
import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class Guide extends StatefulWidget {
  const Guide({super.key, required this.scaffoldKey});
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  State<Guide> createState() => GuideState();
}

class GuideState extends State<Guide> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final classItemNotifier = Provider.of<ClassItemNotifier>(context);
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
                classItemNotifier.refreshAllData();
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
              itemCount:
                  classItemNotifier.uniqueClassItems.length + 1, // +1 用于“全部”选项
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 第一个选项是“全部”
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text('全部'), // "全部" 的本地化字符串
                      selected: classItemNotifier.selectedClassItem ==
                          null, // 如果 _selectedClassItem 为 null，则选中
                      onSelected: (selected) {
                        classItemNotifier.setSelectedClassItem(null);
                      },
                    ),
                  );
                } else {
                  final classItem = classItemNotifier
                      .uniqueClassItems[index - 1]; // 获取对应的 classItem
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(classItem),
                      selected: classItemNotifier.selectedClassItem ==
                          classItem, // 如果当前 classItem 匹配，则选中
                      onSelected: (selected) {
                        if (selected) {
                          classItemNotifier.setSelectedClassItem(classItem);
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: classItemNotifier.filteredTemplates.isEmpty
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
                          classItemNotifier.selectedClassItem == null &&
                                  classItemNotifier.allTemplates
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
                    itemCount: classItemNotifier.filteredTemplates.length,
                    itemBuilder: (context, index) {
                      final template =
                          classItemNotifier.filteredTemplates[index];
                      // return buildTemplateCard(template, currentTheme); // 传递主题数据
                      return TemplateCard(
                        template: template,
                        theme: currentTheme,
                        // onRefresh: loadTemplates
                        onRefresh: classItemNotifier.refreshAllData,
                      );
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
