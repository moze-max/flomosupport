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

  // Helper to get the base avatar directory
  Future<String> _getAvatarBaseDirPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarsDir =
        Directory(path.join(appDir.path, 'flomosupport', 'avatars'));
    if (!await avatarsDir.exists()) {
      await avatarsDir.create(recursive: true);
    }
    return avatarsDir.path;
  }

  Future<File?> _getCurrentAvatarFile() async {
    try {
      final baseDirPath = await _getAvatarBaseDirPath();
      final avatarsDir = Directory(baseDirPath);
      if (!await avatarsDir.exists()) return null;

      // List all files in the directory and find the latest one
      final files = avatarsDir.listSync().whereType<File>().toList();
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      if (files.isNotEmpty) {
        return files.first;
      }
    } catch (e) {
      developer.log('Error getting current avatar file: $e');
    }
    return null;
  }

  // Helper to delete ALL previous avatar files
  Future<void> _deleteAllOldAvatars() async {
    try {
      final baseDirPath = await _getAvatarBaseDirPath();
      final avatarsDir = Directory(baseDirPath);
      if (await avatarsDir.exists()) {
        final files = avatarsDir.listSync().whereType<File>().toList();
        for (var file in files) {
          if (path.basename(file.path).startsWith('user_avatar_') &&
              path.extension(file.path) == '.png') {
            await file.delete();
            developer.log('Deleted old avatar file: ${file.path}');
          }
        }
      }
    } catch (e) {
      developer.log('Error deleting old avatars: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (mounted) {
        if (Theme.of(context).platform == TargetPlatform.windows) {
          final File originalImageFile = File(pickedFile.path);
          await _saveAvatarLocally(originalImageFile); // Save the image
          if (mounted) {
            // No need for imgKey = UniqueKey(); here anymore
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Windows 平台暂不支持图片裁剪，已使用原图。')),
            );
          }
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
            // Changed to const
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
      await _saveAvatarLocally(finalImageFile);
    }
  }

  Future<void> _saveAvatarLocally(File imageFile) async {
    try {
      await _deleteAllOldAvatars(); // Delete all previous avatar files

      final baseDirPath = await _getAvatarBaseDirPath();
      final String newFileName =
          'user_avatar_${DateTime.now().microsecondsSinceEpoch}.png'; // Unique filename
      final String newFilePath = path.join(baseDirPath, newFileName);

      await imageFile.copy(newFilePath);
      developer.log('新头像已保存到: $newFilePath');

      if (mounted) {
        setState(() {
          _pickedImage =
              File(newFilePath); // Update _pickedImage with the new path
        });
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
      final File? latestAvatar = await _getCurrentAvatarFile();

      if (latestAvatar != null && await latestAvatar.exists()) {
        setState(() {
          _pickedImage = latestAvatar;
        });
        developer.log('已加载本地头像: ${latestAvatar.path}');
      } else {
        developer.log('本地头像文件不存在或未找到最新头像。');
        setState(() {
          _pickedImage = null; // Ensure avatar displays null if no file found
        });
      }
    } catch (e) {
      developer.log('加载本地头像失败: $e');
    }
  }

  // Added: Delete Avatar functionality
  Future<void> _deleteAvatar() async {
    try {
      await _deleteAllOldAvatars(); // Delete all existing avatar files
      setState(() {
        _pickedImage = null; // Set to null immediately
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('头像已删除！')),
        );
      }
      developer.log('头像已删除。');
    } catch (e) {
      developer.log('删除头像失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除头像失败！')),
        );
      }
    }
  }

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
              if (_pickedImage != null) // Only show if an avatar exists
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('查看大图'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _viewLargeImage(context, _pickedImage!);
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
              if (_pickedImage != null) // Only show if an avatar exists
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title:
                      const Text('删除头像', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteAvatar();
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showAvatarActionSheet(context),
            child: CircleAvatar(
              radius: widget.radius,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  _pickedImage != null ? FileImage(_pickedImage!) : null,
              child: _pickedImage == null
                  ? Icon(
                      Icons.person,
                      size: widget.radius * 1.5, // Icon size scales with radius
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
