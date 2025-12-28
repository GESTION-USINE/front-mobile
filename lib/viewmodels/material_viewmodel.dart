import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm_template/models/entities/material_price.dart';
import 'package:flutter_mvvm_template/core/constants/api_endpoints.dart';
import 'package:flutter_mvvm_template/models/response/delete_response.dart';

import '../core/network/api_client.dart';
import '../models/entities/material.dart';
import '../models/request/create_material_request.dart';
import '../models/request/update_material_request.dart';
import '../services/material_service.dart';
import '../di/injection_container.dart';

/// ViewModel pour gérer les matériaux
class MaterialViewModel extends BaseViewModel {
  final MaterialService _materialService;

  MaterialViewModel(this._materialService);

  List<Material> _materials = [];
  List<MaterialPriceItem> _materialPrices = [];

  List<MaterialPriceItem> get materialPrices => _materialPrices;

  List<Material> get materials => _materials;

  int _currentPage = 1;
  int _pageSize = 50;
  int _total = 0;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _total > 0 ? (_total / _pageSize).ceil() : 1;
  int get total => _total;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Filtres
  String? _searchQuery;
  String? _categoryFilter;
  bool? _isActiveFilter;
  String _sortBy = 'name';
  String _sortOrder = 'asc';

  String? get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  bool? get isActiveFilter => _isActiveFilter;

  bool get hasMaterials => _materials.isNotEmpty;



  Future<void> loadClientMaterialPrices({
    required int clientId,
    bool refresh = false,
    }) async {
      if (refresh) {
        _currentPage = 1;
      }

      final result = await runAsync(() async {
        return await _materialService.getClientMaterialPrices(
          clientId: clientId,
          page: _currentPage,
          pageSize: _pageSize,
        );
      });

      if (result != null) {
              _materialPrices = result.items.map((item) {
           if (item is MaterialPriceItem) return item;
          return MaterialPriceItem.fromJson(item as Map<String, dynamic>);
        }).toList();
        _currentPage = result.page;
        _pageSize = result.pageSize;
        _total = result.total;

        notifyListeners();
      }
    }

   Future<bool> createClientMaterialPrice({
      required int clientId,
      required int materialId,
      required double customPricePerTon,
    }) async {
      final result = await runAsync(() async {
       return await _materialService.createClientMaterialPrice(
          clientId: clientId,
          materialId: materialId,
          customPricePerTon: customPricePerTon,
        );
      });

      if (result != null) {
        // Recharger les prix du client après création
        await loadClientMaterialPrices(
          clientId: clientId,
          refresh: true,
        );
        return true;
      }
      return false;
    }
  
   Future<bool> deleteClientMaterialPrice({
      required int priceId,
      required int clientId,
    }) async {
      DeleteResponse? result = await runAsync(() async {
       return await _materialService.deleteClientMaterialPrice(
          priceId: priceId,
        );
      });

      if (result!.deleted) {
        // Recharger la liste après suppression
        await loadClientMaterialPrices(
          clientId: clientId,
          refresh: true,
        );
        return true ; 
      }
      return false ; 
    }

  /// Charge la liste des matériaux
  Future<void> loadMaterials({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    final result = await runAsync(() async {
      return await _materialService.getMaterials(
        search: _searchQuery,
        category: _categoryFilter,
        isActive: _isActiveFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });

    if (result != null) {
      _materials = result.items.map((item) {
        if (item is Material) return item;
        return Material.fromJson(item as Map<String, dynamic>);
      }).toList();
      _currentPage = result.page;
      _pageSize = result.pageSize;
      _total = result.total;
      notifyListeners();
    }
  }

  /// Recherche des matériaux
  void searchMaterials(String query) {
    _searchQuery = query.isEmpty ? null : query;
    _currentPage = 1;
    loadMaterials();
  }

  /// Filtre par catégorie
  void filterByCategory(String? category) {
    _categoryFilter = category;
    _currentPage = 1;
    loadMaterials();
  }

  /// Filtre par statut actif
  void filterByIsActive(bool? isActive) {
    _isActiveFilter = isActive;
    _currentPage = 1;
    loadMaterials();
  }

  /// Change le tri
  void changeSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadMaterials();
  }

  /// Réinitialise les filtres
  void resetFilters() {
    _searchQuery = null;
    _categoryFilter = null;
    _isActiveFilter = null;
    _sortBy = 'name';
    _sortOrder = 'asc';
    _currentPage = 1;
    loadMaterials();
  }

  /// Page suivante
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadMaterials();
    }
  }

  /// Page précédente
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadMaterials();
    }
  }

  /// Va à une page spécifique
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      await loadMaterials();
    }
  }

  /// Crée un nouveau matériau
  Future<bool> createMaterial(CreateMaterialRequest request) async {
    final result = await runAsync(() async {
      return await _materialService.createMaterial(request);
    });
    if (result != null) {
      // Recharger la liste après création
      await loadMaterials(refresh: true);
      return true;
    }
    return false;
  }

  /// Met à jour un matériau existant
  Future<bool> updateMaterial(int materialId, UpdateMaterialRequest request) async {
    final result = await runAsync(() async {
      return await _materialService.updateMaterial(materialId, request);
    });

    if (result != null) {
      // Recharger la liste après mise à jour
      await loadMaterials(refresh: true);
      return true;
    }
    return false;
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadMaterials(refresh: true);
  }

  /// Sauvegarde les prix spéciaux d'un client (batch)
  /// Format: [ { 'material_id': int, 'custom_price_per_ton': double|null }, ... ]
  Future<bool> saveClientMaterialPrices({
    required int clientId,
    required List<Map<String, dynamic>> prices,
  }) async {
    final result = await runAsync(() async {
      final response = await getIt<ApiClient>().post(
        ApiEndpoints.clientMaterialPrices,
        data: {
          'client_id': clientId,
          'prices': prices,
        },
      );
      final status = response.statusCode ?? 200;
      return status >= 200 && status < 300;
    });

    if (result == true) {
      await loadClientMaterialPrices(clientId: clientId, refresh: true);
      return true;
    }

    return false;
  }
}
