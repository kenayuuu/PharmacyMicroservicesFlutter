import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../model/UserModel.dart';
import '../api/auth_service.dart';

class AuthProvider with ChangeNotifier {
  UserData? _user;
  String? _token;
  bool _isLoading = false;

  UserData? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  final AuthService _authService = AuthService();

  AuthProvider() {
    _loadUserFromStorage();
  }

  // Load user dari SharedPreferences
  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    final token = prefs.getString('token');

    if (userJson != null && token != null) {
      _user = UserData.fromJson(jsonDecode(userJson));
      _token = token;
      notifyListeners();
    }
  }

  // Simpan user ke SharedPreferences
  Future<void> _saveUserToStorage(UserData user, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('token', token);
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result['success'] == true) {
        final userData = result['data'] as UserData;
        _user = userData;
        _token = result['token'] as String? ?? '';

        await _saveUserToStorage(_user!, _token!);

        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': result['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      _isLoading = false;
      notifyListeners();
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }


  // REGISTER
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );

      if (result['success'] == true) {
        final userData = result['data'] as UserData;
        _user = userData;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    await prefs.remove('token');
    _user = null;
    _token = null;
    notifyListeners();
  }
}
