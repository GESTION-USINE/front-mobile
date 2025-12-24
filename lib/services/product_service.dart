import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../core/exceptions/app_exceptions.dart';
import '../models/request/create_product_request.dart';
import '../models/response/product_response.dart';
import 'interfaces/i_product_service.dart';

class ProductService implements IProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  @override
  Future<List<ProductResponse>> getProducts() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.products);
      final List data = response.data;
      return data.map((json) => ProductResponse.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductResponse> getProductById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.products}/$id');
      return ProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductResponse> createProduct(CreateProductRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.products,
        data: request.toJson(),
      );
      return ProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductResponse> updateProduct(
    String id,
    CreateProductRequest request,
  ) async {
    try {
      final response = await _apiClient.put(
        '${ApiEndpoints.products}/$id',
        data: request.toJson(),
      );
      return ProductResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.products}/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ProductResponse>> searchProducts(String query) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.products,
        queryParameters: {'search': query},
      );
      final List data = response.data;
      return data.map((json) => ProductResponse.fromJson(json)).toList();
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

    switch (statusCode) {
      case 401:
        return UnauthorizedException();
      case 404:
        return NotFoundException('Produit non trouvé');
      default:
        return ServerException('Erreur serveur', statusCode);
    }
  }
}
