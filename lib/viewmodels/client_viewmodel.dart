import 'package:dio/dio.dart';
import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';

import '../models/entities/client.dart';
import '../models/request/create_client_request.dart';
import '../models/request/update_client_request.dart';
import '../services/client_service.dart';

/// ViewModel pour gérer les clients
class ClientViewModel extends BaseViewModel {
  final ClientService _clientService;

  ClientViewModel(this._clientService);

  List<Client> _clients = [];
  List<Client> get clients => _clients;
  

  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _total > 0 ? (_total / _pageSize).ceil() : 1;
  int get total => _total;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Filtres
  String? _searchQuery;
  String? _typeFilter;
  bool? _canPayByCheckFilter;
  bool? _isActiveFilter;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  String? get searchQuery => _searchQuery;
  String? get typeFilter => _typeFilter;
  bool? get canPayByCheckFilter => _canPayByCheckFilter;
  bool? get isActiveFilter => _isActiveFilter;

  bool get hasClients => _clients.isNotEmpty;

  /// Générer une clé cache unique basée sur les paramètres de filtre
  String _generateCacheKey({
    required int page,
    required int pageSize,
    String? search,
    String? type,
    bool? canPayByCheck,
    bool? isActive,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) {
    return 'clients_'
        'p${page}_ps${pageSize}_'
        's${search ?? 'null'}_'
        't${type ?? 'null'}_'
        'c${canPayByCheck ?? 'null'}_'
        'ia${isActive ?? 'null'}_'
        'sb${sortBy}_so${sortOrder}';
  }

  /// Charge la liste des clients avec cache intelligent
  Future<void> loadClients({
    bool refresh = false,
    int? pageSize,
    int? isActive,
  }) async {
    if (refresh) {
      _currentPage = 1;
      // Nettoyer le cache pour les clients lors d'un refresh explicite
      clearCacheEntry(_generateCacheKey(
        page: 1,
        pageSize: _pageSize,
        search: _searchQuery,
        type: _typeFilter,
        canPayByCheck: _canPayByCheckFilter,
        isActive: _isActiveFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      ));
    }
    
    // Mettre à jour le pageSize si fourni
    if (pageSize != null) {
      _pageSize = pageSize;
    }
    if (isActive != null) {
      _isActiveFilter = isActive == 1 ? true : false;
    }

    // Générer la clé cache
    final cacheKey = _generateCacheKey(
      page: _currentPage,
      pageSize: _pageSize,
      search: _searchQuery,
      type: _typeFilter,
      canPayByCheck: _canPayByCheckFilter,
      isActive: _isActiveFilter,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
    );

    // 🔥 Vérifier le cache en premier
    if (isCacheValid(cacheKey)) {
      final cachedResult = getCacheEntry(cacheKey);
      if (cachedResult != null) {
        _clients = cachedResult['items'] as List<Client>;
        _currentPage = cachedResult['page'] as int;
        _pageSize = cachedResult['pageSize'] as int;
        _total = cachedResult['total'] as int;
        setSuccess();
        return; // 👈 Pas d'appel API!
      }
    }

    final result = await runAsync(() async {
      return await _clientService.getClients(
        search: _searchQuery,
        type: _typeFilter,
        canPayByCheck: _canPayByCheckFilter,
        isActive: _isActiveFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });

    if (result != null) {
      _clients = result.items;
      _currentPage = result.page;
      _pageSize = result.pageSize;
      _total = result.total;
      
      // 💾 Mettre en cache le résultat
      setCacheEntry(cacheKey, {
        'items': result.items,
        'page': result.page,
        'pageSize': result.pageSize,
        'total': result.total,
      });
      
      notifyListeners();
    }
  }
    
  /// Recherche des clients
  void searchClients(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    loadClients();
  }

  /// Filtre par type
  void filterByType(String? type) {
    _typeFilter = type;
    _currentPage = 1;
    loadClients();
  }

  /// Filtre par paiement par chèque
  void filterByCanPayByCheck(bool? canPayByCheck) {
    _canPayByCheckFilter = canPayByCheck;
    _currentPage = 1;
    loadClients();
  }

  /// Filtre par statut actif
  void filterByIsActive(bool? isActive) {
    _isActiveFilter = isActive;
    _currentPage = 1;
    loadClients();
  }

  /// Change le tri
  void changeSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadClients();
  }

  /// Réinitialise les filtres
  void resetFilters() {
    _searchQuery = null;
    _typeFilter = null;
    _canPayByCheckFilter = null;
    _isActiveFilter = null;
    _sortBy = 'created_at';
    _sortOrder = 'desc';
    _currentPage = 1;
    loadClients();
  }

  /// Page suivante
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadClients();
    }
  }

  /// Page précédente
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadClients();
    }
  }

  /// Va à une page spécifique
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      await loadClients();
    }
  }

  /// Crée un nouveau client
  Future<bool> createClient(CreateClientRequest request) async {
    final result = await runAsync(() async {
      return await _clientService.createClient(request);
    });

    if (result != null) {
      // Nettoyer le cache après création
      clearAllCache();
      // Recharger la liste après création
      await loadClients(refresh: true);
      return true;
    }
    return false;
  }

  /// Met à jour un client existant
  Future<bool> updateClient(int clientId, UpdateClientRequest request) async {
    setLoading();
    try {
      final updated = await _clientService.updateClient(clientId, request);
      // On a réussi
      clearAllCache();
      await loadClients(refresh: true);
      setSuccess();
      return true;
    } on DioException catch (e) {
      // Parser erreur structurée du backend si présente
      String message = 'Une erreur est survenue';
      if (e.error is Map<String, dynamic>) {
        final err = e.error as Map<String, dynamic>;
        final code = err['code'] ?? '';
        final details = err['details'] as Map<String, dynamic>? ?? {};
        switch (code) {
          case 'CLIENT_CREDIT_LIMIT_TOO_SMALL':
            final proposed = details['credit_limit'] ?? 0;
            final current = details['current_total_remaining_credit'] ?? 0;
            final deficit = details['deficit'] ?? 0;
            message = 'La limite de crédit ne peut pas être inférieure au crédit existant\n\n'
                'Limite proposée: ${proposed.toStringAsFixed(2)} DZD\n'
                'Crédit restant actuel: ${current.toStringAsFixed(2)} DZD\n'
                'Déficit: ${deficit.toStringAsFixed(2)} DZD';
            break;
          default:
            message = err['message'] ?? message;
        }
      } else if (e.response?.data != null) {
        final resp = e.response!.data;
        if (resp is Map<String, dynamic> && resp['error'] != null) {
          final err = resp['error'] as Map<String, dynamic>;
          final code = err['code'] ?? '';
          final details = err['details'] as Map<String, dynamic>? ?? {};
          if (code == 'CLIENT_CREDIT_LIMIT_TOO_SMALL') {
            final proposed = details['credit_limit'] ?? 0;
            final current = details['current_total_remaining_credit'] ?? 0;
            final deficit = details['deficit'] ?? 0;
            message = 'La limite de crédit ne peut pas être inférieure au crédit existant\n\n'
                'Limite proposée: ${proposed.toStringAsFixed(2)} DZD\n'
                'Crédit restant actuel: ${current.toStringAsFixed(2)} DZD\n'
                'Déficit: ${deficit.toStringAsFixed(2)} DZD';
          } else {
            message = err['message'] ?? message;
          }
        }
      }
      setError(message);
      return false;
    } catch (e) {
      setError('Une erreur inattendue est survenue');
      return false;
    }
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadClients(refresh: true);
  }

  /// Charge tous les clients actifs sans pagination pour les dropdowns
  Future<List<Client>> getAllActiveClients() async {
    final result = await runAsync(() async {
      return await _clientService.getClients(
        isActive: true,
        page: 1,
        pageSize: 10000,
      );
    });

    if (result != null) {
      return result.items;
    }
    return [];
  }
}
