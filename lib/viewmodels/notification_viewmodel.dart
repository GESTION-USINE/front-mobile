import '../core/base/base_viewmodel.dart';
import '../models/entities/notification_item.dart';
import '../services/notification_service.dart';

/// ViewModel pour gérer les notifications
class NotificationViewModel extends BaseViewModel {
  final NotificationService _notificationService;

  NotificationViewModel(this._notificationService);

  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  int _currentPage = 1;
  int _pageSize = 20;
  int _total = 0;

  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  int get totalPages => _total > 0 ? (_total / _pageSize).ceil() : 1;
  int get total => _total;
  bool get hasNextPage => _currentPage < totalPages;
  bool get hasPreviousPage => _currentPage > 1;

  bool? _isReadFilter;
  String? _typeFilter;
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  bool _unreadCountLoaded = false;

  bool? get isReadFilter => _isReadFilter;
  String? get typeFilter => _typeFilter;

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    }

    final result = await runAsync(() async {
      return await _notificationService.getNotifications(
        isRead: _isReadFilter,
        type: _typeFilter,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
        pageSize: _pageSize,
      );
    });

    if (result != null) {
      _notifications = result.items;
      _currentPage = result.page;
      _pageSize = result.pageSize;
      _total = result.total;
      notifyListeners();
      
      // Charger le count des non lues
      await loadUnreadCount();
    }
  }

  void filterByReadStatus(bool? isRead) {
    _isReadFilter = isRead;
    _currentPage = 1;
    loadNotifications();
  }

  void filterByType(String? type) {
    _typeFilter = type;
    _currentPage = 1;
    loadNotifications();
  }

  void changeSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    loadNotifications();
  }

  void resetFilters() {
    _isReadFilter = null;
    _typeFilter = null;
    _sortBy = 'created_at';
    _sortOrder = 'desc';
    _currentPage = 1;
    loadNotifications();
  }

  Future<void> nextPage() async {
    if (hasNextPage) {
      _currentPage++;
      await loadNotifications();
    }
  }

  Future<void> previousPage() async {
    if (hasPreviousPage) {
      _currentPage--;
      await loadNotifications();
    }
  }

  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  /// Charge le nombre de notifications non lues
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      print('Unread notifications count: $count');
      _unreadCount = count;
      _unreadCountLoaded = true;
      notifyListeners();
    } catch (e) {
      // Ignorer les erreurs silencieusement pour ne pas bloquer l'UI
      print('Failed to load unread notifications count: $e');
    }
  }

  void ensureUnreadCountLoaded() {
    if (_unreadCountLoaded) return;
    loadUnreadCount();
  }

  /// Marque une notification comme lue
  Future<bool> markNotificationAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      
      // Mettre à jour localement la notification
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Note: On devrait créer une copie avec isRead = true
        // Pour l'instant on recharge la liste
        await loadNotifications();
        await loadUnreadCount();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
