// services/storage_service.dart
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
  static Future<File> _getTemplatesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final dirPath = path.join(directory.path, 'flomosupport');
    // Ensure the directory exists
    await Directory(dirPath).create(recursive: true);
    return File(path.join(dirPath, 'templates.json'));
  }

  /// Reads the templates from the local file.
  /// Returns a list of Template objects.
  /// Returns an empty list if the file does not exist or is empty.
  static Future<List<Template>> readTemplatesFromFile() async {
    final file = await _getTemplatesFile();
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

  /// Writes the given list of Template objects back to the local file.
  static Future<void> writeTemplatesToFile(List<Template> templates) async {
    final file = await _getTemplatesFile();
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
