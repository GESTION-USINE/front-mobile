import '../entities/notification_item.dart';

/// Réponse pour la liste des notifications avec pagination
class NotificationsResponse {
  final List<NotificationItem> items;
  final int page;
  final int pageSize;
  final int total;

  NotificationsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    final pagination = meta['pagination'] as Map<String, dynamic>;

    return NotificationsResponse(
      items: (data['items'] as List)
          .map((item) => NotificationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      pageSize: pagination['pageSize'] as int,
      total: pagination['total'] as int,
    );
  }

  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}
