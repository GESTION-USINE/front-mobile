import '../core/base/base_viewmodel.dart';
import '../models/entities/invoice.dart';
import '../models/entities/weighing_slip.dart';
import '../models/request/create_invoice_request.dart';
import '../models/request/update_invoice_request.dart';
import '../services/invoice_service.dart';
import '../services/weighing_slip_service.dart';

class InvoiceViewModel extends BaseViewModel {
  final InvoiceService _invoiceService;
  final WeighingSlipService _weighingSlipService;

  List<Invoice> _items = [];
  List<Invoice> _allItems = [];
  List<Invoice> get items => _items;

  // Facture actuellement sélectionnée (pour les détails)
  Invoice? _selectedInvoice;
  Invoice? get selectedInvoice => _selectedInvoice;

  // Liste des bons non facturés (pour la création de facture)
  List<WeighingSlip> _uninvoicedSlips = [];
  List<WeighingSlip> get uninvoicedSlips => _uninvoicedSlips;

  // Bons sélectionnés pour la création/modification
  List<WeighingSlip> _selectedSlips = [];
  List<WeighingSlip> get selectedSlips => _selectedSlips;

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

  // Filtres
  String? _searchQuery;
  int? _clientId;
  String? _dateFrom;
  String? _dateTo;

  String? get searchQuery => _searchQuery;
  int? get clientIdFilter => _clientId;
  String? get dateFromFilter => _dateFrom;
  String? get dateToFilter => _dateTo;

  InvoiceViewModel(this._invoiceService, this._weighingSlipService);

  /// Générer une clé cache unique
  String _generateCacheKey({
    required int page,
    required int pageSize,
    int? clientId,
    String? dateFrom,
    String? dateTo,
  }) {
    return 'invoices_'
        'p${page}_ps${pageSize}_'
        'c${clientId ?? 'null'}_'
        'df${dateFrom ?? 'null'}_'
        'dt${dateTo ?? 'null'}';
  }

  /// Charger la liste des factures
  Future<void> loadInvoices({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      clearCacheEntry(_generateCacheKey(
        page: 1,
        pageSize: _pageSize,
        clientId: _clientId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
      ));
    }

    final cacheKey = _generateCacheKey(
      page: _currentPage,
      pageSize: _pageSize,
      clientId: _clientId,
      dateFrom: _dateFrom,
      dateTo: _dateTo,
    );

    // Vérifier le cache
    if (isCacheValid(cacheKey)) {
      final cachedResult = getCacheEntry(cacheKey);
      if (cachedResult != null) {
        _allItems = cachedResult['allItems'] as List<Invoice>;
        _items = cachedResult['items'] as List<Invoice>;
        _currentPage = cachedResult['page'] as int;
        _pageSize = cachedResult['pageSize'] as int;
        _total = cachedResult['total'] as int;
        setSuccess();
        return;
      }
    }

    final result = await runAsync(() async {
      return await _invoiceService.getInvoices(
        clientId: _clientId,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });

    if (result != null) {
      _allItems = result.items;
      _applySearchFilter();
      _currentPage = result.page;
      _pageSize = result.pageSize;
      _total = result.total;

      // Mettre en cache
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

  /// Appliquer le filtre de recherche locale
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
    _items = _allItems.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(query) ||
          (invoice.clientName?.toLowerCase().contains(query) ?? false) ||
          invoice.totalAmount.toString().contains(query);
    }).toList();
  }

  /// Rechercher dans les factures
  void searchInvoices(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _applySearchFilter();
    notifyListeners();
  }

  /// Filtrer par client
  void filterByClient(int? clientId) {
    _clientId = clientId;
    _currentPage = 1;
    loadInvoices();
  }

  /// Filtrer par plage de dates
  void filterByDateRange(String? from, String? to) {
    _dateFrom = from;
    _dateTo = to;
    _currentPage = 1;
    loadInvoices();
  }

  /// Réinitialiser les filtres
  void resetFilters() {
    _searchQuery = null;
    _clientId = null;
    _dateFrom = null;
    _dateTo = null;
    _currentPage = 1;
    notifyListeners();
    loadInvoices();
  }

  /// Navigation pagination
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadInvoices();
    }
  }

  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadInvoices();
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      await loadInvoices();
    }
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadInvoices(refresh: true);
  }

  /// Charger les détails d'une facture
  Future<Invoice?> loadInvoiceDetails(int id) async {
    final result = await runAsync(() async {
      return await _invoiceService.getInvoiceById(id);
    });

    if (result != null) {
      _selectedInvoice = result;
      notifyListeners();
    }

    return result;
  }

  /// Charger les bons non facturés pour un client
  Future<void> loadUninvoicedSlips({int? clientId}) async {
    final result = await runAsyncSilent(() async {
      return await _weighingSlipService.getSlips(
        clientId: clientId,
        isInvoiced: false,
        page: 1,
        pageSize: 1000, // Charger tous les bons non facturés
      );
    });

    if (result != null) {
      _uninvoicedSlips = result.items.map((item) {
        if (item is WeighingSlip) return item;
        return WeighingSlip.fromJson(item as Map<String, dynamic>);
      }).toList();
      notifyListeners();
    }
  }

  /// Sélectionner/désélectionner un bon
  void toggleSlipSelection(WeighingSlip slip) {
    if (_selectedSlips.any((s) => s.id == slip.id)) {
      _selectedSlips.removeWhere((s) => s.id == slip.id);
    } else {
      // Vérifier que le bon appartient au même client
      if (_selectedSlips.isNotEmpty && 
          _selectedSlips.first.clientId != slip.clientId) {
        // Ne pas ajouter si client différent
        return;
      }
      _selectedSlips.add(slip);
    }
    notifyListeners();
  }

  /// Vérifier si un bon est sélectionné
  bool isSlipSelected(WeighingSlip slip) {
    return _selectedSlips.any((s) => s.id == slip.id);
  }

  /// Effacer la sélection
  void clearSelection() {
    _selectedSlips.clear();
    notifyListeners();
  }

  /// Calculer le total des bons sélectionnés
  double get selectedSlipsTotal {
    return _selectedSlips.fold(0.0, (sum, slip) => sum + slip.totalAmount);
  }

  /// Créer une facture
  Future<Invoice?> createInvoice(List<int> slipIds) async {
    final request = CreateInvoiceRequest(weighingSlipIds: slipIds);

    final result = await runAsync(() async {
      return await _invoiceService.createInvoice(request);
    });

    if (result != null) {
      clearAllCache();
      _selectedSlips.clear();
      await loadInvoices(refresh: true);
    }

    return result;
  }

  /// Mettre à jour une facture
  Future<Invoice?> updateInvoice(
    int id, {
    List<int>? addSlipIds,
    List<int>? removeSlipIds,
  }) async {
    final request = UpdateInvoiceRequest(
      addSlipIds: addSlipIds,
      removeSlipIds: removeSlipIds,
    );

    final result = await runAsync(() async {
      return await _invoiceService.updateInvoice(id, request);
    });

    if (result != null) {
      clearAllCache();
      await loadInvoices(refresh: true);
    }

    return result;
  }

  /// Supprimer une facture (soft delete)
  Future<bool> deleteInvoice(int id) async {
    final result = await runAsync(() async {
      await _invoiceService.deleteInvoice(id);
      return true;
    });

    if (result == true) {
      _items.removeWhere((inv) => inv.id == id);
      _allItems.removeWhere((inv) => inv.id == id);
      clearAllCache();
      await loadInvoices(refresh: true);
      return true;
    }

    return false;
  }

  /// Statistiques rapides
  int get totalInvoices => _total;
  
  double get totalAmount {
    return _allItems.fold(0.0, (sum, inv) => sum + inv.totalAmount);
  }

  double get totalPaidAmount {
    return _allItems.fold(0.0, (sum, inv) => sum + inv.totalPaid);
  }

  double get totalRemainingCredit {
    return _allItems.fold(0.0, (sum, inv) => sum + inv.remainingCredit);
  }

  int get fullyPaidInvoicesCount {
    return _allItems.where((inv) => inv.isFullyPaid).length;
  }

  int get pendingInvoicesCount {
    return _allItems.where((inv) => !inv.isFullyPaid).length;
  }
}
