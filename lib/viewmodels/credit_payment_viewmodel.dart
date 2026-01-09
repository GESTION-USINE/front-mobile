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
  List<WeighingSlip> _allSlipsWithCredit = []; // Store all items before filtering
  List<Payment> _payments = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  
  // Filters
  String _searchQuery = '';
  String? _dateFrom;
  String? _dateTo;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<WeighingSlip> get slipsWithCredit => _slipsWithCredit;
  List<Payment> get payments => _payments;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalRecords => _totalRecords;
  String get searchQuery => _searchQuery;
  String? get dateFromFilter => _dateFrom;
  String? get dateToFilter => _dateTo;

  /// Apply local search filter across all fields
  void _applySearchFilter() {
    if (_allSlipsWithCredit.isEmpty) {
      _slipsWithCredit = [];
      return;
    }
    
    if (_searchQuery.isEmpty) {
      _slipsWithCredit = List.from(_allSlipsWithCredit);
      return;
    }
    
    final query = _searchQuery.toLowerCase();
    _slipsWithCredit = _allSlipsWithCredit.where((slip) {
      return (slip.slipNumber?.toLowerCase().contains(query) ?? false) ||
             (slip.clientName?.toLowerCase().contains(query) ?? false) ||
             (slip.materialName?.toLowerCase().contains(query) ?? false) ||
             (slip.weightTons.toString().contains(query)) ||
             (slip.totalAmount.toString().contains(query)) ||
             ((slip.totalPaid ?? 0).toString().contains(query)) ||
             ((slip.remainingCredit ?? 0).toString().contains(query));
    }).toList();
  }

  /// Search slips with credit (local filtering)
  void searchSlips(String query) {
    _searchQuery = query;
    _applySearchFilter();
    notifyListeners();
  }

  /// Set date filters and reload from server
  void filterByDateRange(String? from, String? to) {
    _dateFrom = from;
    _dateTo = to;
    _currentPage = 1;
    loadSlipsWithCredit();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _dateFrom = null;
    _dateTo = null;
    _currentPage = 1;
    loadSlipsWithCredit();
  }

  /// Load all weighing slips with remaining credit
  Future<void> loadSlipsWithCredit({
    int? clientId,
    int page = 1,
    int pageSize = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _paymentService.getSlipsWithCredit(
        clientId: clientId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        page: page,
        pageSize: pageSize,
      );

      _allSlipsWithCredit = response.items.map((item) => WeighingSlip.fromJson(item)).toList();
      _applySearchFilter();
      _currentPage = response.page;
      _totalPages = (response.total / response.pageSize).ceil();
      _totalRecords = response.total;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _slipsWithCredit = [];
      _allSlipsWithCredit = [];
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
      print(  'CreatePaymentResponse: ${response}');
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
