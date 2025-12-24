import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/request/login_request.dart';
import '../models/response/login_response.dart';
import 'interfaces/i_auth_service.dart';

class AuthService implements IAuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }



  @override
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> refreshToken() async {
    try {
      await _apiClient.post(ApiEndpoints.refreshToken);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Récupérer le message d'erreur de la structure API
    String? errorMessage;
    if (data != null && data is Map<String, dynamic>) {
      final error = data['error'];
      if (error != null && error is Map<String, dynamic>) {
        errorMessage = error['message'] as String?;
      }
    }

    switch (statusCode) {
      case 400:
        return ValidationException(errorMessage ?? 'Données invalides');
      case 401:
        return UnauthorizedException(errorMessage ?? 'Identifiants incorrects');
      case 403:
        return UnauthorizedException(errorMessage ?? 'Compte désactivé ou accès distant non autorisé');
      case 404:
        return NotFoundException();
      case 422:
        return ValidationException(errorMessage ?? 'Erreur de validation');
      case 429:
        return ServerException('Trop de tentatives de connexion. Veuillez réessayer plus tard.', statusCode);
      default:
        return ServerException(errorMessage ?? 'Erreur serveur', statusCode);
    }
  }
}
