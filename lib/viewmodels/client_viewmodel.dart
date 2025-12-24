import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';

import '../models/entities/client.dart';
import '../models/request/create_client_request.dart';
import '../services/client_service.dart';

/// ViewModel pour gérer les clients
class ClientViewModel extends BaseViewModel {
  final ClientService _clientService;

  ClientViewModel(this._clientService);

  List<Client> _clients = [];
  List<Client> get clients => _clients;

  int _currentPage = 1;
  final int _pageSize = 20;
  int _total = 0;
  int get currentPage => _currentPage;
  int get totalPages => (_total / _pageSize).ceil();
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

  /// Charge la liste des clients
  Future<void> loadClients({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
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
      _total = result.total;
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
      // Recharger la liste après création
      await loadClients(refresh: true);
      return true;
    }
    return false;
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadClients(refresh: true);
  }
}
