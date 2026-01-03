import 'package:dio/dio.dart';
import '../models/entities/salary_payment.dart';
import '../models/request/create_salary_payment_request.dart';
import '../models/response/salary_payments_response.dart';
import '../core/network/api_client.dart';

/// Service pour gérer les paiements de salaire
class SalaryPaymentService {
  final ApiClient _apiClient;

  SalaryPaymentService(this._apiClient);
  



     String _formatDateToString(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
  
   


  /// Récupère la liste des paiements de salaire avec filtres, tri et pagination
  Future<SalaryPaymentsResponse> getSalaryPayments({
    int? workerId,
    String? paymentMonth,
    DateTime? dateFrom,
    DateTime? dateTo,
    String sortBy = 'payment_month',
    String sortOrder = 'desc',
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };

      if (workerId != null) {
        queryParams['worker_id'] = workerId;
      }
      if (paymentMonth != null && paymentMonth.isNotEmpty) {
        queryParams['payment_month'] = paymentMonth;
      }
      if (dateFrom != null) {
        queryParams['date_from'] = _formatDateToString(dateFrom);
      }
      if (dateTo != null) {
        queryParams['date_to'] = _formatDateToString(dateTo);
      }

      final response = await _apiClient.get(
        '/salary-payments',
        queryParameters: queryParams,
      );
       final result = SalaryPaymentsResponse.fromJson(response.data);

      return result;
    } on DioException {
      rethrow;
    }
  }

  /// Crée un nouveau paiement de salaire
  Future<SalaryPayment> createSalaryPayment(CreateSalaryPaymentRequest request) async {
    try {
      final response = await _apiClient.post(
        '/salary-payments',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return SalaryPayment.fromJson(data);
    } on DioException {
      rethrow;
    }
  }
}
