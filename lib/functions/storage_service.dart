// flomosupport/functions/storage_service.dart
import 'dart:convert';
import 'dart:io'
    as io; // Alias dart:io to avoid conflict with file package's File
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flomosupport/models/guidemodel.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';

class StorageService {
  static const String _appFolderName = 'flomosupport';
  static const String _templatesFileName = 'templates.json';
  static const String _classItemsFileName = 'class_items.json';
  static const String _imageDirName = 'template_images';
  static const String _avatarDirName = 'avatars';
  static const String _userinfoFileName = 'userinfo.json';

  // 1. 添加一个静态 FileSystem 实例，默认为 LocalFileSystem
  static FileSystem _fileSystem = const LocalFileSystem();

  // 2. 添加一个方法用于在测试中注入 FileSystem
  static void setFileSystem(FileSystem fs) {
    _fileSystem = fs;
  }

  /// Private helper to get the File object for a given data filename
  static Future<File> _getFile(String fileName) async {
    developer.log('_GET_FILE: Starting _getFile for $fileName');
    try {
      developer.log('_GET_FILE: Calling getApplicationDocumentsDirectory()');
      final directory = await getApplicationDocumentsDirectory();
      developer.log(
          '_GET_FILE: Got application documents directory: ${directory.path}');

      final appDir =
          _fileSystem.directory(path.join(directory.path, _appFolderName));
      developer
          .log('_GET_FILE: Checking if app directory exists: ${appDir.path}');

      bool exists = false;
      try {
        // 为 exists() 检查添加超时，5秒后如果还没返回，则认为不存在或不可访问
        exists = await appDir.exists().timeout(const Duration(seconds: 5),
            onTimeout: () {
          developer.log(
              '_GET_FILE: appDir.exists() timed out. Assuming directory does not exist or is inaccessible.');
          return false; // 超时则假定目录不存在或无法访问
        });
      } on Exception catch (e) {
        developer.log(
            '_GET_FILE: Error during appDir.exists() check: $e. Assuming directory does not exist.');
        exists = false; // 任何错误也当作不存在处理
      }

      if (!exists) {
        developer.log(
            '_GET_FILE: App directory does not exist or was inaccessible. Creating recursively.');
        try {
          // 为 create() 调用也添加超时
          await appDir
              .create(recursive: true)
              .timeout(const Duration(seconds: 5), onTimeout: () {
            developer.log('_GET_FILE: appDir.create() timed out.');
            throw Exception(
                'Failed to create app directory: Timeout'); // 如果创建超时，则抛出异常
          });
          developer.log('_GET_FILE: App directory created.');
        } on Exception catch (e) {
          developer.log('_GET_FILE: Error creating app directory: $e');
          rethrow; // 重新抛出创建过程中的任何错误
        }
      } else {
        developer.log('_GET_FILE: App directory already exists.');
      }
      developer.log('_GET_FILE: Returning File object for $fileName.');
      return _fileSystem.file(path.join(appDir.path, fileName));
    } catch (e) {
      developer.log('_GET_FILE: Final Error in _getFile: $e');
      rethrow;
    }
  }

  /// Private helper to get the image storage directory
  static Future<Directory> _getImageDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirPath =
        path.join(directory.path, _appFolderName, _imageDirName);
    // 3. 使用 _fileSystem 创建 Directory 对象
    final Directory imageDir = _fileSystem.directory(imageDirPath);

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  static Future<Directory> _getAvatarDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarDirPath =
        path.join(directory.path, _appFolderName, _avatarDirName);
    // 3. 使用 _fileSystem 创建 Directory 对象
    final Directory avatarDir = _fileSystem.directory(avatarDirPath);
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    return avatarDir;
  }

  // ==============================================
  // Template (Guide Model) Operations
  // ==============================================

  /// Reads all templates from the local file.
  /// Returns a list of Template objects, or an empty list if file does not exist, is empty, or on error.
  static Future<List<Template>> loadTemplates() async {
    final file = await _getFile(_templatesFileName);
    if (!await file.exists()) {
      developer.log("Templates file does not exist. Returning empty list.");
      return [];
    }
    try {
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        developer.log("Templates file is empty. Returning empty list.");
        return [];
      }
      List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Template.fromJson(json)).toList();
    } catch (e) {
      developer.log("Error reading or decoding templates file: $e");
      return []; // Return empty list on error to prevent crashes
    }
  }

  /// Saves the given list of Template objects to the local file, overwriting existing data.
  static Future<void> saveTemplates(List<Template> templates) async {
    final file = await _getFile(_templatesFileName);
    try {
      final String jsonString =
          json.encode(templates.map((template) => template.toJson()).toList());
      await file.writeAsString(jsonString);
      developer.log("Templates saved to file: ${file.path}");
    } catch (e) {
      developer.log("Error saving templates to file: $e");
    }
  }

  /// Deletes a specific template from local storage and its associated image if present.
  /// Returns `true` if the template was successfully deleted, `false` otherwise.
  static Future<bool> deleteTemplate(String templateId) async {
    // Changed to use ID directly
    try {
      List<Template> templatesList =
          await loadTemplates(); // Use unified loadTemplates

      final int initialLength = templatesList.length;
      Template? deletedTemplate;

      // Find and remove the template
      templatesList.removeWhere((t) {
        if (t.id == templateId) {
          deletedTemplate = t;
          return true;
        }
        return false;
      });

      if (templatesList.length == initialLength) {
        // Template not found
        developer.log("Template with ID '$templateId' not found for deletion.");
        return false;
      }

      // Delete associated image if exists
      if (deletedTemplate?.imagePath != null &&
          deletedTemplate!.imagePath!.isNotEmpty) {
        await deleteImageFile(deletedTemplate!.imagePath!);
      }

      await saveTemplates(templatesList); // Use unified saveTemplates
      developer.log(
          "Template (ID: $templateId) deleted successfully from local storage.");
      return true;
    } catch (e) {
      developer.log("Error deleting template locally: $e");
      return false;
    }
  }

  // ==============================================
  // Class Item Operations
  // ==============================================

  /// Reads the class items from the local file.
  /// Returns a list of String objects.
  /// Returns a default list if the file does not exist or is empty.
  static Future<List<String>> loadClassItems() async {
    try {
      final file = await _getFile(_classItemsFileName);
      if (await file.exists()) {
        final contents = await file.readAsString();
        if (contents.isEmpty) {
          developer.log("Class items file is empty. Returning empty list.");
          return [];
        }
        final List<dynamic> jsonList = json.decode(contents) as List;
        return jsonList.map((e) => e.toString()).toList();
      } else {
        developer.log(
            'Class items file not found. Returning and saving default list.');
        final defaultItems = ['生活', '工作', '学习'];
        await saveClassItems(defaultItems);
        return defaultItems;
      }
    } catch (e) {
      developer.log('Error loading class items: $e');
      return ['生活', '工作', '学习'];
    }
  }

  /// Saves the class items to the local file, overwriting existing data.
  // static Future<void> saveClassItems(List<String> classItems) async {
  //   try {
  //     final file = await _getFile(_classItemsFileName);
  //     final String jsonString = json.encode(classItems);
  //     await file.writeAsString(jsonString);
  //     developer.log("Class items saved to file: ${file.path}");
  //   } catch (e) {
  //     developer.log('Error saving class items: $e');
  //   }
  // }
  static Future<void> saveClassItems(List<String> classItems) async {
    try {
      final file = await _getFile(_classItemsFileName);
      final String jsonString = json.encode(classItems);
      await file.writeAsString(jsonString); // 冻结可能发生在这里

      developer
          .log('SAVE CLASS ITEMS: Class items saved successfully.'); // 调试点 7
    } catch (e) {
      developer.log('SAVE CLASS ITEMS: Error saving class items: $e'); // 调试点 8
      rethrow; // 重新抛出错误，以便调用者可以处理
    }
  }

  // ==============================================
  // Image Operations
  // ==============================================

  /// Saves a picked image to the application's documents directory.
  /// Returns the new path of the saved image, or `null` if saving fails.
  static Future<String?> saveImageToFile(io.File pickedImage) async {
    // Accepts dart:io.File
    try {
      final imageDir = await _getImageDirectory();
      final String newFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String newPath = path.join(imageDir.path, newFileName);

      // 4. 使用 _fileSystem 来创建新的文件，但复制内容来自 dart:io.File
      final File newImage = _fileSystem.file(newPath);
      await newImage
          .writeAsBytes(await pickedImage.readAsBytes()); // Copy content
      return newImage.path;
    } catch (e) {
      developer.log("Error saving image to local storage: $e");
      return null;
    }
  }

  /// Deletes an image file by its path.
  static Future<void> deleteImageFile(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      // 5. 使用 _fileSystem 获取 File 实例
      final file = _fileSystem.file(imagePath);
      if (await file.exists()) {
        await file.delete();
        developer.log("Image deleted: $imagePath");
      } else {
        developer.log("Image file not found for deletion: $imagePath");
      }
    } catch (e) {
      developer.log("Error deleting image file: $e");
    }
  }

  // ==============================================
  // User Info & Avatar Operations
  // ==============================================

  /// Private helper to read and parse the user info JSON file.
  static Future<Map<String, dynamic>> _readUserInfo() async {
    final file = await _getFile(_userinfoFileName);
    if (!await file.exists()) {
      return {};
    }
    try {
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return {};
      }
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      developer.log("Error reading or decoding user info file: $e");
      return {};
    }
  }

  /// Private helper to write user info to the JSON file.
  static Future<void> _writeUserInfo(Map<String, dynamic> userInfo) async {
    final file = await _getFile(_userinfoFileName);
    try {
      final String jsonString = json.encode(userInfo);
      await file.writeAsString(jsonString);
    } catch (e) {
      developer.log("Error writing user info file: $e");
    }
  }

  /// Saves the user's avatar path to the user info file.
  static Future<String?> saveAvatar(io.File avatarFile) async {
    try {
      final avatarDir = await _getAvatarDirectory();
      final String newAvatarFileName =
          '${DateTime.now().microsecondsSinceEpoch}.png';
      final String newAvatarPath = path.join(avatarDir.path, newAvatarFileName);

      final File newAvatar = _fileSystem.file(newAvatarPath);
      await newAvatar.writeAsBytes(await avatarFile.readAsBytes());

      // 读取当前的用户信息，更新头像路径并写入
      final userInfo = await _readUserInfo();
      final oldAvatarPath = userInfo['avatarPath'] as String?;

      // 清理旧头像文件
      if (oldAvatarPath != null && oldAvatarPath.isNotEmpty) {
        await _cleanUpFile(oldAvatarPath);
      }

      userInfo['avatarPath'] = newAvatar.path;
      await _writeUserInfo(userInfo);

      return newAvatar.path;
    } catch (e) {
      developer.log("Error saving avatar: $e");
      return null;
    }
  }

  /// Loads the saved avatar image based on the path stored in the user info file.
  static Future<io.File?> loadAvatar() async {
    try {
      final userInfo = await _readUserInfo();
      final String? avatarPath = userInfo['avatarPath'] as String?;

      if (avatarPath != null && avatarPath.isNotEmpty) {
        final File avatarFileInMem = _fileSystem.file(avatarPath);
        if (await avatarFileInMem.exists()) {
          developer.log("Avatar loaded from: ${avatarFileInMem.path}");
          final tempIoFile = io.File(avatarFileInMem.path);
          await tempIoFile.writeAsBytes(await avatarFileInMem.readAsBytes());
          return tempIoFile;
        } else {
          developer.log(
              "Avatar file not found at recorded path: $avatarPath. Clearing record.");
          // 如果文件不存在，清理记录
          userInfo.remove('avatarPath');
          await _writeUserInfo(userInfo);
          return null;
        }
      }
      developer.log("No avatar path record found.");
      return null;
    } catch (e) {
      developer.log("Error loading avatar: $e");
      return null;
    }
  }

  /// Deletes the saved avatar image and its path record from the user info file.
  static Future<void> deleteAvatar() async {
    try {
      final userInfo = await _readUserInfo();
      final String? avatarPath = userInfo['avatarPath'] as String?;

      if (avatarPath != null && avatarPath.isNotEmpty) {
        await _cleanUpFile(avatarPath);
      }

      userInfo.remove('avatarPath');
      await _writeUserInfo(userInfo);

      developer.log("Avatar image and record deleted.");
    } catch (e) {
      developer.log("Error deleting avatar: $e");
    }
  }

  /// Saves the user's nickname to the user info file.
  static Future<void> saveNickname(String nickname) async {
    try {
      final userInfo = await _readUserInfo();
      userInfo['nickname'] = nickname;
      await _writeUserInfo(userInfo);
      developer.log("Nickname saved: $nickname");
    } catch (e) {
      developer.log("Error saving nickname: $e");
    }
  }

  /// Loads the user's nickname from the user info file.
  static Future<String?> loadNickname() async {
    try {
      final userInfo = await _readUserInfo();
      return userInfo['nickname'] as String?;
    } catch (e) {
      developer.log("Error loading nickname: $e");
      return null;
    }
  }

  // ==============================================
  //  Utility Functions
  // ==============================================

  /// Helper to clean up a file at a given path.
  static Future<void> _cleanUpFile(String filePath) async {
    try {
      final file = _fileSystem.file(filePath);
      if (await file.exists()) {
        await file.delete();
        developer.log("File deleted: $filePath");
      }
    } catch (e) {
      developer.log("Error cleaning up file: $e");
    }
  }

  // static Future<void> _cleanOldAvatars(String? currentAvatarPath) async {
  //   try {
  //     final avatarDir = await _getAvatarDirectory();
  //     if (!await avatarDir.exists()) {
  //       return;
  //     }

  //     final List<FileSystemEntity> files = avatarDir.listSync();
  //     for (final FileSystemEntity entity in files) {
  //       if (entity is File) {
  //         if (currentAvatarPath == null || entity.path != currentAvatarPath) {
  //           await entity.delete();
  //           developer.log("Cleaned up old avatar file: ${entity.path}");
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     developer.log("Error cleaning up old avatars: $e");
  //   }
  // }
}
