import 'user_response.dart';
import 'session_response.dart';

class LoginResponse {
  final int status;
  final String accessToken;
  final String expiresAt;
  final SessionResponse session;
  final UserResponse user;

  LoginResponse({
    required this.status,
    required this.accessToken,
    required this.expiresAt,
    required this.session,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return LoginResponse(
      status: json['status'] as int,
      accessToken: data['accessToken'] as String,
      expiresAt: data['expiresAt'] as String,
      session: SessionResponse.fromJson(data['session'] as Map<String, dynamic>),
      user: UserResponse.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': {
          'accessToken': accessToken,
          'expiresAt': expiresAt,
          'session': session.toJson(),
          'user': user.toJson(),
        },
      };
}
