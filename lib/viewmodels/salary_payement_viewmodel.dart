import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm_template/models/entities/salary_payment.dart';
import 'package:flutter_mvvm_template/models/request/create_salary_payment_request.dart';
import 'package:flutter_mvvm_template/services/salary_payement.dart';

/// ViewModel pour gérer les paiements de salaire
class SalaryPaymentViewModel extends BaseViewModel {
  final SalaryPaymentService _salaryPaymentService;

  SalaryPaymentViewModel(this._salaryPaymentService);

  List<SalaryPayment> _salaryPayments = [];

  List<SalaryPayment> get salaryPayments => _salaryPayments;

  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;
  double _totalAmount = 0.0;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _total > 0 ? (_total / _pageSize).ceil() : 1;
  int get total => _total;
  double get totalAmount => _totalAmount;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Filtres
  int? _workerIdFilter;
  String? _paymentMonthFilter;
  DateTime? _dateFromFilter;
  DateTime? _dateToFilter;
  String _sortBy = 'payment_month';
  String _sortOrder = 'desc';

  int? get workerIdFilter => _workerIdFilter;
  String? get paymentMonthFilter => _paymentMonthFilter;
  DateTime? get dateFromFilter => _dateFromFilter;
  DateTime? get dateToFilter => _dateToFilter;

  bool get hasSalaryPayments => _salaryPayments.isNotEmpty;

  /// Charge la liste des paiements de salaire
  Future<void> loadSalaryPayments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }
    
    final result = await runAsync(() async {

      return await _salaryPaymentService.getSalaryPayments(
        workerId: _workerIdFilter,
        paymentMonth: _paymentMonthFilter,
        dateFrom: _dateFromFilter,
        dateTo: _dateToFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });
    if (result != null) {
      _salaryPayments = result.items;
      _total = result.total;
      _totalAmount = result.totalAmount;
      notifyListeners();
    }
  }

  /// Filtre par travailleur
  void filterByWorkerId(int? workerId) {
    _workerIdFilter = workerId;
    _currentPage = 1;
    loadSalaryPayments();
  }

  /// Filtre par mois de paiement
  void filterByPaymentMonth(String? paymentMonth) {
    _paymentMonthFilter = paymentMonth;
    _currentPage = 1;
    loadSalaryPayments();
  }

  /// Filtre par période (date de début et fin)
  void filterByDateRange(DateTime? dateFrom, DateTime? dateTo) {
    _dateFromFilter = dateFrom;
    _dateToFilter = dateTo;
    _currentPage = 1;
    loadSalaryPayments();
  }

  /// Change le tri
  void changeSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadSalaryPayments();
  }

  /// Réinitialise les filtres
  void resetFilters() {
    _workerIdFilter = null;
    _paymentMonthFilter = null;
    _dateFromFilter = null;
    _dateToFilter = null;
    _sortBy = 'payment_month';
    _sortOrder = 'desc';
    _currentPage = 1;
    loadSalaryPayments();
  }

  /// Page suivante
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadSalaryPayments();
    }
  }

  /// Page précédente
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadSalaryPayments();
    }
  }

  /// Va à une page spécifique
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      await loadSalaryPayments();
    }
  }

  /// Crée un nouveau paiement de salaire
  Future<bool> createSalaryPayment(CreateSalaryPaymentRequest request) async {
    final result = await runAsync(() async {
      return await _salaryPaymentService.createSalaryPayment(request);
    });


    if (result != null) {
      // Recharger la liste après création
      await loadSalaryPayments(refresh: true);
      return true;
    }
    return false;
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadSalaryPayments(refresh: true);
  }
}
