import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class UserAvatarManager extends StatefulWidget {
  const UserAvatarManager({super.key});

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Windows 平台暂不支持图片裁剪，已使用原图。')),
      );
      _saveAvatarLocally(imageFile); // 即使未裁剪也保存
      return; // 提前返回
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '裁剪头像',
          toolbarColor: Theme.of(context).primaryColor, // 使用应用主题色
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          aspectRatioPresets: [
            // 再次强调：这里才是 Android 的 aspectRatioPresets
            CropAspectRatioPreset.square,
          ],
          hideBottomControls: false, // 显示底部控制条
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
      _saveAvatarLocally(_pickedImage!); // 保存头像
    }
  }

  Future<void> _saveAvatarLocally(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory(path.join(appDir.path, 'avatars'));
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }
      final String fileName = 'user_avatar.png'; // 固定文件名或使用用户ID
      final String filePath = path.join(avatarsDir.path, fileName);

      await imageFile.copy(filePath);
      print('头像已保存到: $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像保存成功！')),
      );
    } catch (e) {
      print('保存头像失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像保存失败！')),
      );
    }
  }

  Future<void> _loadSavedAvatar() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory(path.join(appDir.path, 'avatars'));
      final String fileName = 'user_avatar.png';
      final String filePath = path.join(avatarsDir.path, fileName);
      final File savedFile = File(filePath);

      if (await savedFile.exists()) {
        setState(() {
          _pickedImage = savedFile;
        });
        print('已加载本地头像: $filePath');
      }
    } catch (e) {
      print('加载本地头像失败: $e');
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 80, // 可以调整头像大小
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
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => _showImageSourceActionSheet(context),
            icon: const Icon(Icons.edit),
            label: const Text('更改头像'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
