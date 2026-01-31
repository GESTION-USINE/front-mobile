class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? relatedPaymentId;
  final int? relatedSlipId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.relatedPaymentId,
    required this.relatedSlipId,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      relatedPaymentId: json['related_payment_id'] as int?,
      relatedSlipId: json['related_slip_id'] as int?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
    );
  }
}
