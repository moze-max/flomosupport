import 'dart:io'
    as io; // Alias dart:io to avoid conflict with file package's File
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart'; // 保持导入，因为 MockPlatformInterfaceMixin 依赖它
import 'package:plugin_platform_interface/plugin_platform_interface.dart'; // 保持导入，因为 MockPlatformInterfaceMixin 依赖它
import 'package:uuid/uuid.dart';
import 'package:uuid/data.dart'; // Import for V4Options to match v4 signature
import 'package:flutter/services.dart'; // ！！！新增导入！！！

// Import the file package
import 'package:file/file.dart';
import 'package:file/memory.dart'; // For MemoryFileSystem

import 'package:flomosupport/models/guidemodel.dart'; // Corrected import for Template
import 'package:flomosupport/functions/storage_service.dart'; // Adjust this import to your file structure

// ！！！移除 MockPathProviderPlatform 类，不再需要它！！！
// class MockPathProviderPlatform extends Mock
//     with MockPlatformInterfaceMixin
//     implements PathProviderPlatform {}

// Mock Uuid
class MockUuid extends Mock implements Uuid {
  @override
  String v4({V4Options? config, Map<String, dynamic>? options}) {
    return 'mock-uuid-v4';
  }
}

void main() {
  // ！！！新增这一行代码，确保在任何测试绑定操作之前初始化！！！
  TestWidgetsFlutterBinding.ensureInitialized();

  // Use the file package's FileSystem
  late FileSystem fileSystem;
  late String testAppDocumentsPath;
  late String flomosupportDirPath;
  late String templatesFilePath;
  late String classItemsFilePath;
  late String
      classItemsFilePathDefault; // Added for testing default class items
  late String imageDirPath;
  late String avatarDirPath;
  late String currentAvatarPathFile;

  final mockUuid = MockUuid(); // Shared mock for general template creation

  setUpAll(() {
    // Initialize MemoryFileSystem
    fileSystem = MemoryFileSystem();
    StorageService.setFileSystem(fileSystem); // Inject the mock file system

    // ！！！修改这里：直接模拟 MethodChannel！！！
    testAppDocumentsPath = '/test_app_documents';
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return testAppDocumentsPath;
        }
        return null; // For other methods not being mocked
      },
    );

    flomosupportDirPath = '$testAppDocumentsPath/flomosupport';
    templatesFilePath = '$flomosupportDirPath/templates.json';
    classItemsFilePath = '$flomosupportDirPath/class_items.json';
    classItemsFilePathDefault =
        '$flomosupportDirPath/class_items.json'; // Default path for class items
    imageDirPath = '$flomosupportDirPath/template_images';
    avatarDirPath = '$flomosupportDirPath/avatars';
    currentAvatarPathFile = '$flomosupportDirPath/current_avatar_path.txt';

    // No need to delete directories at setUpAll in MemoryFileSystem, it starts clean.
    // However, if you had complex nested state, you might clear it.
  });

  tearDown(() {
    // For MemoryFileSystem, resetting the fileSystem effectively clears it.
    // Re-initialize for each test to ensure a clean slate.
    fileSystem = MemoryFileSystem();
    StorageService.setFileSystem(fileSystem);
    reset(mockUuid); // Reset mockUuid's behavior after each test
  });

  group('StorageService - Template Operations', () {
    test('loadTemplates returns empty list if file does not exist', () async {
      final templates = await StorageService.loadTemplates();
      expect(templates, isEmpty);
    });

    test('saveTemplates saves templates correctly', () async {
      final template1 = Template.create(
          name: 'Test Template 1',
          classitems: ['Category A'],
          items: ['a', 'b'],
          uuidGenerator: mockUuid);
      final template2 = Template.create(
          name: 'Test Template 2',
          items: ['a', 'b'],
          classitems: ['Category B'],
          uuidGenerator: mockUuid);
      final templatesToSave = [template1, template2];

      await StorageService.saveTemplates(templatesToSave);

      // Use the injected fileSystem to check file existence and content
      final file = fileSystem.file(templatesFilePath);
      expect(await file.exists(), isTrue);
      final contents = await file.readAsString();
      expect(contents, contains('Test Template 1'));
      expect(contents, contains('Test Template 2'));
      expect(contents, contains('mock-uuid-v4'));
    });

    test('loadTemplates loads saved templates correctly', () async {
      final template1 = Template.create(
          name: 'Test Template 1',
          classitems: ['Category A'],
          uuidGenerator: mockUuid);
      final template2 = Template.create(
          name: 'Test Template 2',
          classitems: ['Category B'],
          uuidGenerator: mockUuid);
      final templatesToSave = [template1, template2];
      await StorageService.saveTemplates(templatesToSave);

      final loadedTemplates = await StorageService.loadTemplates();
      expect(loadedTemplates.length, 2);
      // Since Template.create always generates 'mock-uuid-v4' with the mock,
      // we need to adjust our expectation for the ID
      expect(loadedTemplates[0].id, 'mock-uuid-v4');
      expect(loadedTemplates[0].name, 'Test Template 1');
      expect(loadedTemplates[1].name, 'Test Template 2');
    });

    test('deleteTemplate deletes a template and its associated image',
        () async {
      final imageDir = fileSystem.directory(imageDirPath);
      await imageDir.create(recursive: true);
      final dummyImageFile =
          fileSystem.file(path.join(imageDir.path, 'test_image_1.png'));
      await dummyImageFile.writeAsString('dummy image data');

      final mockUuid1 = MockUuid();
      when(mockUuid1.v4()).thenReturn('unique-id-1');
      final templateToDelete = Template.create(
          name: 'Template To Delete',
          imagePath: dummyImageFile.path,
          uuidGenerator: mockUuid1);

      final mockUuid2 = MockUuid();
      when(mockUuid2.v4()).thenReturn('unique-id-2');
      final templateToKeep =
          Template.create(name: 'Template To Keep', uuidGenerator: mockUuid2);

      await StorageService.saveTemplates([templateToDelete, templateToKeep]);

      expect(await fileSystem.file(dummyImageFile.path).exists(), isTrue);

      final isDeleted = await StorageService.deleteTemplate('unique-id-1');
      expect(isDeleted, isTrue);

      final loadedTemplates = await StorageService.loadTemplates();
      expect(loadedTemplates.length, 1);
      expect(loadedTemplates[0].id, 'unique-id-2');
      expect(loadedTemplates[0].name, 'Template To Keep');
      expect(await fileSystem.file(dummyImageFile.path).exists(), isFalse);
    });

    test('deleteTemplate returns false if template not found', () async {
      final template1 = Template.create(
          name: 'Test Template 1',
          classitems: ['Category A'],
          uuidGenerator: mockUuid);
      await StorageService.saveTemplates([template1]);

      final isDeleted = await StorageService.deleteTemplate('non_existent_id');
      expect(isDeleted, isFalse);

      final loadedTemplates = await StorageService.loadTemplates();
      expect(loadedTemplates.length, 1);
      expect(loadedTemplates[0].id, 'mock-uuid-v4');
    });
  });

  group('StorageService - Class Item Operations', () {
    test('loadClassItems returns default list if file does not exist',
        () async {
      final classItems = await StorageService.loadClassItems();
      expect(classItems, ['生活', '工作', '学习']);
      // Verify that no file was created
      expect(
          await fileSystem.file(classItemsFilePathDefault).exists(), isFalse);
    });

    test('saveClassItems saves class items correctly', () async {
      final classItemsToSave = ['New Item 1', 'New Item 2'];
      await StorageService.saveClassItems(classItemsToSave);

      final file = fileSystem.file(classItemsFilePath);
      expect(await file.exists(), isTrue);
      final contents = await file.readAsString();
      expect(contents, contains('New Item 1'));
      expect(contents, contains('New Item 2'));
    });

    test('loadClassItems loads saved class items correctly', () async {
      final classItemsToSave = ['Custom Item A', 'Custom Item B'];
      await StorageService.saveClassItems(classItemsToSave);

      final loadedClassItems = await StorageService.loadClassItems();
      expect(loadedClassItems.length, 2);
      expect(loadedClassItems[0], 'Custom Item A');
    });
  });

  group('StorageService - Image Operations', () {
    test('saveImageToFile saves an image and returns its path', () async {
      // Create an io.File instance for the "original" image, as saveImageToFile takes dart:io.File
      final originalImageDartIoFile =
          io.File('test_image.png'); // No './' needed for temporary file
      await originalImageDartIoFile.writeAsString(
          'test image data'); // This creates a real file for the test, which is fine as it's the input.

      final savedPath =
          await StorageService.saveImageToFile(originalImageDartIoFile);

      expect(savedPath, isNotNull);
      expect(savedPath!.contains(imageDirPath), isTrue);
      // Check for existence using the mocked fileSystem
      expect(await fileSystem.file(savedPath).exists(), isTrue);

      await originalImageDartIoFile.delete(); // Clean up the real dummy file
    });

    test('deleteImageFile deletes an image file', () async {
      final imageDir = fileSystem.directory(imageDirPath);
      await imageDir.create(recursive: true);
      final dummyImageFile =
          fileSystem.file('${imageDir.path}/image_to_delete.png');
      await dummyImageFile.writeAsString('dummy image data');

      expect(await dummyImageFile.exists(), isTrue);

      await StorageService.deleteImageFile(dummyImageFile.path);
      expect(await dummyImageFile.exists(), isFalse);
    });

    test('deleteImageFile handles non-existent file gracefully', () async {
      await StorageService.deleteImageFile(
          '/non_existent_image.png'); // Use absolute path for consistency with MemoryFileSystem
    });
  });

  group('StorageService - Avatar Operations', () {
    test('saveAvatar saves avatar, records path, and cleans old avatars',
        () async {
      // Create io.File instances for input, as saveAvatar takes dart:io.File
      final testAvatarFile1 = io.File('test_avatar_1.png'); // No './' needed
      await testAvatarFile1.writeAsString('test avatar data 1');

      final savedPath1 = await StorageService.saveAvatar(testAvatarFile1);
      expect(savedPath1, isNotNull);
      expect(await fileSystem.file(savedPath1!).exists(), isTrue);
      expect(await fileSystem.file(currentAvatarPathFile).readAsString(),
          savedPath1);

      final testAvatarFile2 = io.File('test_avatar_2.png'); // No './' needed
      await testAvatarFile2.writeAsString('test avatar data 2');

      final savedPath2 = await StorageService.saveAvatar(testAvatarFile2);
      expect(savedPath2, isNotNull);
      expect(await fileSystem.file(savedPath2!).exists(), isTrue);
      expect(await fileSystem.file(currentAvatarPathFile).readAsString(),
          savedPath2);
      expect(await fileSystem.file(savedPath1).exists(),
          isFalse); // Old avatar should be deleted

      await testAvatarFile1.delete(); // Clean up real dummy file
      await testAvatarFile2.delete(); // Clean up real dummy file
    });

    test('loadAvatar loads the saved avatar', () async {
      final testAvatarFile = io.File('test_avatar_load.png'); // No './' needed
      await testAvatarFile.writeAsString('test avatar data for loading');
      final savedPath = await StorageService.saveAvatar(testAvatarFile);

      final loadedAvatar = await StorageService.loadAvatar();
      expect(loadedAvatar, isNotNull);
      // Ensure the loadedAvatar (io.File) points to the correct path in the mocked file system
      // Note: `loadAvatar` now returns an `io.File` which will be a temporary real file.
      // We check its path to ensure it matches the path in our *mocked* file system.
      expect(loadedAvatar!.path, savedPath);

      await testAvatarFile.delete(); // Clean up real dummy file
      // If loadAvatar returns a new real file, it might need to be deleted too,
      // but for unit tests, often the garbage collection is sufficient or not strictly needed
      // unless it's causing resource issues.
      if (loadedAvatar.existsSync()) {
        // Only delete if it exists (might not if test setup is different)
        await loadedAvatar.delete();
      }
    });

    test('loadAvatar returns null if no avatar path recorded', () async {
      final loadedAvatar = await StorageService.loadAvatar();
      expect(loadedAvatar, isNull);
    });

    test('loadAvatar returns null and clears record if avatar file not found',
        () async {
      // Manually write a path, then delete the file to simulate missing file
      final pathFile = fileSystem.file(currentAvatarPathFile);
      await pathFile.writeAsString('$avatarDirPath/non_existent_avatar.png');

      final loadedAvatar = await StorageService.loadAvatar();
      expect(loadedAvatar, isNull);
      expect(await fileSystem.file(currentAvatarPathFile).exists(),
          isFalse); // Record should be cleared
    });

    test(
        'deleteAvatar deletes avatar image and path record, and cleans old avatars',
        () async {
      final testAvatarFile =
          io.File('test_avatar_delete.png'); // No './' needed
      await testAvatarFile.writeAsString('test avatar data for deletion');
      final savedPath = await StorageService.saveAvatar(testAvatarFile);

      expect(await fileSystem.file(savedPath!).exists(), isTrue);
      expect(await fileSystem.file(currentAvatarPathFile).exists(), isTrue);

      await StorageService.deleteAvatar();

      expect(await fileSystem.file(savedPath).exists(),
          isFalse); // Avatar image should be deleted
      expect(await fileSystem.file(currentAvatarPathFile).exists(),
          isFalse); // Path record should be deleted

      await testAvatarFile.delete(); // Clean up real dummy file
    });
  });
}
