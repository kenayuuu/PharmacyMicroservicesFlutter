import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/UserModel.dart';
import '../config/api_config.dart';

class UserService {
  static const String baseUrl = ApiConfig.userServiceUrl;

  // GET ALL USERS
  Future<List<UserData>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final list = data['data'] as List<dynamic>;
      return list.map((e) => UserData.fromJson(e)).toList();
    }
    throw Exception('Failed to load users');
  }

  // CREATE USER
  Future<bool> createUser(UserData user) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data['success'] ?? false;
    }
    return false;
  }

  // UPDATE USER
  Future<bool> updateUser(int id, UserData user) async {
    final res = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson(forUpdate: true)),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['success'] ?? false;
    }
    return false;
  }

  // DELETE USER
  Future<bool> deleteUser(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/users/$id'));
    return res.statusCode == 200 || res.statusCode == 204;
  }
}
