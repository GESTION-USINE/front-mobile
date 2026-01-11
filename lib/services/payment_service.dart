import 'package:dio/dio.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/entities/payment.dart';
import '../models/request/create_payment_request.dart';
import '../models/response/payment_response.dart';
import '../models/response/payment_details_response.dart';
import '../models/response/weighing_slips_response.dart';
import '../models/response/credits_payments_response.dart';

class PaymentService {
  final ApiClient _apiClient;
  PaymentService(this._apiClient);

  /// Create a new payment
  Future<PaymentResponse> createPayment(CreatePaymentRequest request) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.payments,
        data: request.toJson(),
      );
      return PaymentResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Get all weighing slips with remaining credit (not fully paid)
  Future<WeighingSlipsResponse> getSlipsWithCredit({
    String? search,
    int? clientId,
    String? dateFrom,
    String? dateTo,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int? page,
    int? pageSize,
  }) async {
    try {
      final query = <String, dynamic>{
        'is_fully_paid': false, // Only get slips with remaining credit
        'sortBy': sortBy,
        'sortOrder': sortOrder,
        'page': page,
        'pageSize': pageSize,
      };
      if (search != null && search.isNotEmpty) query['search'] = search;
      if (clientId != null) query['client_id'] = clientId;
      if (dateFrom != null) query['date_from'] = dateFrom;
      if (dateTo != null) query['date_to'] = dateTo;

      final response = await _apiClient.get(
        ApiEndpoints.all_weighing_slips,
        queryParameters: query,
      );
      return WeighingSlipsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Get payments for a specific weighing slip
  Future<List<Payment>> getPaymentsForSlip(int weighingSlipId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.payments}?weighing_slip_id=$weighingSlipId',
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => Payment.fromJson(json)).toList();
    } on DioException {
      rethrow;
    }
  }

  /// Get detailed payment information for a weighing slip
  Future<PaymentDetailsResponse> getPaymentDetails(int weighingSlipId) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.payments}/weighing-slips/$weighingSlipId',
      );
      return PaymentDetailsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Get daily credits payments (encaissements), filterable by date (YYYY-MM-DD)
  Future<CreditsPaymentsResponse> getCreditsPayments({String? date}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.creditsPayments,
        queryParameters: {
          if (date != null) 'date': date,
        },
      );
      return CreditsPaymentsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }
}
