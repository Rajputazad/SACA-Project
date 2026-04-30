import 'dart:convert';
import 'package:http/http.dart' as http;

class NlpApiService {
  // Android emulator
  static const String baseUrl = 'http://10.0.2.2:8000';

  // static const String baseUrl = 'http://192.168.1.10:8000';

  static Future<Map<String, dynamic>> triage({
    required String text,
    required String language,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/triage'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        'language': language,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}