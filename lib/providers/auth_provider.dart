import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../model/UserModel.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  UserData? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserData? get user => _user;

  // ================= REGISTER =================
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      role: role,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _user = result['data'];
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    notifyListeners();
    return false;
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;

    if (result['success'] == true) {
      _user = result['data'];
      _isAuthenticated = true;
    }

    notifyListeners();
    return result;
  }

  // ================= LOGOUT =================
  void logout() {
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
