// image_file_manager.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:flomosupport/functions/avatar_notifier.dart';
import 'dart:io';

/// 用于选择图片的实例
final ImagePicker _picker = ImagePicker();

/// 处理图片选择的业务逻辑
Future<void> pickImage(BuildContext context, ImageSource source) async {
  final XFile? pickedFile = await _picker.pickImage(source: source);

  // 确保在异步操作后，context仍然有效
  if (!context.mounted) return;

  if (pickedFile != null) {
    if (Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux) {
      // PC平台处理逻辑
      final File originalImageFile = File(pickedFile.path);
      Provider.of<AvatarNotifier>(context, listen: false)
          .updateAvatar(originalImageFile);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('PC平台暂不支持图片裁剪,已使用原图。')),
      // );
    } else {
      // 移动端处理逻辑，进行裁剪
      await cropImage(context, File(pickedFile.path));
    }
  }
}

/// 处理图片裁剪的业务逻辑
Future<void> cropImage(BuildContext context, File imageFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: '裁剪头像',
        toolbarColor: Theme.of(context).primaryColor,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.square,
        lockAspectRatio: true,
        aspectRatioPresets: const [
          CropAspectRatioPreset.square,
        ],
        hideBottomControls: false,
      ),
      IOSUiSettings(
        title: '裁剪头像',
        aspectRatioLockEnabled: true,
        aspectRatioPresets: const [
          CropAspectRatioPreset.square,
        ],
        doneButtonTitle: '完成',
        cancelButtonTitle: '取消',
      ),
    ],
  );

  if (croppedFile != null) {
    final File finalImageFile = File(croppedFile.path);
    // 确保在异步操作后，context仍然有效
    if (!context.mounted) return;
    Provider.of<AvatarNotifier>(context, listen: false)
        .updateAvatar(finalImageFile);
  }
}

/// 处理删除头像的业务逻辑
void deleteAvatarConfirmed(BuildContext context) {
  Provider.of<AvatarNotifier>(context, listen: false).deleteAvatar();
}

/// 处理查看大图的业务逻辑
void viewLargeImage(BuildContext context, File imageFile) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text('头像大图', style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4,
            child: Image.file(
              imageFile,
            ),
          ),
        ),
      ),
    ),
  );
}
