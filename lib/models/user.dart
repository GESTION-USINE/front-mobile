class User {
  final int id;
  final String username;
  final String? email;
  final String? phone;
  final String role;
  final bool isActive;
  final bool canModifyInvoices;
  final bool canAccessFullTraceability;
  final bool canAccessRemotely;
  final double creditLimit;
  final double currentCreditUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.canModifyInvoices,
    required this.canAccessFullTraceability,
    required this.canAccessRemotely,
    required this.creditLimit,
    required this.currentCreditUsed,
    required this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'employe',
      isActive: json['is_active'] as bool? ?? true,
      canModifyInvoices: json['can_modify_invoices'] as bool? ?? false,
      canAccessFullTraceability: json['can_access_full_traceability'] as bool? ?? false,
      canAccessRemotely: json['can_access_remotely'] as bool? ?? false,
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      currentCreditUsed: (json['current_credit_used'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'is_active': isActive,
      'can_modify_invoices': canModifyInvoices,
      'can_access_full_traceability': canAccessFullTraceability,
      'can_access_remotely': canAccessRemotely,
      'credit_limit': creditLimit,
      'current_credit_used': currentCreditUsed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class UsersListResponse {
  final List<User> items;
  final UsersPagination pagination;

  UsersListResponse({
    required this.items,
    required this.pagination,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: UsersPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class UsersPagination {
  final int page;
  final int pageSize;
  final int total;

  UsersPagination({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  factory UsersPagination.fromJson(Map<String, dynamic> json) {
    return UsersPagination(
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
    );
  }
}

class CreateUserRequest {
  final String username;
  final String password;
  final String? email;
  final String? phone;
  final String role;
  final bool canModifyInvoices;
  final bool canAccessFullTraceability;
  final bool canAccessRemotely;
  final double creditLimit;

  CreateUserRequest({
    required this.username,
    required this.password,
    this.email,
    this.phone,
    required this.role,
    this.canModifyInvoices = false,
    this.canAccessFullTraceability = false,
    this.canAccessRemotely = false,
    this.creditLimit = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'phone': phone,
      'role': role,
      'can_modify_invoices': canModifyInvoices,
      'can_access_full_traceability': canAccessFullTraceability,
      'can_access_remotely': canAccessRemotely,
      'credit_limit': creditLimit,
    };
  }
}

class UpdateUserRequest {
  final String? email;
  final String? phone;
  final bool? canModifyInvoices;
  final bool? canAccessFullTraceability;
  final bool? canAccessRemotely;
  final double? creditLimit;

  UpdateUserRequest({
    this.email,
    this.phone,
    this.canModifyInvoices,
    this.canAccessFullTraceability,
    this.canAccessRemotely,
    this.creditLimit,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (canModifyInvoices != null) 'can_modify_invoices': canModifyInvoices,
      if (canAccessFullTraceability != null) 'can_access_full_traceability': canAccessFullTraceability,
      if (canAccessRemotely != null) 'can_access_remotely': canAccessRemotely,
      if (creditLimit != null) 'credit_limit': creditLimit,
    };
  }
}

class DeactivateUserResponse {
  final int id;
  final String username;
  final bool isActive;
  final DateTime deactivatedAt;
  final bool ok;

  DeactivateUserResponse({
    required this.id,
    required this.username,
    required this.isActive,
    required this.deactivatedAt,
    required this.ok,
  });

  factory DeactivateUserResponse.fromJson(Map<String, dynamic> json) {
    return DeactivateUserResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      isActive: json['is_active'] as bool? ?? false,
      deactivatedAt: DateTime.parse(json['deactivated_at'] as String),
      ok: json['ok'] as bool? ?? true,
    );
  }
}
