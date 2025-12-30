import 'package:dio/dio.dart';
import '../models/entities/maintenance_expense.dart';
import '../models/request/create_maintenance_expense_request.dart';
import '../models/request/update_maintenance_expense_request.dart';
import '../models/response/maintenance_expenses_response.dart';
import '../core/network/api_client.dart';

/// Service pour gérer les dépenses de maintenance
class MaintenanceService {
  final ApiClient _apiClient;

  MaintenanceService(this._apiClient);

  /// Récupère la liste des dépenses de maintenance avec filtres, tri et pagination
  Future<MaintenanceExpensesResponse> getMaintenanceExpenses({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? machineType,
    String sortBy = 'maintenance_date',
    String sortOrder = 'desc',
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String().split('T')[0];
      }
      if (machineType != null && machineType.isNotEmpty) {
        queryParams['machine_type'] = machineType;
      }
     
      final response = await _apiClient.get(
        '/maintenance-expenses',
        queryParameters: queryParams,
      );
      
      
      try {
        final result = MaintenanceExpensesResponse.fromJson(response.data);
       
        
        return result;
      } catch (e) {
        rethrow;
      }
    } on DioException {
      rethrow;
    }
  }

  /// Récupère une dépense de maintenance par son ID
  Future<MaintenanceExpense> getMaintenanceExpenseById(int id) async {
    try {
      final response = await _apiClient.get('/maintenance-expenses/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return MaintenanceExpense.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Crée une nouvelle dépense de maintenance
  Future<MaintenanceExpense> createMaintenanceExpense(
    CreateMaintenanceExpenseRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/maintenance-expenses',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return MaintenanceExpense.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Met à jour une dépense de maintenance existante
  Future<MaintenanceExpense> updateMaintenanceExpense(
    int id,
    UpdateMaintenanceExpenseRequest request,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/maintenance-expenses/$id',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return MaintenanceExpense.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Supprime une dépense de maintenance
  Future<void> deleteMaintenanceExpense(int id) async {
    try {
      await _apiClient.delete('/maintenance-expenses/$id');
    } on DioException {
      rethrow;
    }
  }
}
