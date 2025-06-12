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
}
