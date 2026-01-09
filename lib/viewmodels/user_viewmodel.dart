import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class UserViewModel extends BaseViewModel {
  final UserService _userService;

  // Users list section
  UsersListResponse? _usersListResponse;
  String? _listRole;
  bool? _listIsActive;
  String _listSearch = '';
  String _listSortBy = 'created_at';
  String _listSortOrder = 'desc';
  int _listPage = 1;
  final int _listPageSize = 20;

  // Single user section
  User? _selectedUser;

  // Create/Update request (tracked but not currently used)
  // ignore: unused_field
  CreateUserRequest? _createRequest;
  // ignore: unused_field
  UpdateUserRequest? _updateRequest;

  UserViewModel(this._userService);

  // ==================== Getters ====================

  // Users list getters
  UsersListResponse? get usersListResponse => _usersListResponse;
  List<User> get users => _usersListResponse?.items ?? [];
  UsersPagination? get usersPagination => _usersListResponse?.pagination;

  String? get listRole => _listRole;
  bool? get listIsActive => _listIsActive;
  String get listSearch => _listSearch;
  String get listSortBy => _listSortBy;
  String get listSortOrder => _listSortOrder;
  int get listPage => _listPage;

  // Single user getter
  User? get selectedUser => _selectedUser;

  // ==================== Cache Methods ====================

  /// Générer une clé cache unique basée sur les paramètres de filtre
  String _generateCacheKey({
    required int page,
    required int pageSize,
    String? role,
    bool? isActive,
    String? search,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) {
    return 'users_'
        'p${page}_ps${pageSize}_'
        'r${role ?? 'null'}_'
        'ia${isActive ?? 'null'}_'
        's${search ?? 'null'}_'
        'sb${sortBy}_so${sortOrder}';
  }

  // ==================== Setters ====================

  void setListRole(String? role) {
    _listRole = role;
    notifyListeners();
  }

  void setListIsActive(bool? isActive) {
    _listIsActive = isActive;
    notifyListeners();
  }

  void setListSearch(String search) {
    _listSearch = search;
    _listPage = 1;
    notifyListeners();
  }

  void setListSortBy(String sortBy) {
    _listSortBy = sortBy;
    _listPage = 1;
    notifyListeners();
  }

  void setListSortOrder(String sortOrder) {
    _listSortOrder = sortOrder;
    _listPage = 1;
    notifyListeners();
  }

  void setListPage(int page) {
    _listPage = page;
    notifyListeners();
  }

  // ==================== Load Methods ====================

  /// Load users list with current filters avec cache intelligent
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _listPage = 1;
      // Nettoyer le cache lors d'un refresh explicite
      clearCacheEntry(_generateCacheKey(
        page: 1,
        pageSize: _listPageSize,
        role: _listRole,
        isActive: _listIsActive,
        search: _listSearch.isNotEmpty ? _listSearch : null,
        sortBy: _listSortBy,
        sortOrder: _listSortOrder,
      ));
    }

    // Générer la clé cache
    final cacheKey = _generateCacheKey(
      page: _listPage,
      pageSize: _listPageSize,
      role: _listRole,
      isActive: _listIsActive,
      search: _listSearch.isNotEmpty ? _listSearch : null,
      sortBy: _listSortBy,
      sortOrder: _listSortOrder,
    );

    // 🔥 Vérifier le cache en premier
    if (isCacheValid(cacheKey)) {
      final cachedResult = getCacheEntry(cacheKey);
      if (cachedResult != null) {
        _usersListResponse = cachedResult['response'] as UsersListResponse;
        setSuccess();
        return; // 👈 Pas d'appel API!
      }
    }

    await runAsync(() async {
      _usersListResponse = await _userService.getUsers(
        role: _listRole,
        isActive: _listIsActive,
        search: _listSearch.isNotEmpty ? _listSearch : null,
        sortBy: _listSortBy,
        sortOrder: _listSortOrder,
        page: _listPage,
        pageSize: _listPageSize,
      );

      // 💾 Mettre en cache le résultat (30 minutes)
      if (_usersListResponse != null) {
        setCacheEntry(
          cacheKey,
          {'response': _usersListResponse},
          cacheDuration: const Duration(minutes: 30),
        );
      }
    });
  }

  /// Load single user by ID
  Future<void> loadUserById(int userId) async {
    await runAsync(() async {
      _selectedUser = await _userService.getUserById(userId);
    });
  }

  /// Create new user
  Future<void> createUser(CreateUserRequest request) async {
    _createRequest = request;
    await runAsync(() async {
      final newUser = await _userService.createUser(request);
      _selectedUser = newUser;
      // Nettoyer le cache après création
      clearAllCache();
      // Reload users list to include the new user
      await loadUsers(refresh: true);
    });
  }

  /// Update user
  Future<void> updateUser(int userId, UpdateUserRequest request) async {
    _updateRequest = request;
    await runAsync(() async {
      final updatedUser = await _userService.updateUser(userId, request);
      _selectedUser = updatedUser;
      // Nettoyer le cache après mise à jour
      clearAllCache();
      // Reload users list to reflect the update
      await loadUsers(refresh: true);
    });
  }

  /// Deactivate user
  Future<void> deactivateUser(int userId) async {
    await runAsync(() async {
      await _userService.deactivateUser(userId);
      // Nettoyer le cache après désactivation
      clearAllCache();
      // Reload users list to reflect deactivation
      await loadUsers(refresh: true);
    });
  }

  // ==================== Pagination Methods ====================

  Future<void> nextPage() async {
    if (usersPagination?.hasNextPage ?? false) {
      setListPage(_listPage + 1);
      await loadUsers();
    }
  }

  Future<void> previousPage() async {
    if (usersPagination?.hasPreviousPage ?? false) {
      setListPage(_listPage - 1);
      await loadUsers();
    }
  }

  Future<void> goToPage(int page) async {
    setListPage(page);
    await loadUsers();
  }

  // ==================== Refresh Methods ====================

  /// Rafraîchir la liste (force fetch backend)
  Future<void> refresh() async {
    await loadUsers(refresh: true);
  }

  /// Refresh users list with current filters
  Future<void> refreshUsers() async {
    _listPage = 1;
    await loadUsers(refresh: true);
  }

  /// Refresh selected user
  Future<void> refreshSelectedUser(int userId) async {
    await loadUserById(userId);
  }

  /// Refresh all
  Future<void> refreshAll({int? userId}) async {
    await Future.wait([
      loadUsers(),
      if (userId != null) loadUserById(userId),
    ]);
  }

  // ==================== Filter Methods ====================

  /// Apply filters and reset to page 1
  Future<void> applyFilters({
    String? role,
    bool? isActive,
    String? search,
  }) async {
    if (role != null) _listRole = role;
    if (isActive != null) _listIsActive = isActive;
    if (search != null) _listSearch = search;

    _listPage = 1;
    await loadUsers();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _listRole = null;
    _listIsActive = null;
    _listSearch = '';
    _listPage = 1;
    await loadUsers();
  }

  // ==================== Clear Methods ====================

  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  void clearCreateRequest() {
    _createRequest = null;
    notifyListeners();
  }

  void clearUpdateRequest() {
    _updateRequest = null;
    notifyListeners();
  }
}
