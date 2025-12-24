class LoginRequest {
  final String username;
  final String password;
  final bool isRemote;

  LoginRequest({
    required this.username,
    required this.password,
    this.isRemote = false,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'is_remote': isRemote,
      };
}
