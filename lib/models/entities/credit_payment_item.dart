class CreditPaymentItem {
  final int id;
  final int weighingSlipId;
  final String slipNumber;
  final int clientId;
  final String clientName;
  final String clientType;
  final String paymentType;
  final double amountPaid;
  final String createdBy;
  final DateTime createdAt;

  CreditPaymentItem({
    required this.id,
    required this.weighingSlipId,
    required this.slipNumber,
    required this.clientId,
    required this.clientName,
    required this.clientType,
    required this.paymentType,
    required this.amountPaid,
    required this.createdBy,
    required this.createdAt,
  });

  factory CreditPaymentItem.fromJson(Map<String, dynamic> json) {
    return CreditPaymentItem(
      id: json['id'] as int,
      weighingSlipId: json['weighing_slip_id'] as int,
      slipNumber: json['slip_number'] as String? ?? '',
      clientId: json['client_id'] as int,
      clientName: json['client_name'] as String? ?? '',
      clientType: json['client_type'] as String? ?? '',
      paymentType: json['payment_type'] as String? ?? '',
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
