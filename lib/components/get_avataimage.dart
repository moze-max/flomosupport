import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart'; // ⭐ 导入 Provider
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
  final ImagePicker _picker = ImagePicker();

  // @override
  // void initState() {
  //   super.initState();
  // }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (mounted) {
        if (Theme.of(context).platform == TargetPlatform.windows ||
            Theme.of(context).platform == TargetPlatform.macOS ||
            Theme.of(context).platform == TargetPlatform.linux) {
          final File originalImageFile = File(pickedFile.path);
          Provider.of<AvatarNotifier>(context, listen: false)
              .updateAvatar(originalImageFile);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('PC平台暂不支持图片裁剪,已使用原图。')),
            );
          }
          if (!mounted) return;
          Navigator.pop(context);
        } else {
          _cropImage(File(pickedFile.path));
        }
      }
    }
  }

  Future<void> _cropImage(File imageFile) async {
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
            // Changed to const
            CropAspectRatioPreset.square,
          ],
          doneButtonTitle: '完成',
          cancelButtonTitle: '取消',
        ),
      ],
    );

    if (croppedFile != null) {
      final File finalImageFile = File(croppedFile.path);
      if (!mounted) return;
      Provider.of<AvatarNotifier>(context, listen: false)
          .updateAvatar(finalImageFile);
    }
  }

  Future<void> _deleteAvatarConfirmed() async {
    Provider.of<AvatarNotifier>(context, listen: false).deleteAvatar();
  }

  void _showAvatarActionSheet(BuildContext context) {
    if (!widget.enableActions) {
      return;
    }
    final File? currentAvatar =
        Provider.of<AvatarNotifier>(context, listen: false).currentAvatar;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 1. 查看大图
              if (currentAvatar != null) // Only show if an avatar exists
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('查看大图'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _viewLargeImage(context, currentAvatar);
                  },
                ),
              // 2. 拍照
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              // 3. 从相册选择
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              // 4. Delete Avatar
              if (currentAvatar != null) // Only show if an avatar exists
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title:
                      const Text('删除头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteAvatarConfirmed();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _viewLargeImage(BuildContext context, File imageFile) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AvatarNotifier>(builder: (context, avatarNotifier, child) {
      final File? avatar = avatarNotifier.currentAvatar;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => _showAvatarActionSheet(context),
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
