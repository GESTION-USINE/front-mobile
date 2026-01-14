import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/entities/invoice.dart';
import '../models/request/create_invoice_request.dart';
import '../models/request/update_invoice_request.dart';
import '../models/response/invoices_response.dart';

class InvoiceService {
  final ApiClient _apiClient;

  InvoiceService(this._apiClient);

  /// Récupérer la liste des factures avec filtres
  Future<InvoicesResponse> getInvoices({
    int? clientId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (clientId != null) query['client_id'] = clientId;
      if (dateFrom != null) query['date_from'] = dateFrom;
      if (dateTo != null) query['date_to'] = dateTo;

      final response = await _apiClient.get(
        ApiEndpoints.invoices,
        queryParameters: query,
      );

      return InvoicesResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupérer une facture par son ID avec tous les détails
  Future<Invoice> getInvoiceById(int id) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.invoiceById(id));
      final data = response.data['data'] as Map<String, dynamic>;
    
      return Invoice.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Créer une nouvelle facture à partir de bons de pesée
  Future<Invoice> createInvoice(CreateInvoiceRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.invoices,
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Invoice.fromJson(data);
    } on DioException catch (e) {
      // Capter la structure d'erreur du backend
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['error'] != null) {
          final error = errorData['error'];
          final code = error['code'] ?? 'UNKNOWN_ERROR';
          final message = error['message'] ?? 'Une erreur est survenue';
          final details = error['details'] ?? {};

          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: {
              'code': code,
              'message': message,
              'details': details,
            },
          );
        }
      }
      rethrow;
    }
  }

  /// Mettre à jour une facture (ajouter/retirer des bons)
  Future<Invoice> updateInvoice(int id, UpdateInvoiceRequest request) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.invoiceById(id),
        data: request.toJson(),
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return Invoice.fromJson(data);
    } on DioException catch (e) {
      // Capter la structure d'erreur du backend
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['error'] != null) {
          final error = errorData['error'];
          final code = error['code'] ?? 'UNKNOWN_ERROR';
          final message = error['message'] ?? 'Une erreur est survenue';
          final details = error['details'] ?? {};

          throw DioException(
            requestOptions: e.requestOptions,
            response: e.response,
            type: e.type,
            error: {
              'code': code,
              'message': message,
              'details': details,
            },
          );
        }
      }
      rethrow;
    }
  }

  /// Imprimer une facture en PDF
  Future<Response> printInvoicePdf(int invoiceId) async {
    try {
      final response = await _apiClient.downloadFile(
        '/invoices/$invoiceId/print',
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Supprimer une facture (soft delete)
  Future<void> deleteInvoice(int id) async {
    try {
      await _apiClient.delete(ApiEndpoints.invoiceById(id));
    } on DioException {
      rethrow;
    }
  }
}
