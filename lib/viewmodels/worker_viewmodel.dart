import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm_template/models/entities/worker.dart';
import 'package:flutter_mvvm_template/models/request/create_worker_request.dart';
import 'package:flutter_mvvm_template/models/request/update_worker_request.dart';
import 'package:flutter_mvvm_template/services/worker_service.dart';

/// ViewModel pour gérer les travailleurs
class WorkerViewModel extends BaseViewModel {
  final WorkerService _workerService;

  WorkerViewModel(this._workerService);

  List<Worker> _workers = [];

  List<Worker> get workers => _workers;

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
  bool? _isActiveFilter;
  String? _searchQuery;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  bool? get isActiveFilter => _isActiveFilter;
  String? get searchQuery => _searchQuery;

  bool get hasWorkers => _workers.isNotEmpty;

  // ==================== Cache Methods ====================

  /// Générer une clé cache unique basée sur les paramètres de filtre
  String _generateCacheKey() {
    return 'workers_p${_currentPage}_ps${_pageSize}_ia${_isActiveFilter}_s${_searchQuery}_sb${_sortBy}_so${_sortOrder}';
  }

  /// Charge la liste des travailleurs
  Future<void> loadWorkers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      clearAllCache();
    }

    final cacheKey = _generateCacheKey();

    // 💾 Vérifier le cache d'abord
    if (!refresh && isCacheValid(cacheKey)) {
      final cachedData = getCacheEntry<Map<String, dynamic>>(cacheKey);
      if (cachedData != null) {
        _workers = cachedData['workers'] ?? [];
        _total = cachedData['total'] ?? 0;
        notifyListeners();
        return;
      }
    }

    final result = await runAsync(() async {
      return await _workerService.getWorkers(
        isActive: _isActiveFilter,
        search: _searchQuery,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });
    if (result != null) {
      _workers = result.items.cast<Worker>().toList();
      _total = result.meta.total;

      // 💾 Mettre en cache le résultat (50 minutes)
      setCacheEntry(
        cacheKey,
        {'workers': _workers, 'total': _total},
        cacheDuration: const Duration(minutes: 50),
      );

      notifyListeners();
    }
  }

  /// Recherche des travailleurs
  void searchWorkers(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    loadWorkers();
  }

  /// Filtre par statut actif
  void filterByIsActive(bool? isActive) {
    _isActiveFilter = isActive;
    _currentPage = 1;
    loadWorkers();
  }

  /// Change le tri
  void changeSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadWorkers();
  }

  /// Réinitialise les filtres
  void resetFilters() {
    _searchQuery = null;
    _isActiveFilter = null;
    _sortBy = 'created_at';
    _sortOrder = 'desc';
    _currentPage = 1;
    loadWorkers();
  }

  /// Page suivante
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadWorkers();
    }
  }

  /// Page précédente
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadWorkers();
    }
  }

  /// Va à une page spécifique
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      await loadWorkers();
    }
  }

  /// Récupère un travailleur par ID
  Future<Worker?> getWorkerById(int id) async {
    return await runAsync(() async {
      return await _workerService.getWorkerById(id);
    });
  }

  /// Crée un nouveau travailleur
  Future<bool> createWorker(CreateWorkerRequest request) async {
    final result = await runAsync(() async {
      return await _workerService.createWorker(request);
    });

    if (result != null) {
      // Vider le cache et recharger la liste après création
      clearAllCache();
      await loadWorkers(refresh: true);
      return true;
    }
    return false;
  }

  /// Met à jour un travailleur existant
  Future<bool> updateWorker(int id, UpdateWorkerRequest request) async {
    final result = await runAsync(() async {
      return await _workerService.updateWorker(id, request);
    });

    if (result != null) {
      // Vider le cache et recharger la liste après mise à jour
      clearAllCache();
      await loadWorkers(refresh: true);
      return true;
    }
    return false;
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadWorkers(refresh: true);
  }
}
