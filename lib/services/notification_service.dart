import 'package:dio/dio.dart';

import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../models/response/notifications_response.dart';

/// Service pour gérer les notifications
class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  /// Récupère les notifications de l'utilisateur avec filtres et pagination
  Future<NotificationsResponse> getNotifications({
    bool? isRead,
    String? type,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'sort_by': sortBy,
        'sort_order': sortOrder,
        'page': page,
        'page_size': pageSize,
      };

      if (isRead != null) {
        queryParams['is_read'] = isRead.toString();
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }

      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      return NotificationsResponse.fromJson(response.data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notificationsUnreadCount,
      );
       print("unread count response: ${response.data['data']['unread_count']}");
      return response.data['data']['unread_count'] as int;
    } on DioException {
      rethrow;
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.notificationMarkAsRead(notificationId),
      );
    } on DioException {
      rethrow;
    }
  }
}
