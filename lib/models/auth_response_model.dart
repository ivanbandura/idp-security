import 'user_model.dart';

class AuthResponse {
  final User user;
  final String? refreshToken;
  final String? accessToken;
  final String? message;

  AuthResponse({
    required this.user,
    this.refreshToken,
    this.accessToken,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      refreshToken: json['refreshToken'],
      accessToken: json['accessToken'],
      message: json['message'],
    );
  }
}
