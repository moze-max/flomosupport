import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flomosupport/models/guidemodel.dart';

class StorageService {
  static const String _appFolderName = 'flomosupport';
  static const String _templatesFileName = 'templates.json';
  static const String _classItemsFileName = 'class_items.json';
  static const String _imageDirName = 'template_images';
  static const String _avatarDirName = 'avatars';

  /// Private helper to get the File object for a given data filename
  static Future<File> _getFile(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory(path.join(directory.path, _appFolderName));
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return File(path.join(appDir.path, fileName));
  }

  /// Private helper to get the image storage directory
  static Future<Directory> _getImageDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirPath =
        path.join(directory.path, _appFolderName, _imageDirName);
    final Directory imageDir = Directory(imageDirPath);

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }
    return imageDir;
  }

  static Future<Directory> _getAvatarDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final avatarDirPath =
        path.join(directory.path, _appFolderName, _avatarDirName);
    final Directory avatarDir = Directory(avatarDirPath);
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
      }
    } catch (e) {
      developer.log('Error loading class items: $e');
    }
    // If file does not exist or error occurs, return a default list for initial setup
    developer
        .log('Class items file not found or error. Returning default list.');
    return ['生活', '工作', '学习']; // Default class items
  }

  /// Saves the class items to the local file, overwriting existing data.
  static Future<void> saveClassItems(List<String> classItems) async {
    try {
      final file = await _getFile(_classItemsFileName);
      final String jsonString = json.encode(classItems);
      await file.writeAsString(jsonString);
      developer.log("Class items saved to file: ${file.path}");
    } catch (e) {
      developer.log('Error saving class items: $e');
    }
  }

  // ==============================================
  // Image Operations
  // ==============================================

  /// Saves a picked image to the application's documents directory.
  /// Returns the new path of the saved image, or `null` if saving fails.
  static Future<String?> saveImageToFile(File pickedImage) async {
    try {
      final imageDir = await _getImageDirectory();
      final String newFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String newPath = path.join(imageDir.path, newFileName);

      final File newImage = await pickedImage.copy(newPath);
      developer.log("Image saved to: ${newImage.path}");
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
      final file = File(imagePath);
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
  //  Avatar Operations
  // ==============================================

  static const String _currentAvatarPathFileName = 'current_avatar_path.txt';

  /// Saves the user's avatar. Generates a unique filename using a timestamp.
  /// This ensures that even if the content changes, the path does, triggering
  /// UI refresh. It also stores the path to a text file for persistence.
  /// Returns the path to the saved avatar, or null if failed.
  static Future<String?> saveAvatar(File avatarFile) async {
    try {
      final avatarDir = await _getAvatarDirectory();
      // 生成唯一的头像文件名
      final String newAvatarFileName =
          '${DateTime.now().microsecondsSinceEpoch}.png';
      final String newAvatarPath = path.join(avatarDir.path, newAvatarFileName);

      // 复制文件到新路径
      final File newAvatar = await avatarFile.copy(newAvatarPath);
      developer.log("Avatar saved to: ${newAvatar.path}");

      // 记录新头像的路径到文件中
      final pathFile = await _getFile(_currentAvatarPathFileName);
      await pathFile.writeAsString(newAvatar.path);
      developer.log("Current avatar path saved to: ${pathFile.path}");

      // 删除旧头像文件（如果存在且不同于新头像）
      // 在保存新头像之前，先读取旧路径并删除旧文件，避免文件堆积
      final String? oldAvatarPath = await _readCurrentAvatarPath();
      if (oldAvatarPath != null && oldAvatarPath != newAvatar.path) {
        final oldAvatarFile = File(oldAvatarPath);
        if (await oldAvatarFile.exists()) {
          await oldAvatarFile.delete();
          developer.log("Deleted old avatar: $oldAvatarPath");
        }
      }
      await _cleanOldAvatars(newAvatar.path);
      return newAvatar.path;
    } catch (e) {
      developer.log("Error saving avatar: $e");
      return null;
    }
  }

  /// Loads the saved avatar image based on the path stored in a text file.
  /// Returns a [File] object of the avatar, or `null` if no avatar is found.
  static Future<File?> loadAvatar() async {
    try {
      final String? avatarPath = await _readCurrentAvatarPath();
      if (avatarPath != null && avatarPath.isNotEmpty) {
        final File avatarFile = File(avatarPath);
        if (await avatarFile.exists()) {
          developer.log("Avatar loaded from: ${avatarFile.path}");
          return avatarFile;
        } else {
          // 文件不存在，可能是被删除了，清除记录
          developer.log(
              "Avatar file not found at recorded path: $avatarPath. Clearing record.");
          await deleteAvatarPathRecord();
          return null;
        }
      }
      developer.log("No avatar path record found.");
      return null; // No avatar path found
    } catch (e) {
      developer.log("Error loading avatar: $e");
      return null;
    }
  }

  /// Deletes the saved avatar image and its path record.
  static Future<void> deleteAvatar() async {
    try {
      final String? avatarPath = await _readCurrentAvatarPath();
      if (avatarPath != null && avatarPath.isNotEmpty) {
        final File avatarFile = File(avatarPath);
        if (await avatarFile.exists()) {
          await avatarFile.delete();
          developer.log("Avatar image deleted from: $avatarPath");
        }
      }
      await deleteAvatarPathRecord(); // 删除路径记录文件
      developer.log("Avatar path record deleted.");
      await _cleanOldAvatars(null);
    } catch (e) {
      developer.log("Error deleting avatar: $e");
    }
  }

  /// Helper to read the current avatar path from a file.
  static Future<String?> _readCurrentAvatarPath() async {
    try {
      final pathFile = await _getFile(_currentAvatarPathFileName);
      if (await pathFile.exists()) {
        return await pathFile.readAsString();
      }
      return null;
    } catch (e) {
      developer.log("Error reading current avatar path: $e");
      return null;
    }
  }

  /// Helper to delete the current avatar path record file.
  static Future<void> deleteAvatarPathRecord() async {
    try {
      final pathFile = await _getFile(_currentAvatarPathFileName);
      if (await pathFile.exists()) {
        await pathFile.delete();
      }
    } catch (e) {
      developer.log("Error deleting avatar path record: $e");
    }
  }

  static Future<void> _cleanOldAvatars(String? currentAvatarPath) async {
    try {
      final avatarDir = await _getAvatarDirectory();
      if (!await avatarDir.exists()) {
        return; // 目录不存在，无需清理
      }

      final List<FileSystemEntity> files = avatarDir.listSync();
      for (final FileSystemEntity entity in files) {
        if (entity is File) {
          // 确保是文件，并且不是当前有效的头像文件路径
          if (currentAvatarPath == null || entity.path != currentAvatarPath) {
            await entity.delete();
            developer.log("Cleaned up old avatar file: ${entity.path}");
          }
        }
      }
    } catch (e) {
      developer.log("Error cleaning up old avatars: $e");
    }
  }
}
