class UserModel {
  final bool success;
  final List<UserData> data;

  UserModel({
    required this.success,
    required this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((e) => UserData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class UserData {
  final int? id;
  final String name;
  final String role;
  final String? email;
  final String? phone;
  final String? shift;
  final String? password;

  UserData({
    this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.shift,
    this.password,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      email: json['email'],
      phone: json['phone'],
      shift: json['shift'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      if (id != null) "id": id,
      "name": name,
      "role": role,
      if (email != null) "email": email,
      if (phone != null) "phone": phone,
      if (shift != null) "shift": shift,
      if (password != null) "password": password,
    };
    return map;
  }
}
