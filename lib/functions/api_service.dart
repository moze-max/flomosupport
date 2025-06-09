import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// Modified ApiService (best for testability)
class ApiService {
  final FlutterSecureStorage _storage;
  final http.Client _httpClient;
  String? _apiKey; // This will be set during creation

  // Private constructor for internal use
  ApiService._internal({
    required FlutterSecureStorage storage, // Require dependencies
    required http.Client httpClient,
    required String? apiKey, // Pass the loaded key here
  })  : _storage = storage,
        _httpClient = httpClient,
        _apiKey = apiKey;

  // Asynchronous Factory Constructor
  static Future<ApiService> create({
    FlutterSecureStorage? storage,
    http.Client? httpClient,
  }) async {
    final effectiveStorage = storage ?? const FlutterSecureStorage();
    final effectiveHttpClient = httpClient ?? http.Client();

    final apiKey = await effectiveStorage.read(key: 'APIkey');
    if (apiKey == null) {
      developer.log("API Key is not set in secure storage during creation.");
      // You might want to throw an exception here if a key is mandatory for the app to function
      // throw Exception('API Key is missing for ApiService initialization.');
    }

    return ApiService._internal(
      storage: effectiveStorage,
      httpClient: effectiveHttpClient,
      apiKey: apiKey, // Pass the loaded key to the private constructor
    );
  }

  Future<void> updateApiKey(String newKey) async {
    await _storage.write(key: 'APIkey', value: newKey);
    _apiKey = newKey; // 更新内部缓存的 key
    developer.log("API Key updated and saved to storage.");
  }

  /// Sends data to the configured API endpoint.
  /// Retries up to `maxRetries` times if the request fails.
  /// Returns `true` on success, `false` otherwise.
  Future<bool> sendData(String data) async {
    // With this pattern, _apiKey should already be set during create()
    // However, including a final check for robustness is fine.
    if (_apiKey == null) {
      developer.log(
          "API Key is unexpectedly null in sendData. This should not happen after create().");
      return false; // Or throw a more specific error
    }

    final url = Uri.parse(_apiKey!);
    int retryCount = 0;
    const maxRetries = 3;

    Map<String, dynamic> requestBody = {"content": data};

    while (retryCount < maxRetries) {
      try {
        final response = await _httpClient.post(
          url,
          body: jsonEncode(requestBody),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        );

        if (response.statusCode == 200) {
          developer.log("Response:\n${response.body}");
          return true;
        } else {
          developer.log(
              'Request failed, status: ${response.statusCode}, body: ${response.body}');
          throw Exception('Request failed with status: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          developer.log("Max retries reached, request ultimately failed: $e");
          return false;
        }
        developer.log(
            "\n[WARNING] Upload failed, retrying in 5 seconds (attempts left: ${maxRetries - retryCount}/$maxRetries)...");
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    return false;
  }
}
