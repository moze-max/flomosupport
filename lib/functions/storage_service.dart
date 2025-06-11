import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:flomosupport/models/guidemodel.dart';
// You'll also need to import flutter/material.dart if _showSnackbar is called directly in StorageService
// However, it's better to return the result and let the UI handle the snackbar.

class StorageService {
  /// Retrieves the path to the templates file.
  static Future<File> getTemplatesFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dirPath = path.join(directory.path, 'flomosupport');
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        await dir.create(recursive: true);
      }
      return File(path.join(dirPath, 'templates.json'));
    } catch (e) {
      // 可记录日志或抛出错误
      throw Exception('Failed to get templates file: $e');
    }
  }

  /// Reads the templates from the local file.
  /// Returns a list of Template objects.
  /// Returns an empty list if the file does not exist or is empty.
  static Future<List<Template>> readTemplatesFromFile() async {
    final file = await getTemplatesFile();
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

  Future<List<Template>> loadTemplates() async {
    try {
      final file = await getTemplatesFile();
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents) as List;
        return jsonList.map((json) => Template.fromJson(json)).toList();
      }
    } catch (e) {
      developer.log('Error loading templates: $e');
      // 可以在这里集成 showSnackbar 或其他错误处理
    }
    return []; // 如果文件不存在或发生错误，返回空列表
  }

  /// Writes the given list of Template objects back to the local file.
  static Future<void> writeTemplatesToFile(List<Template> templates) async {
    final file = await getTemplatesFile();
    final List<Map<String, dynamic>> jsonList =
        templates.map((template) => template.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
    developer.log("Templates written successfully to local storage.");
  }

  /// Deletes a specific template from local storage and its associated image if present.
  /// Returns `true` if the template was successfully deleted (and image if applicable), `false` otherwise.
  static Future<bool> deleteTemplate(Template templateToDelete) async {
    try {
      List<Template> templatesList = await readTemplatesFromFile();

      Template? foundTemplate;
      int? foundIndex;
      for (int i = 0; i < templatesList.length; i++) {
        if (templatesList[i].id == templateToDelete.id) {
          foundTemplate = templatesList[i];
          foundIndex = i;
          break;
        }
      }

      if (foundTemplate == null) {
        developer.log(
            "Template with ID '${templateToDelete.id}' not found for deletion.");
        return false;
      }

      if (foundIndex != null) {
        templatesList.removeAt(foundIndex);
      } else {
        templatesList.removeWhere((t) => t.id == templateToDelete.id);
      }

      if (foundTemplate.imagePath != null &&
          foundTemplate.imagePath!.isNotEmpty) {
        final imageFile = File(foundTemplate.imagePath!);
        if (await imageFile.exists()) {
          try {
            await imageFile.delete();
            developer.log(
                "Associated image file deleted: ${foundTemplate.imagePath}");
          } catch (e) {
            developer.log(
                "Error deleting associated image file ${foundTemplate.imagePath}: $e");
          }
        } else {
          developer.log(
              "Associated image file not found: ${foundTemplate.imagePath}");
        }
      }

      await writeTemplatesToFile(templatesList);
      developer.log(
          "Template '${foundTemplate.name}' (ID: ${foundTemplate.id}) deleted successfully from local storage.");
      return true;
    } catch (e) {
      developer.log("Error deleting template locally: $e");
      return false;
    }
  }

  /// Saves a new template to local storage.
  ///
  /// Returns the newly created [Template] object if successful, otherwise `null`.
  /// This method handles image saving and updates the templates file.
  static Future<Template?> saveNewTemplate(
      {required String name,
      required List<String> items,
      File? pickedImage,
      List<String>? classitems}) async {
    String? imagePath;
    if (pickedImage != null) {
      try {
        imagePath = await saveImageToFile(pickedImage);
        if (imagePath == null) {
          developer.log("Failed to save template image.");
          return null; // Indicate failure if image saving fails
        }
      } catch (e) {
        developer.log("Error saving cover image for template: $e");
        return null; // Indicate failure if image saving throws an error
      }
    }

    final newTemplate = Template.create(
        name: name.trim(),
        items: List<String>.from(items),
        imagePath: imagePath,
        classitems: classitems);

    try {
      List<Template> currentTemplates = await readTemplatesFromFile();
      currentTemplates.add(newTemplate);
      await writeTemplatesToFile(currentTemplates);
      developer.log("Template '${newTemplate.name}' saved successfully.");
      return newTemplate;
    } catch (e) {
      developer.log("Error saving template to file: $e");
      return null; // Indicate failure if template saving fails
    }
  }

  /// Saves a picked image to the application's documents directory.
  /// Returns the new path of the saved image, or `null` if saving fails.
  static Future<String?> saveImageToFile(File pickedImage) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      const String imageDirName =
          'template_images'; // Define a consistent image directory name
      final String imageDirPath =
          path.join(directory.path, 'flomosupport', imageDirName);
      final Directory imageDir = Directory(imageDirPath);

      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Use timestamp as image name for uniqueness, keeping .png extension
      final String newFileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final String newPath = path.join(imageDirPath, newFileName);

      final File newImage = await pickedImage
          .copy(newPath); // Copy the image to the specified directory
      developer.log("Image saved to: ${newImage.path}");
      return newImage.path; // Return the new image path
    } catch (e) {
      developer.log("Error saving image to local storage: $e");
      // Don't show SnackBar here; let the UI layer handle it.
      return null;
    }
  }
}
