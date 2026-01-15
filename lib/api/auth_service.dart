import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/UserModel.dart';
import '../config/api_config.dart';

class AuthService {
  static const String baseUrl = ApiConfig.userServiceUrl;

  bool _isJsonValid(String body) {
    try {
      jsonDecode(body);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ================= REGISTER =================
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
        }),
      );

      if (!_isJsonValid(response.body)) {
        return {
          'success': false,
          'message': 'Server tidak mengirim JSON yang valid'
        };
      }

      final body = jsonDecode(response.body);

      // User bisa berada di beberapa key berbeda
      final userJson =
          body['user'] ??
          body['data'] ??
          (body is List && body.isNotEmpty ? body.first : null) ??
          body;

      return {
        'success': response.statusCode == 200 || response.statusCode == 201,
        'data': UserData.fromJson(userJson),
      };
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

 // ================= LOGIN =================
Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN BODY: ${response.body}');

    if (!_isJsonValid(response.body)) {
      return {
        'success': false,
        'message': 'Response server bukan JSON'
      };
    }

    final body = jsonDecode(response.body);

    // 🔑 INI YANG BENAR
    if (body['success'] == true) {
      return {
        'success': true,
        'data': UserData.fromJson(body['data']),
        'token': body['token'],
      };
    }

    return {
      'success': false,
      'message': body['message'] ?? 'Login gagal'
    };
  } catch (e) {
    return {
      'success': false,
      'message': 'Error login: $e',
    };
  }
}
}