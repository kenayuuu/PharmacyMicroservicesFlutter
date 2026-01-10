import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/UserModel.dart';
import '../config/api_config.dart';

class UserService {
  static const String baseUrl = ApiConfig.userServiceUrl;

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => UserModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<UserModel?> getUserById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/users/$id'));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<bool> createUser(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<bool> updateUser(int id, UserModel user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/api/users/$id'));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }
}
