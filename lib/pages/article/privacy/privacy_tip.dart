import 'package:flomosupport/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class PrivacyTip extends StatefulWidget {
  const PrivacyTip({super.key});

  @override
  State<PrivacyTip> createState() => _PrivacyTipState();
}

class _PrivacyTipState extends State<PrivacyTip> {
  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            appLocalizations.privacySettings,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                title: const Text('标题 1: 点击展开/收起'), // 标题
                subtitle: const Text('这是标题的副标题'), // 可选的副标题
                leading: const Icon(Icons.info), // 可选的引导图标
                trailing: const Icon(Icons.arrow_drop_down), // 可选的尾部图标，默认就是箭头
                onExpansionChanged: (bool expanded) {
                  // 当展开/收起状态改变时回调
                  debugPrint('面板 1 展开状态：$expanded');
                },
                children: const <Widget>[
                  // 这里是展开后显示的内容
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '这是面板 1 的正文内容。你可以放置任何 Widget 在这里，例如图片、更多的文本、列表等。'
                      '内容可以很长，当它展开时会占用更多空间。'
                      'ExpansionTile 是一个非常方便的 Widget，它自动处理了展开/收起的逻辑和动画。',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // 示例 2: 另一个 ExpansionTile，有不同的样式和内容
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              color: Colors.blue.shade50, // 背景色
              child: ExpansionTile(
                title: const Text(
                  '标题 2: 更多内容',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                leading: const Icon(Icons.article, color: Colors.blue),
                collapsedIconColor: Colors.grey, // 收起时的图标颜色
                iconColor: Colors.blue, // 展开时的图标颜色
                children: <Widget>[
                  // 可以放置多个子 Widget
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(child: Text('这是一个列表项。')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      '第二段内容，可以用来放置更详细的信息，例如 FAQ 或说明书。',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                  ListTile(
                    title: const Text('子项功能 1'),
                    onTap: () {
                      debugPrint('点击了子项功能 1');
                    },
                  ),
                ],
              ),
            ),

            // 示例 3: 默认展开的面板 (initiallyExpanded)
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                title: const Text('标题 3: 默认展开'),
                initiallyExpanded: true, // 默认就是展开状态
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      '这个面板在加载时就会自动展开。你可以根据需求设置这个属性。',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
