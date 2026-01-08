import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/user.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  /// Get list of users with filters and pagination
  Future<UsersListResponse> getUsers({
    String? role,
    bool? isActive,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/users',
        queryParameters: {
          if (role != null) 'role': role,
          if (isActive != null) 'is_active': isActive,
          if (search != null) 'search': search,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
          'page': page,
          'pageSize': pageSize,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return UsersListResponse.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Create a new user
  Future<User> createUser(CreateUserRequest request) async {
    try {
      final response = await _apiClient.post(
        '/users',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Get user by ID
  Future<User> getUserById(int userId) async {
    try {
      final response = await _apiClient.get('/users/$userId');

      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Update user
  Future<User> updateUser(int userId, UpdateUserRequest request) async {
    try {
      final response = await _apiClient.patch(
        '/users/$userId',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Get current user profile
  Future<User> getMyProfile() async {
    try {
      final response = await _apiClient.get('/users/profile');

      final data = response.data['data'] as Map<String, dynamic>;
      return User.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Deactivate user
  Future<DeactivateUserResponse> deactivateUser(int userId) async {
    try {
      final response = await _apiClient.post('/users/$userId/deactivate');

      final data = response.data['data'] as Map<String, dynamic>;
      return DeactivateUserResponse.fromJson(data);
    } on DioException {
      rethrow;
    }
  }
}
