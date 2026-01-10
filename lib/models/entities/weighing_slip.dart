class WeighingSlip {
  final int id;
  final String? slipNumber;
  final int clientId;
  final String? clientName;
  final int materialId;
  final String? materialName;
  final double weightTons;
  final double pricePerTon;
  final double totalAmount;
  final int? invoiceId;
  final double? totalPaid;
  final double? remainingCredit;
  final bool isFullyPaid;
  final String? paymentType;
  final double? paymentAmount;
  final int createdBy;
  final DateTime createdAt;

  WeighingSlip({
    required this.id,
    this.slipNumber,
    required this.clientId,
    this.clientName,
    required this.materialId,
    this.materialName,
    required this.weightTons,
    required this.pricePerTon,
    required this.totalAmount,
    this.invoiceId,
    this.totalPaid,
    this.remainingCredit,
    required this.isFullyPaid,
    this.paymentType,
    this.paymentAmount,
    required this.createdBy,
    required this.createdAt,
  });

  factory WeighingSlip.fromJson(Map<String, dynamic> json) {
    return WeighingSlip(
      id: json['id'] as int,
      slipNumber: json['slip_number'] as String?,
      clientId: (json['client_id'] as int?) ?? (json['client']?['id'] as int),
      clientName: json['client'] != null ? json['client']['name'] as String? : null,
      materialId: (json['material_id'] as int?) ?? (json['material']?['id'] as int),
      materialName: json['material'] != null ? json['material']['name'] as String? : null,
      weightTons: ((json['weight_tons'] as num?) ?? 0).toDouble(),
      pricePerTon: ((json['price_per_ton'] as num?) ?? 0).toDouble(),
      totalAmount: ((json['total_amount'] as num?) ?? 0).toDouble(),
      invoiceId: json['invoice_id'] as int?,
      totalPaid: (json['credit_info']?['total_paid'] as num?)?.toDouble(),
      remainingCredit: (json['credit_info']?['remaining_credit'] as num?)?.toDouble(),
      isFullyPaid: json['credit_info']?['is_fully_paid'] as bool? ?? json['is_fully_paid'] as bool? ?? false,
      paymentType: json['payment_type'] as String?,
      paymentAmount: (json['payment_amount'] as num?)?.toDouble(),
      createdBy: json['created_by'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slip_number': slipNumber,
      'client_id': clientId,
      'material_id': materialId,
      'weight_tons': weightTons,
      'price_per_ton': pricePerTon,
      'total_amount': totalAmount,
      'invoice_id': invoiceId,
      'credit_info': {
        'total_paid': totalPaid,
        'remaining_credit': remainingCredit,
        'is_fully_paid': isFullyPaid,
      },
      'is_fully_paid': isFullyPaid,
      'payment_type': paymentType,
      'payment_amount': paymentAmount,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
