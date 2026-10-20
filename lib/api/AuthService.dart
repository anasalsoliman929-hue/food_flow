

import 'dart:convert';
import 'package:http/http.dart' as http;

/// موديل للرد (تسجيل/تسجيل دخول)
class AuthResponse {
  final String message;
  final User user;
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String theme;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.theme,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      theme: json['theme'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
class AuthService {
  static const String baseUrl = "http://10.0.2.2:8000/api/auth";

  /// تسجيل الدخول
  static Future<AuthResponse> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل تسجيل الدخول: ${response.statusCode} \n ${response.body}");
    }
  }

  /// التسجيل
  static Future<AuthResponse> registerUser({
    required String username,
    required String email,
    required String password,
    required String phone,
    required String theme,
  }) async {
    final url = Uri.parse("$baseUrl/register");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "phone": phone,
        "theme": theme,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("فشل التسجيل: ${response.statusCode} \n ${response.body}");
    }
  }
}