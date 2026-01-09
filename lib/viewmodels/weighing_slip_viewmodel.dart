import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';

import '../models/entities/weighing_slip.dart';
import '../models/request/create_weighing_slip_request.dart';
import '../models/request/update_weighing_slip_request.dart';
import '../services/weighing_slip_service.dart';

class WeighingSlipViewModel extends BaseViewModel {
  final WeighingSlipService _service;

  List<WeighingSlip> _items = [];
  List<WeighingSlip> _allItems = []; // Store all items before filtering
  List<WeighingSlip> get items => _items;

  // Pagination
  int _currentPage = 1;
  int _pageSize = 20;
  int _total = 0;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get total => _total;
  int get totalPages => _total > 0 ? (_total / _pageSize).ceil() : 1;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Filters
  String? _searchQuery;
  int? _clientId;
  int? _createdBy;
  String? _dateFrom;
  String? _dateTo;
  bool? _isInvoiced;
  bool? _isFullyPaid;
  String? _paymentType;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  WeighingSlipViewModel(this._service) {
    // Set default date filter to today
    final today = DateTime.now();
    _dateFrom = DateTime(today.year, today.month, today.day).toIso8601String().substring(0, 10);
    _dateTo = _dateFrom;
  }

  String? get searchQuery => _searchQuery;
  int? get clientIdFilter => _clientId;
  int? get createdByFilter => _createdBy;
  String? get dateFromFilter => _dateFrom;
  String? get dateToFilter => _dateTo;
  bool? get isInvoicedFilter => _isInvoiced;
  bool? get isFullyPaidFilter => _isFullyPaid;
  String? get paymentTypeFilter => _paymentType ?? '';

  // Stats (for today)
  int get todayTotalCount => _items.length;
  int get todayCreditCount => _items.where((e) => !e.isFullyPaid).length;
  int get todayPaidCount => _items.where((e) => e.isFullyPaid).length;

  /// Générer une clé cache unique basée sur les paramètres de filtre
  String _generateCacheKey({
    required int page,
    required int pageSize,
    String? search,
    int? clientId,
    int? createdBy,
    String? dateFrom,
    String? dateTo,
    bool? isInvoiced,
    bool? isFullyPaid,
    String? paymentType,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) {
    return 'slips_'
        'p${page}_ps${pageSize}_'
        's${search ?? 'null'}_'
        'c${clientId ?? 'null'}_'
        'cb${createdBy ?? 'null'}_'
        'df${dateFrom ?? 'null'}_'
        'dt${dateTo ?? 'null'}_'
        'inv${isInvoiced ?? 'null'}_'
        'paid${isFullyPaid ?? 'null'}_'
        'pt${paymentType ?? 'null'}_'
        'sb${sortBy}_so${sortOrder}';
  }

  Future<void> loadSlips({
    bool refresh = false, 
    bool forceTodayForEmployees = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      // Nettoyer le cache lors d'un refresh explicite
      final df = forceTodayForEmployees ? _todayIsoDate() : _dateFrom;
      final dt = forceTodayForEmployees ? _todayIsoDate() : _dateTo;
      clearCacheEntry(_generateCacheKey(
        page: 1,
        pageSize: _pageSize,
        search: _searchQuery,
        clientId: _clientId,
        createdBy: _createdBy,
        dateFrom: df,
        dateTo: dt,
        isInvoiced: _isInvoiced,
        isFullyPaid: _isFullyPaid,
        paymentType: _paymentType,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      ));
    }

    final String? df = forceTodayForEmployees ? _todayIsoDate() : _dateFrom;
    final String? dt = forceTodayForEmployees ? _todayIsoDate() : _dateTo;

    // Générer la clé cache
    final cacheKey = _generateCacheKey(
      page: _currentPage,
      pageSize: _pageSize,
      search: _searchQuery,
      clientId: _clientId,
      createdBy: _createdBy,
      dateFrom: df,
      dateTo: dt,
      isInvoiced: _isInvoiced,
      isFullyPaid: _isFullyPaid,
      paymentType: _paymentType,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    // 🔥 Vérifier le cache en premier
    if (isCacheValid(cacheKey)) {
      final cachedResult = getCacheEntry(cacheKey);
      if (cachedResult != null) {
        _allItems = cachedResult['allItems'] as List<WeighingSlip>;
        _items = cachedResult['items'] as List<WeighingSlip>;
        _currentPage = cachedResult['page'] as int;
        _pageSize = cachedResult['pageSize'] as int;
        _total = cachedResult['total'] as int;
        setSuccess();
        return; // 👈 Pas d'appel API!
      }
    }

    final result = await runAsync(() async {
      return await _service.getSlips(
        search: _searchQuery,
        clientId: _clientId,
        createdBy: _createdBy,
        dateFrom: df,
        dateTo: dt,
        isInvoiced: _isInvoiced,
        isFullyPaid: _isFullyPaid,
        paymentType: _paymentType,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });

    if (result != null) {
      _allItems = result.items.map((item) {
        if (item is WeighingSlip) return item;
        return WeighingSlip.fromJson(item as Map<String, dynamic>);
      }).toList();
      _applySearchFilter();
      _currentPage = result.page;
      _pageSize = result.pageSize;
      _total = result.total;

      // 💾 Mettre en cache le résultat
      setCacheEntry(cacheKey, {
        'allItems': _allItems,
        'items': _items,
        'page': result.page,
        'pageSize': result.pageSize,
        'total': result.total,
      });

      notifyListeners();
    }
  }

  /// Apply local search filter across all fields
  void _applySearchFilter() {
    if (_allItems.isEmpty) {
      _items = [];
      return;
    }
    
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      _items = _allItems;
      return;
    }
    
    final query = _searchQuery!.toLowerCase();
    _items = _allItems.where((slip) {
      return (slip.slipNumber?.toLowerCase().contains(query) ?? false) ||
             (slip.clientName?.toLowerCase().contains(query) ?? false) ||
             (slip.materialName?.toLowerCase().contains(query) ?? false) ||
             (slip.weightTons.toString().contains(query)) ||
             (slip.totalAmount.toString().contains(query)) ||
             ((slip.totalPaid ?? 0).toString().contains(query)) ||
             ((slip.remainingCredit ?? 0).toString().contains(query)) ||
             ((slip.paymentType ?? '').toLowerCase().contains(query)) ||
             ((slip.isFullyPaid ? 'Payé' : 'Crédit').toLowerCase().contains(query));
    }).toList();
  }

  void searchSlips(String query) { 
    _searchQuery = query.isEmpty ? null : query; 
    _applySearchFilter();
    notifyListeners();
  }
  void filterByClient(int? clientId) { _clientId = clientId; _currentPage = 1; loadSlips(); }
  void filterByCreatedBy(int? userId) { _createdBy = userId; _currentPage = 1; loadSlips(); }
  void filterByDateRange(String? from, String? to) { _dateFrom = from; _dateTo = to; _currentPage = 1; loadSlips(); }
  void filterByInvoiced(bool? invoiced) { _isInvoiced = invoiced; _currentPage = 1; loadSlips(); }
  void filterByFullyPaid(bool? paid) { _isFullyPaid = paid; _currentPage = 1; loadSlips(); }
  void filterByPaymentType(String? type) { _paymentType = type; _currentPage = 1; loadSlips(); }
  void changeSorting(String sortBy, String sortOrder) { _sortBy = sortBy; _sortOrder = sortOrder; _currentPage = 1; loadSlips(); }

  void resetFilters() {
    _searchQuery = null; _clientId = null; _createdBy = null; _dateFrom = null; _dateTo = null; _isInvoiced = null; _isFullyPaid = null; _paymentType = null;
    _sortBy = 'created_at'; _sortOrder = 'desc'; _currentPage = 1; 
    notifyListeners();
    loadSlips();
  }

  Future<void> nextPage() async { if (hasNextPage) { _currentPage++; await loadSlips(); } }
  Future<void> previousPage() async { if (hasPreviousPage) { _currentPage--; await loadSlips(); } }
  Future<void> goToPage(int page) async { if (page >= 1 && page <= totalPages) { _currentPage = page; await loadSlips(); } }

  /// Rafraîchir la liste (force fetch backend)
  Future<void> refresh() async {
    await loadSlips(refresh: true);
  }

  Future<bool> createSlip(CreateWeighingSlipRequest request) async {
    final result = await runAsync(() async { return await _service.createSlip(request); });
    if (result != null) { 
      // Nettoyer le cache après création
      clearAllCache();
      await loadSlips(refresh: true); 
      return true; 
    }
    return false;
  }

  Future<bool> updateSlip(int id, UpdateWeighingSlipRequest request) async {
    final result = await runAsync(() async { return await _service.updateSlip(id, request); });
    if (result != null) { 
      // Nettoyer le cache après mise à jour
      clearAllCache();
      await loadSlips(refresh: true); 
      return true; 
    }
    return false;
  }

  Future<bool> deleteSlip(int id) async {
    final result = await runAsync(() async { await _service.deleteSlip(id); return true; });
    if (result == true) { 
      // Nettoyer le cache après suppression
      clearAllCache();
      await loadSlips(refresh: true); 
      return true; 
    }
    return false;
  }

  String _todayIsoDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).toIso8601String().substring(0,10);
  }
}
