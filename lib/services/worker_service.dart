import 'package:dio/dio.dart';
import '../models/entities/worker.dart';
import '../models/request/create_worker_request.dart';
import '../models/request/update_worker_request.dart';
import '../models/response/workers_response.dart';
import '../core/network/api_client.dart';

/// Service pour gérer les travailleurs
class WorkerService {
  final ApiClient _apiClient;

  WorkerService(this._apiClient);

  /// Récupère la liste des travailleurs avec filtres, tri et pagination
  Future<WorkersResponse> getWorkers({
    bool? isActive,
    String? search,
    String sortBy = 'created_at',
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

      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiClient.get(
        '/workers',
        queryParameters: queryParams,
      );

      return WorkersResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère un travailleur par son ID
  Future<Worker> getWorkerById(int id) async {
    try {
      final response = await _apiClient.get('/workers/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return Worker.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Crée un nouveau travailleur
  Future<Worker> createWorker(CreateWorkerRequest request) async {
    try {
      final response = await _apiClient.post(
        '/workers',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Worker.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Met à jour un travailleur existant
  Future<Worker> updateWorker(int id, UpdateWorkerRequest request) async {
    try {
      final response = await _apiClient.patch(
        '/workers/$id',
        data: request.toJson(),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return Worker.fromJson(data);
    } on DioException {
      rethrow;
    }
  }
}
