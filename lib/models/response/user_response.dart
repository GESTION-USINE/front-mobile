import 'dart:convert';

class UserResponse {
  final int id;
  final String username;
  final String role;
  final bool canModifyInvoices;
  final bool canAccessFullTraceability;
  final bool canAccessRemotely;
  final double creditLimit;
  final double currentCreditUsed;

  UserResponse({
    required this.id,
    required this.username,
    required this.role,
    required this.canModifyInvoices,
    required this.canAccessFullTraceability,
    required this.canAccessRemotely,
    required this.creditLimit,
    required this.currentCreditUsed,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
      canModifyInvoices: json['can_modify_invoices'] as bool? ?? false,
      canAccessFullTraceability: json['can_access_full_traceability'] as bool? ?? false,
      canAccessRemotely: json['can_access_remotely'] as bool? ?? false,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      currentCreditUsed: (json['current_credit_used'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'role': role,
        'can_modify_invoices': canModifyInvoices,
        'can_access_full_traceability': canAccessFullTraceability,
        'can_access_remotely': canAccessRemotely,
        'credit_limit': creditLimit,
        'current_credit_used': currentCreditUsed,
      };

  /// Sérialiser en String (pour SharedPreferences)
  String toJsonString() => jsonEncode(toJson());

  /// Désérialiser depuis String
  factory UserResponse.fromJsonString(String jsonString) {
    return UserResponse.fromJson(jsonDecode(jsonString));
  }

  /// Copie avec modifications
  UserResponse copyWith({
    int? id,
    String? username,
    String? role,
    bool? canModifyInvoices,
    bool? canAccessFullTraceability,
    bool? canAccessRemotely,
    double? creditLimit,
    double? currentCreditUsed,
  }) {
    return UserResponse(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      canModifyInvoices: canModifyInvoices ?? this.canModifyInvoices,
      canAccessFullTraceability: canAccessFullTraceability ?? this.canAccessFullTraceability,
      canAccessRemotely: canAccessRemotely ?? this.canAccessRemotely,
      creditLimit: creditLimit ?? this.creditLimit,
      currentCreditUsed: currentCreditUsed ?? this.currentCreditUsed,
    );
  }

  @override
  String toString() => 'UserResponse(id: $id, username: $username, role: $role)';
}
