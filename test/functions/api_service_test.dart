import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flomosupport/functions/api_service.dart';

import 'api_service_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<http.Client>(),
  MockSpec<FlutterSecureStorage>(),
])
void main() {
  late MockClient mockHttpClient;
  late MockFlutterSecureStorage mockSecureStorage;
  // late ApiService apiService; // apiService 不再作为全局 late 变量，而是在每个测试中声明和初始化

  setUp(() {
    // setUp 保持同步，或者只做异步初始化（如 ApiService.create），但不要包含 when
    mockHttpClient = MockClient();
    mockSecureStorage = MockFlutterSecureStorage();

    reset(mockHttpClient);
    reset(mockSecureStorage); // 确保每次测试都是干净的 slate
  });

  group('ApiService Tests', () {
    // 每个测试用例都应该在内部设置其所需的 ApiService 实例

    test('sendData returns true on successful 200 response with loaded key',
        () async {
      // Arrange: Configure mockSecureStorage to return a key BEFORE ApiService is created
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://testapi.com/endpoint');

      // Create ApiService instance for this specific test
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      // Configure mockHttpClient to return a successful 200 response
      when(mockHttpClient.post(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('{"status": "success"}', 200));

      // Act: Call sendData
      final result = await apiService.sendData('test data');

      // Assert
      expect(result, true);

      // Verify http.post was called with the correct URL and data
      verify(mockHttpClient.post(
        Uri.parse('https://testapi.com/endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"content": "test data"}),
      )).called(1);

      // Verify secure storage was read EXACTLY once during ApiService.create()
      verify(mockSecureStorage.read(key: 'APIkey')).called(1);
    });

    test('sendData returns false and retries on non-200 response', () async {
      // Arrange: Configure mockSecureStorage to return a key
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://testapi.com/endpoint');

      // Create ApiService instance for this specific test
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      // Configure mockHttpClient to return a non-200 response multiple times
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('Error', 500));

      final result = await apiService.sendData('test data');

      expect(result, false);
      // Verify http.post was called maxRetries (3) times
      verify(mockHttpClient.post(
        Uri.parse('https://testapi.com/endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"content": "test data"}),
      )).called(3);

      // Verify secure storage was read EXACTLY once during ApiService.create()
      verify(mockSecureStorage.read(key: 'APIkey')).called(1);
    });

    test('sendData returns false and retries on network error (Exception)',
        () async {
      // Arrange: Configure mockSecureStorage to return a key
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://testapi.com/endpoint');

      // Create ApiService instance for this specific test
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      // Configure mockHttpClient to throw an exception multiple times
      when(mockHttpClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(Exception('Network error'));

      final result = await apiService.sendData('test data');

      expect(result, false);
      // Verify http.post was called maxRetries (3) times
      verify(mockHttpClient.post(
        Uri.parse('https://testapi.com/endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({"content": "test data"}),
      )).called(3);

      // Verify secure storage was read EXACTLY once during ApiService.create()
      verify(mockSecureStorage.read(key: 'APIkey')).called(1);
    });

    // 针对 "sendData returns false when API key is null during create" 的修正
    // 这是您遇到 "Expected: <1> Actual: <2>" 错误的测试
    test('sendData returns false when API key is null during create', () async {
      // Arrange: Configure mockSecureStorage to return null for the API key
      // This should be done BEFORE ApiService.create is called.
      when(mockSecureStorage.read(key: 'APIkey')).thenAnswer((_) async => null);

      // Act: Create ApiService. _apiKey will be null because of the mockSecureStorage setup.
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      // Assert: sendData should return false
      final result = await apiService.sendData('test data without key');

      expect(result, false);

      // Verify: secure storage was read once during create
      verify(mockSecureStorage.read(key: 'APIkey')).called(1); // <-- 这里应该只有 1 次
      // Verify: http.post was NEVER called because API key was null
      verifyZeroInteractions(mockHttpClient);
    });

    test('sendData uses cached API key after initial create', () async {
      // 1. **不再需要额外的 reset，因为 setUp 已经 reset 了**

      // 2. 配置 mockSecureStorage，使其在 ApiService.create() 时返回期望的 API Key
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://firstload.com/api');

      // 3. **在这个测试中创建 ApiService 实例，并等待其初始化**
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      // 4. 配置 mockHttpClient 的行为，以便它在第一次和第二次调用时都返回成功响应
      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('OK', 200));

      // First call
      final result1 = await apiService.sendData('data1');
      expect(result1, true);
      verify(mockSecureStorage.read(key: 'APIkey')).called(1);
      verify(mockHttpClient.post(Uri.parse('https://firstload.com/api'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);

      // **重点：在这里清除 mockHttpClient 的调用记录**
      clearInteractions(mockHttpClient);

      // **不需要重新配置 mockHttpClient 的行为，因为 clearInteractions() 不会清除 when() 行为**
      // when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
      //     .thenAnswer((_) async => http.Response('OK', 200)); // <-- 移除此行

      // 第二次调用：_apiKey 应该已经缓存，不会再次读取 storage
      final result2 = await apiService.sendData('data2');

      expect(result2, true);
      verifyNever(mockSecureStorage.read(key: 'APIkey')); // 确认没有再次读取存储

      // 验证 mockHttpClient 再次被调用，且仅被调用 1 次 (因为 clearInteractions 之后)
      verify(mockHttpClient.post(Uri.parse('https://firstload.com/api'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);
    });

    test('updateApiKey correctly updates the key in storage and internally',
        () async {
      // Arrange: Initially no key, or an old key during create
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'old_key_url');
      when(mockSecureStorage.write(key: 'APIkey', value: anyNamed('value')))
          .thenAnswer((_) async {}); // Mock write operation

      final apiService = await ApiService.create(
        // <--- 声明为 final apiService
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      // Verify initial _apiKey is 'old_key_url' from create.
      // Note: ensure this verify is correctly reflecting the single call during create.
      verify(mockSecureStorage.read(key: 'APIkey'))
          .called(1); // Call count after ApiService.create()

      // Act: Update the API key
      final newKey = 'https://newapi.com/v1';
      await apiService.updateApiKey(newKey);

      // Assert & Verify:
      // Verify that the new key was written to storage
      verify(mockSecureStorage.write(key: 'APIkey', value: newKey)).called(1);

      // Verify that sendData now uses the new key
      when(mockHttpClient.post(
              Uri.parse(newKey), // Mock HTTP client for the new key
              headers: anyNamed('headers'),
              body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('New API OK', 200));

      final result = await apiService.sendData('data using new key');
      expect(result, true);

      // Verify that http.post was called with the new key URL
      verify(mockHttpClient.post(Uri.parse(newKey),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(1);

      // Verify that storage was NOT read again by sendData
      // Use clearInteractions if needed before this to only count interactions after updateApiKey
      verifyNoMoreInteractions(
          mockSecureStorage); // This means no more reads or writes *after* the last verified one.
      // If write was called, this should be fine.
    });
    test('sendData sends correct JSON body and headers', () async {
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://testapi.com/endpoint');
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"status": "success"}', 200));

      final testData = 'my test string';
      final expectedBody = jsonEncode({'content': testData});
      final expectedHeaders = {
        'Content-Type': 'application/json; charset=UTF-8'
      };

      final result = await apiService.sendData(testData);

      expect(result, true);
      verify(mockHttpClient.post(
        Uri.parse('https://testapi.com/endpoint'),
        body: expectedBody, // 精确验证 body
        headers: expectedHeaders, // 精确验证 headers
      )).called(1);
    });
    test('sendData returns false on 401 Unauthorized response after retries',
        () async {
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://testapi.com/endpoint');
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));

      final result = await apiService.sendData('unauthorized data');

      expect(result, false);
      // Verify it tried maxRetries times (3 times)
      verify(mockHttpClient.post(Uri.parse('https://testapi.com/endpoint'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(3);
    });

    test('sendData returns false on 404 Not Found response after retries',
        () async {
      when(mockSecureStorage.read(key: 'APIkey'))
          .thenAnswer((_) async => 'https://testapi.com/endpoint');
      final apiService = await ApiService.create(
        storage: mockSecureStorage,
        httpClient: mockHttpClient,
      );

      when(mockHttpClient.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final result = await apiService.sendData('data for missing endpoint');

      expect(result, false);
      verify(mockHttpClient.post(Uri.parse('https://testapi.com/endpoint'),
              headers: anyNamed('headers'), body: anyNamed('body')))
          .called(3);
    });
  });
}
