import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  String? _token;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter le token si disponible
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// Définir le token d'authentification
  void setToken(String? token) {
    _token = token;
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters);
  }

  // Dans api_client.dart
  Future<Response> downloadFile(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': 'application/pdf',
        },
      ),
    );
  }
}
