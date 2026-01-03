import 'package:dio/dio.dart';
import 'package:flutter_mvvm_template/core/constants/api_endpoints.dart';
import 'package:flutter_mvvm_template/models/response/clients_response.dart';

import '../models/entities/client.dart';
import '../models/request/create_client_request.dart';
import '../models/request/update_client_request.dart';
import '../models/response/clients_credit_response.dart';
import '../models/response/clients_with_slips_response.dart';
import '../models/response/client_credit_details_response.dart';
import '../core/network/api_client.dart';

/// Service pour gérer les clients
class ClientService {
  final ApiClient _apiClient;

  ClientService(this._apiClient);

  /// Récupère la liste des clients avec filtres, recherche et pagination
  Future<ClientsResponse> getClients({
    String? search,
    String? type,
    bool? canPayByCheck,
    bool? isActive,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int? page ,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (type != null) {
        queryParams['type'] = type;
      }
      if (canPayByCheck != null) {
        queryParams['can_pay_by_check'] = canPayByCheck;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _apiClient.get(
        ApiEndpoints.all_clients,
        queryParameters: queryParams,
      );

      
      return ClientsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Crée un nouveau client
  Future<Client> createClient(CreateClientRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.create_client,
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Client.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère un client par son ID
  Future<Client> getClientById(int id) async {
    try {
      final response = await _apiClient.get('/clients/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return Client.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Met à jour un client existant
  Future<Client> updateClient(int id, UpdateClientRequest request) async {
    try {
      final response = await _apiClient.patch(
        '/clients/$id',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Client.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Get clients with active credit
  Future<ClientsCreditResponse> getClientsWithCredit({
    String sortBy = 'remaining_credit',
    String sortOrder = 'desc',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _apiClient.get(
        '/clients/credit/list',
        queryParameters: queryParams,
      );

      return ClientsCreditResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Get complete credit details for a specific client
  Future<ClientCreditDetailsResponse> getClientCreditDetails(int clientId) async {
    try {
      final response = await _apiClient.get('/clients/$clientId/credit-details');
      return ClientCreditDetailsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Get all clients with their slips and credit information
  Future<ClientsWithSlipsResponse> getAllClientsWithCredit({
    String sortBy = 'total_remaining_credit',
    String sortOrder = 'desc',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page,
        'page_size': pageSize,
      };

      final response = await _apiClient.get(
        '/clients/all-with-credit',
        queryParameters: queryParams,
      );

      return ClientsWithSlipsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}
