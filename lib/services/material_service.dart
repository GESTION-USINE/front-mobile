import 'package:dio/dio.dart';
import 'package:flutter_mvvm_template/core/constants/api_endpoints.dart';
import 'package:flutter_mvvm_template/models/entities/material_price.dart';
import 'package:flutter_mvvm_template/models/response/delete_response.dart';
import 'package:flutter_mvvm_template/models/response/material_price_response.dart';

import '../models/entities/material.dart';
import '../models/request/create_material_request.dart';
import '../models/request/update_material_request.dart';
import '../models/response/materials_response.dart';
import '../core/network/api_client.dart';

/// Service pour gérer les matériaux
class MaterialService {
  final ApiClient _apiClient;

  MaterialService(this._apiClient);

  /// Récupère la liste des matériaux avec filtres, recherche et pagination
  Future<MaterialsResponse> getMaterials({
    String? search,
    String? category,
    bool? isActive,
    String sortBy = 'name',
    String sortOrder = 'asc',
    int? page,
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
      if (category != null) {
        queryParams['category'] = category;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _apiClient.get(
        ApiEndpoints.all_materials,
        queryParameters: queryParams,
      );

      return MaterialsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  // PRIX SPECIAL CLIENT 

  Future<MaterialPricesResponse> getClientMaterialPrices({
      required int clientId,
      int? materialId,
      int? page,
      int? pageSize,
    }) async {
      try {
        final queryParams = <String, dynamic>{
          'client_id': clientId,
          'page': page,
          'pageSize': pageSize,
        };

        if (materialId != null) {
          queryParams['material_id'] = materialId;
        }

        final response = await _apiClient.get(
          ApiEndpoints.clientMaterialPrices, // ex: /client-material-prices
          queryParameters: queryParams,
        );

        return MaterialPricesResponse.fromJson(response.data);
      } on DioException {
        rethrow;
      }
}    

     Future<MaterialPriceItem> createClientMaterialPrice({
        required int clientId,
        required int materialId,
        required double customPricePerTon,
      }) async {
        try {
          final body = {
            'client_id': clientId,
            'material_id': materialId,
            'custom_price_per_ton': customPricePerTon,
          };
       final reponse =    await _apiClient.post(
            ApiEndpoints.clientMaterialPrices, // POST /client-material-prices
            data: body,
          );
                   
        final data = reponse.data['data'] as Map<String, dynamic>;
         return MaterialPriceItem.fromJson(data);
        } on DioException {
          rethrow;
        }
      }

      Future<DeleteResponse> deleteClientMaterialPrice({
        required int priceId,
      }) async {
        try {
          final response = await _apiClient.delete(
            '${ApiEndpoints.clientMaterialPrices}/$priceId',
          );
          final status = response.data['status'] as int ;
          return DeleteResponse.fromStatus(status);
        } on DioException {
          rethrow;
        }
      }


   















  /// Crée un nouveau matériau
  Future<Material> createMaterial(CreateMaterialRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.create_material,
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Material.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère un matériau par son ID
  Future<Material> getMaterialById(int id) async {
    try {
      final response = await _apiClient.get('/materials/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return Material.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Met à jour un matériau existant
  Future<Material> updateMaterial(int id, UpdateMaterialRequest request) async {
    try {
      final response = await _apiClient.patch(
        '/materials/$id',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Material.fromJson(data);
    } on DioException {
      rethrow;
    }
  }
}
