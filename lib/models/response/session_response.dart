class SessionResponse {
  final int id;
  final int userId;
  final bool isRemote;

  SessionResponse({
    required this.id,
    required this.userId,
    required this.isRemote,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    return SessionResponse(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      isRemote: json['is_remote'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'is_remote': isRemote,
      };
}
