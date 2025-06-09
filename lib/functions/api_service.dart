// services/api_service.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _apiKey;

  ApiService() {
    _loadApiKey(); // Load API key when ApiService is instantiated
  }

  Future<void> _loadApiKey() async {
    _apiKey = await _storage.read(key: 'APIkey');
    if (_apiKey == null) {
      developer.log("API Key is not set in secure storage.");
    }
  }

  /// Sends data to the configured API endpoint.
  /// Retries up to `maxRetries` times if the request fails.
  /// Returns `true` on success, `false` otherwise.
  Future<bool> sendData(String data) async {
    if (_apiKey == null) {
      await _loadApiKey(); // Try loading again if it's null (e.g., first call)
      if (_apiKey == null) {
        developer.log("API Key is still not available, cannot send request.");
        return false;
      }
    }

    final url = Uri.parse(_apiKey!);
    int retryCount = 0;
    const maxRetries = 3;

    Map<String, dynamic> requestBody = {"content": data};

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
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
    return false; // Should not be reached if max retries are handled, but good for safety
  }
}
