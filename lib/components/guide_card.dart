import 'dart:io';
import 'package:flomosupport/functions/handle_delete_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import 'package:flomosupport/models/guidemodel.dart';
import 'package:flomosupport/pages/currentguide.dart';

// 定义一个回调类型，用于通知父组件模板已删除
typedef OnTemplateAction = Future<void> Function(Template template);
typedef OnTemplateRefresh = Future<void> Function(); // 用于通知父组件刷新列表

class TemplateCard extends StatelessWidget {
  final Template template;
  final ThemeData theme;
  final OnTemplateRefresh onRefresh; // 刷新回调 (当从 Currentguide 返回时)

  const TemplateCard({
    super.key,
    required this.template,
    required this.theme,
    required this.onRefresh,
  });

  // 显示上下文菜单的函数
  void _showContextMenu(BuildContext context, Offset globalPosition) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          value: 'edit',
          child:
              Text('编辑', style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
        PopupMenuItem(
          value: 'share',
          child:
              Text('分享', style: TextStyle(color: theme.colorScheme.onSurface)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text('删除', style: TextStyle(color: theme.colorScheme.error)),
        ),
      ],
      elevation: 8.0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ).then((value) async {
      if (value != null) {
        if (value == 'edit') {
        } else if (value == 'delete') {
          if (!context.mounted) {
            return;
          }
          await handleDeleteTemplateLogic(
              context: context, templateToDelete: template);
          onRefresh();
        }
      } else {
        developer.log('guide_card:长按按钮value为null!请进行检查');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        if (kIsWeb ||
            Platform.isWindows ||
            Platform.isMacOS ||
            Platform.isLinux) {
          _showContextMenu(context, details.globalPosition);
        }
      },
      child: InkWell(
        onTap: () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => Currentguide(template: template),
            ),
          );
          if (refresh == true) {
            onRefresh();
          }
        },
        onLongPress: () {
          final Offset cardCenter = (context.findRenderObject() as RenderBox)
              .localToGlobal((context.findRenderObject() as RenderBox)
                  .size
                  .center(Offset.zero));
          _showContextMenu(context, cardCenter);
        },
        child: Card(
          elevation: 4,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: template.imagePath != null &&
                        template.imagePath!.isNotEmpty
                    ? FutureBuilder<bool>(
                        future: File(template.imagePath!).exists(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data == true) {
                            return Image.file(
                              File(template.imagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                developer.log(
                                    '图片加载失败: ${template.imagePath}, 错误: $error');
                                return Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
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
                            return Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Center(
                                child: Icon(
                                  Icons.article,
                                  color: theme.colorScheme.onPrimaryContainer,
                                  size: 64,
                                ),
                              ),
                            );
                          }
                        },
                      )
                    : Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Center(
                          child: Icon(
                            Icons.article,
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
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
