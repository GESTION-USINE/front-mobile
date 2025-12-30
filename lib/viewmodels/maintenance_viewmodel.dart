import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm_template/models/entities/maintenance_expense.dart';
import 'package:flutter_mvvm_template/models/request/create_maintenance_expense_request.dart';
import 'package:flutter_mvvm_template/models/request/update_maintenance_expense_request.dart';
import 'package:flutter_mvvm_template/services/maintenance_service.dart';

/// ViewModel pour gérer les dépenses de maintenance
class MaintenanceViewModel extends BaseViewModel {
  final MaintenanceService _maintenanceService;

  MaintenanceViewModel(this._maintenanceService);

  List<MaintenanceExpense> _maintenanceExpenses = [];

  List<MaintenanceExpense> get maintenanceExpenses => _maintenanceExpenses;

  int _currentPage = 1;
  int _pageSize = 10;
  int _total = 0;
  double _totalCost = 0.0;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _total > 0 ? (_total / _pageSize).ceil() : 1;
  int get total => _total;
  double get totalCost => _totalCost;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  // Filtres
  DateTime? _dateFromFilter;
  DateTime? _dateToFilter;
  String? _machineTypeFilter;
  String _sortBy = 'maintenance_date';
  String _sortOrder = 'desc';

  DateTime? get dateFromFilter => _dateFromFilter;
  DateTime? get dateToFilter => _dateToFilter;
  String? get machineTypeFilter => _machineTypeFilter;

  bool get hasMaintenanceExpenses => _maintenanceExpenses.isNotEmpty;

  /// Charge la liste des dépenses de maintenance
  Future<void> loadMaintenanceExpenses({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    try {
      final result = await runAsync(() async {
        return await _maintenanceService.getMaintenanceExpenses(
          dateFrom: _dateFromFilter,
          dateTo: _dateToFilter,
          machineType: _machineTypeFilter,
          sortBy: _sortBy,
          sortOrder: _sortOrder,
          page: _currentPage,
          pageSize: _pageSize,
        );
      });


      if (result != null) {
      _maintenanceExpenses = result.items.cast<MaintenanceExpense>().toList();

    
        _total = result.meta.total;
        _totalCost = result.meta.totalCost;
        notifyListeners();
      }
    } catch (e, stackTrace) {
      print("EXCEPTION CAUGHT: $e");
      print("STACK TRACE: $stackTrace");
    }
  }

  /// Filtre par plage de dates
  void filterByDateRange(DateTime? dateFrom, DateTime? dateTo) {
    _dateFromFilter = dateFrom;
    _dateToFilter = dateTo;
    _currentPage = 1;
    loadMaintenanceExpenses();
  }

  /// Filtre par type de machine
  void filterByMachineType(String? machineType) {
    _machineTypeFilter = machineType;
    _currentPage = 1;
    loadMaintenanceExpenses();
  }

  /// Change le tri
  void changeSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadMaintenanceExpenses();
  }

  /// Réinitialise les filtres
  void resetFilters() {
    _dateFromFilter = null;
    _dateToFilter = null;
    _machineTypeFilter = null;
    _sortBy = 'maintenance_date';
    _sortOrder = 'desc';
    _currentPage = 1;
    loadMaintenanceExpenses();
  }

  /// Page suivante
  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadMaintenanceExpenses();
    }
  }

  /// Page précédente
  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadMaintenanceExpenses();
    }
  }

  /// Va à une page spécifique
  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= totalPages) {
      _currentPage = page;
      await loadMaintenanceExpenses();
    }
  }

  /// Récupère une dépense de maintenance par ID
  Future<MaintenanceExpense?> getMaintenanceExpenseById(int id) async {
    return await runAsync(() async {
      return await _maintenanceService.getMaintenanceExpenseById(id);
    });
  }

  /// Crée une nouvelle dépense de maintenance
  Future<bool> createMaintenanceExpense(
    CreateMaintenanceExpenseRequest request,
  ) async {
    final result = await runAsync(() async {
      return await _maintenanceService.createMaintenanceExpense(request);
    });

    if (result != null) {
      // Recharger la liste après création
      await loadMaintenanceExpenses(refresh: true);
      return true;
    }
    return false;
  }

  /// Met à jour une dépense de maintenance existante
  Future<bool> updateMaintenanceExpense(
    int id,
    UpdateMaintenanceExpenseRequest request,
  ) async {
    final result = await runAsync(() async {
      return await _maintenanceService.updateMaintenanceExpense(id, request);
    });

    if (result != null) {
      // Recharger la liste après mise à jour
      await loadMaintenanceExpenses(refresh: true);
      return true;
    }
    return false;
  }

  /// Supprime une dépense de maintenance
  Future<bool> deleteMaintenanceExpense(int id) async {
    final result = await runAsync(() async {
      await _maintenanceService.deleteMaintenanceExpense(id);
      return true;
    });

    if (result == true) {
      // Recharger la liste après suppression
      await loadMaintenanceExpenses(refresh: true);
      return true;
    }
    return false;
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadMaintenanceExpenses(refresh: true);
  }
}
