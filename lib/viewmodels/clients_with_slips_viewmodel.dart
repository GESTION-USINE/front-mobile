import 'package:flutter/material.dart';
import '../models/response/clients_with_slips_response.dart';
import '../services/client_service.dart';

class ClientsWithSlipsViewModel extends ChangeNotifier {
  final ClientService _clientService;

  ClientsWithSlipsViewModel(this._clientService);

  // State
  bool _isLoading = false;
  String? _error;
  List<ClientWithSlips> _clients = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;
  final int _pageSize = 20;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ClientWithSlips> get clients => _clients;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalRecords => _totalRecords;

  /// Load all clients with their slips and credit information
  Future<void> loadClientsWithSlips({
    int page = 1,
    String sortBy = 'total_remaining_credit',
    String sortOrder = 'desc',
  }) async {
    _isLoading = true;
    _error = null;
    _currentPage = page;
    notifyListeners();

    try {
      final response = await _clientService.getAllClientsWithCredit(
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
    } catch (e) {
      _error = e.toString();
      _clients = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get total credit across all clients
  double get totalCredit {
    return _clients.fold(
      0.0,
      (sum, client) => sum + client.totalRemainingCredit,
    );
  }

  /// Get total number of clients
  int get totalClients {
    return _clients.length;
  }

  /// Get total number of slips
  int get totalSlips {
    return _clients.fold(
      0,
      (sum, client) => sum + client.slipsCount,
    );
  }

  /// Get total number of slips with active credit
  int get totalSlipsWithCredit {
    return _clients.fold(
      0,
      (sum, client) => sum + client.slipsWithActiveCredit,
    );
  }
}
