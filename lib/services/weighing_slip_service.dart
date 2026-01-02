import 'package:dio/dio.dart';
import 'package:flutter_mvvm_template/core/constants/api_endpoints.dart';

import '../core/network/api_client.dart';
import '../models/entities/weighing_slip.dart';
import '../models/request/create_weighing_slip_request.dart';
import '../models/request/update_weighing_slip_request.dart';
import '../models/response/weighing_slips_response.dart';

class WeighingSlipService {
  final ApiClient _apiClient;
  WeighingSlipService(this._apiClient);

  Future<WeighingSlipsResponse> getSlips({
    String? search,
    int? clientId,
    int? createdBy,
    String? dateFrom,
    String? dateTo,
    bool? isInvoiced,
    bool? isFullyPaid,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int? page,
    int? pageSize,
  }) async {
    try {
      final query = <String, dynamic>{
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (clientId != null) query['client_id'] = clientId;
      if (createdBy != null) query['created_by'] = createdBy;
      if (dateFrom != null) query['date_from'] = dateFrom;
      if (dateTo != null) query['date_to'] = dateTo;
      if (isInvoiced != null) query['is_invoiced'] = isInvoiced;
      if (isFullyPaid != null) query['is_fully_paid'] = isFullyPaid;

      final response = await _apiClient.get(
        ApiEndpoints.all_weighing_slips,
        queryParameters: query,
      );
      return WeighingSlipsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  Future<WeighingSlip> createSlip(CreateWeighingSlipRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.create_weighing_slip,
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return WeighingSlip.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  Future<WeighingSlip> getSlipById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.weighingSlipById(id));
      final data = response.data['data'] as Map<String, dynamic>;
      return WeighingSlip.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  Future<WeighingSlip> updateSlip(int id, UpdateWeighingSlipRequest request) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.weighingSlipById(id),
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return WeighingSlip.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  Future<void> deleteSlip(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.weighingSlipById(id));
    } on DioException {
      rethrow;
    }
  }

  Future<Response> printSlipPdf(int slipId) async {
    try {
      final response = await _apiClient.downloadFile(
        '/weighing-slips/$slipId/print',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Crée un paiement pour un bon de pesée
  Future<dynamic> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await _apiClient.post(
        '/payments', // Endpoint pour créer un paiement
        data: request.toJson(),
      );
      return response.data['data'];
    } on DioException {
      rethrow;
    }
  }
}
