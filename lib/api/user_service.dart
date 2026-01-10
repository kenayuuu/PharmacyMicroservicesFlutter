import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/UserModel.dart';
import '../config/api_config.dart';

class UserService {
  static const String baseUrl = ApiConfig.userServiceUrl;

  // ================= GET ALL USERS =================
  Future<UserModel> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      }

      throw Exception('Failed to load users');
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  // ================= GET USER BY ID =================
  Future<UserModel?> getUserById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  // ================= CREATE USER =================
  Future<bool> createUser(UserData user) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }

      return false;
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // ================= UPDATE USER =================
  Future<bool> updateUser(int id, UserData user) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }

      return false;
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // ================= DELETE USER =================
  Future<bool> deleteUser(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      return false;
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // ================= LOGIN =================
  Future<UserData?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return UserData.fromJson(data['data']);
        }
      }

      return null; // login gagal
    } catch (e) {
      throw Exception('Error login: $e');
    }
  }
}
