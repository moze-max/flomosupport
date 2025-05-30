import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;

class UserAvatarManager extends StatefulWidget {
  final double radius;
  final bool enableActions;
  const UserAvatarManager(
      {super.key, this.radius = 40, this.enableActions = true});

  @override
  State<UserAvatarManager> createState() => _UserAvatarManagerState();
}

class _UserAvatarManagerState extends State<UserAvatarManager> {
  File? _pickedImage; // 用于存储选择或裁剪后的图片文件
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar(); // 尝试加载本地保存的头像
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      _cropImage(File(pickedFile.path)); // 立即进入裁剪阶段
    }
  }

  Future<void> _cropImage(File imageFile) async {
    if (Theme.of(context).platform == TargetPlatform.windows) {
      setState(() {
        _pickedImage = imageFile; // 直接使用原始图片，不裁剪
      });
      await _saveAvatarLocally(imageFile); // 即使未裁剪也保存
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Windows 平台暂不支持图片裁剪，已使用原图。')),
        );
      }

      return; // 提前返回
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪头像',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: '裁剪头像',
          aspectRatioLockEnabled: true,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          doneButtonTitle: '完成',
          cancelButtonTitle: '取消',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _pickedImage = File(croppedFile.path); // 更新为裁剪后的图片
      });
      await _saveAvatarLocally(_pickedImage!); // 保存头像
    }
  }

  Future<void> _saveAvatarLocally(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir =
          Directory(path.join(appDir.path, 'flomosupport', 'avatars'));
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }
      final String fileName = 'user_avatar.png'; // 固定文件名或使用用户ID
      final String filePath = path.join(avatarsDir.path, fileName);

      await imageFile.copy(filePath);
      developer.log('头像已保存到: $filePath');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像保存成功！')),
        );
      }
    } catch (e) {
      developer.log('保存头像失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像保存失败！')),
        );
      }
    }
  }

  Future<void> _loadSavedAvatar() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir =
          Directory(path.join(appDir.path, 'flomosupport', 'avatars'));
      final String fileName = 'user_avatar.png';
      final String filePath = path.join(avatarsDir.path, fileName);
      final File savedFile = File(filePath);

      if (await savedFile.exists()) {
        setState(() {
          _pickedImage = savedFile;
        });
        developer.log('已加载本地头像: $filePath');
      }
    } catch (e) {
      developer.log('加载本地头像失败: $e');
    }
  }

  // 修改：显示操作弹窗，包含查看大图、拍照、从相册选择
  void _showAvatarActionSheet(BuildContext context) {
    if (!widget.enableActions) {
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 1. 查看大图
              if (_pickedImage != null) // 只有当有头像时才显示查看大图
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('查看大图'),
                  onTap: () {
                    Navigator.of(context).pop(); // 关闭底部弹窗
                    _viewLargeImage(context, _pickedImage!); // 跳转到查看大图页面
                  },
                ),
              // 2. 拍照
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop(); // 关闭底部弹窗
                  _pickImage(ImageSource.camera);
                },
              ),
              // 3. 从相册选择
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(context).pop(); // 关闭底部弹窗
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // 新增：查看大图的函数
  void _viewLargeImage(BuildContext context, File imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black, // 全屏查看通常背景为黑色
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white), // 返回按钮为白色
            title: const Text('头像大图', style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: InteractiveViewer(
              // 允许缩放和平移
              panEnabled: true, // 允许平移
              minScale: 0.5,
              maxScale: 4,
              child: Image.file(imageFile),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 将 CircleAvatar 包裹在 GestureDetector 中使其可点击
          GestureDetector(
            onTap: () => _showAvatarActionSheet(context), // 点击时显示操作弹窗
            child: CircleAvatar(
              radius: widget.radius, // 可以调整头像大小
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _pickedImage != null ? FileImage(_pickedImage!) : null,
              child: _pickedImage == null
                  ? Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
