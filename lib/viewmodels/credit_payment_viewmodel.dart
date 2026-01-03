import 'package:flutter/material.dart';
import '../models/entities/payment.dart';
import '../models/entities/weighing_slip.dart';
import '../models/request/create_payment_request.dart';
import '../models/response/payment_response.dart';
import '../services/payment_service.dart';

class CreditPaymentViewModel extends ChangeNotifier {
  final PaymentService _paymentService;

  CreditPaymentViewModel(this._paymentService);

  // State
  bool _isLoading = false;
  String? _error;
  List<WeighingSlip> _slipsWithCredit = [];
  List<Payment> _payments = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WeighingSlip> get slipsWithCredit => _slipsWithCredit;
  List<Payment> get payments => _payments;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalRecords => _totalRecords;

  /// Load all weighing slips with remaining credit
  Future<void> loadSlipsWithCredit({
    String? search,
    int? clientId,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _paymentService.getSlipsWithCredit(
        search: search,
        clientId: clientId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        pageSize: pageSize,
      );

      _slipsWithCredit = response.items.map((item) => WeighingSlip.fromJson(item)).toList();
      _currentPage = response.page;
      _totalPages = (response.total / response.pageSize).ceil();
      _totalRecords = response.total;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _slipsWithCredit = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load payments for a specific weighing slip
  Future<void> loadPaymentsForSlip(int weighingSlipId) async {
    try {
      _payments = await _paymentService.getPaymentsForSlip(weighingSlipId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Create a payment
  Future<PaymentResponse> createPayment(CreatePaymentRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _paymentService.createPayment(request);
      print(  'CreatePaymentResponse: ${response.success}');
      if (response.success == true) {
        // Refresh the list of slips with credit
        await loadSlipsWithCredit();
      } else {
        _error = response.error ?? 'Une erreur est survenue';
      }

      return response;
    } catch (e) {
      _error = e.toString();
      return PaymentResponse(
        success: false,
        error: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get total credit amount across all slips
  double get totalCreditAmount {
    return _slipsWithCredit.fold(
      0.0,
      (sum, slip) => sum + (slip.remainingCredit ?? 0),
    );
  }

  /// Get count of slips with credit
  int get slipsWithCreditCount => _totalRecords;
}
