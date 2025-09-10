// UserAvatarManager.dart

import 'package:flomosupport/functions/image_file_manager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flomosupport/functions/avatar_notifier.dart';
import 'dart:io';

class UserAvatarManager extends StatefulWidget {
  final double radius;
  final bool enableActions;
  const UserAvatarManager(
      {super.key, this.radius = 40, this.enableActions = true});

  @override
  State<UserAvatarManager> createState() => _UserAvatarManagerState();
}

class _UserAvatarManagerState extends State<UserAvatarManager> {
  /// 弹出底部操作表
  void _showAvatarActionSheet() {
    if (!widget.enableActions) {
      return;
    }
    final File? currentAvatar =
        Provider.of<AvatarNotifier>(context, listen: false).currentAvatar;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext sheetContext) {
        // 使用不同的变量名以避免混淆
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 1. 查看大图
              if (currentAvatar != null) // 仅在有头像时显示
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('查看大图'),
                  onTap: () {
                    // 先pop，再调用函数，确保使用外部的context
                    Navigator.of(sheetContext).pop();
                    viewLargeImage(
                        context, currentAvatar); // 调用公共函数，并传递正确的context
                  },
                ),
              // 2. 拍照
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  pickImage(context, ImageSource.camera);
                },
              ),
              // 3. 从相册选择
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  pickImage(context, ImageSource.gallery);
                },
              ),
              // 4. 删除头像
              if (currentAvatar != null) // 仅在有头像时显示
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title:
                      const Text('删除头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    deleteAvatarConfirmed(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AvatarNotifier>(builder: (context, avatarNotifier, child) {
      final File? avatar = avatarNotifier.currentAvatar;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showAvatarActionSheet(),
              child: CircleAvatar(
                radius: widget.radius,
                backgroundColor: Colors.grey[200],
                backgroundImage: avatar != null ? FileImage(avatar) : null,
                child: avatar == null
                    ? Icon(
                        Icons.person,
                        size: widget.radius * 1.5,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
            ),
          ],
        ),
      );
    });
  }
}
