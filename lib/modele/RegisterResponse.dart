class RegisterResponse {
  final String message;
  final User user;
  final String token;

  RegisterResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "user": user.toJson(),
      "token": token,
    };
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

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "email": email,
      "phone": phone,
      "theme": theme,
      "created_at": createdAt,
      "updated_at": updatedAt,
    };
  }
}
