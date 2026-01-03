class Payment {
  final int id;
  final int weighingSlipId;
  final String paymentType;
  final double amountPaid;
  final DateTime paymentDate;
  final String? checkNumber;
  final DateTime? checkDate;
  final String? checkBank;
  final String? checkStatus;
  final String? notes;
  final int createdBy;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.weighingSlipId,
    required this.paymentType,
    required this.amountPaid,
    required this.paymentDate,
    this.checkNumber,
    this.checkDate,
    this.checkBank,
    this.checkStatus,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      weighingSlipId: json['weighing_slip_id'] as int,
      paymentType: json['payment_type'] as String,
      amountPaid: ((json['amount_paid'] as num?) ?? 0).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      checkNumber: json['check_number'] as String?,
      checkDate: json['check_date'] != null
          ? DateTime.parse(json['check_date'] as String)
          : null,
      checkBank: json['check_bank'] as String?,
      checkStatus: json['check_status'] as String?,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weighing_slip_id': weighingSlipId,
      'payment_type': paymentType,
      'amount_paid': amountPaid,
      'payment_date': paymentDate.toIso8601String(),
      'check_number': checkNumber,
      'check_date': checkDate?.toIso8601String(),
      'check_bank': checkBank,
      'check_status': checkStatus,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
