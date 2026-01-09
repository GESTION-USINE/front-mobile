import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import '../models/response/clients_credit_response.dart';
import '../services/client_service.dart';

class ClientsCreditViewModel extends BaseViewModel {
  final ClientService _clientService;

  ClientsCreditViewModel(this._clientService);

  // State
  bool _isLoading = false;
  String? _error;
  List<ClientCredit> _clients = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  final int _pageSize = 10;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClientCredit> get clients => _clients;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalRecords => _totalRecords;

  /// Générer une clé cache unique basée sur les paramètres
  String _generateCacheKey({
    required int page,
    String sortBy = 'remaining_credit',
    String sortOrder = 'desc',
  }) {
    return 'clients_credit_p${page}_sb${sortBy}_so${sortOrder}';
  }

  /// Load clients with credit avec cache intelligent
  Future<void> loadClientsWithCredit({
    int page = 1,
    String sortBy = 'remaining_credit',
    String sortOrder = 'desc',
    bool refresh = false,
  }) async {
    _currentPage = page;

    if (refresh) {
      // Nettoyer le cache lors d'un refresh explicite
      clearCacheEntry(_generateCacheKey(
        page: page,
        sortBy: sortBy,
        sortOrder: sortOrder,
      ));
    }

    // Générer la clé cache
    final cacheKey = _generateCacheKey(
      page: page,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    // 🔥 Vérifier le cache en premier
    if (isCacheValid(cacheKey)) {
      final cachedResult = getCacheEntry(cacheKey);
      if (cachedResult != null) {
        _clients = cachedResult['items'] as List<ClientCredit>;
        _currentPage = cachedResult['page'] as int;
        _totalPages = cachedResult['totalPages'] as int;
        _totalRecords = cachedResult['total'] as int;
        _isLoading = false;
        _error = null;
        setSuccess();
        return; // 👈 Pas d'appel API!
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _clientService.getClientsWithCredit(
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        pageSize: _pageSize,
      );

      _clients = response.items;
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _totalRecords = response.total;
      _error = null;

      // 💾 Mettre en cache le résultat
      setCacheEntry(cacheKey, {
        'items': response.items,
        'page': response.page,
        'totalPages': response.totalPages,
        'total': response.total,
      });

      setSuccess();
    } catch (e) {
      _error = e.toString();
      _clients = [];
      setError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rafraîchir la liste (force fetch backend)
  Future<void> refresh() async {
    await loadClientsWithCredit(
      page: _currentPage,
      refresh: true,
    );
  }

  /// Get total credit across all clients
  double get totalCredit {
    return _clients.fold(
      0.0,
      (sum, client) => sum + client.totalRemainingCredit,
    );
  }

  /// Get total number of slips with credit
  int get totalSlipsWithCredit {
    return _clients.fold(
      0,
      (sum, client) => sum + client.slipsCount,
    );
  }
}
