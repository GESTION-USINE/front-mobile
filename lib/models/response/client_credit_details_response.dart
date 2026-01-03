class ClientCreditDetailsResponse {
  final ClientInfo client;
  final CreditSummary creditSummary;
  final List<SlipDetail> slips;

  ClientCreditDetailsResponse({
    required this.client,
    required this.creditSummary,
    required this.slips,
  });

  factory ClientCreditDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    return ClientCreditDetailsResponse(
      client: ClientInfo.fromJson(data['client'] as Map<String, dynamic>? ?? {}),
      creditSummary: CreditSummary.fromJson(data['credit_summary'] as Map<String, dynamic>? ?? {}),
      slips: (data['slips'] as List?)
              ?.map((s) => SlipDetail.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ClientInfo {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String type;
  final String? address;
  final String? taxId;
  final bool canPayByCheck;
  final bool isActive;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ClientInfo({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.type,
    this.address,
    this.taxId,
    required this.canPayByCheck,
    required this.isActive,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      type: json['type'] as String? ?? 'particulier',
      address: json['address'] as String?,
      taxId: json['tax_id'] as String?,
      canPayByCheck: (json['can_pay_by_check'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

class CreditSummary {
  final int totalSlips;
  final int slipsWithActiveCredit;
  final int fullyPaidSlips;
  final double totalAmount;
  final double totalPaid;
  final double totalRemainingCredit;

  CreditSummary({
    required this.totalSlips,
    required this.slipsWithActiveCredit,
    required this.fullyPaidSlips,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalRemainingCredit,
  });

  factory CreditSummary.fromJson(Map<String, dynamic> json) {
    return CreditSummary(
      totalSlips: json['total_slips'] as int? ?? 0,
      slipsWithActiveCredit: json['slips_with_active_credit'] as int? ?? 0,
      fullyPaidSlips: json['fully_paid_slips'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      totalRemainingCredit: (json['total_remaining_credit'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SlipDetail {
  final int id;
  final String slipNumber;
  final String materialName;
  final double weightTons;
  final double pricePerTon;
  final double totalAmount;
  final double totalPaid;
  final double remainingCredit;
  final bool isFullyPaid;
  final int paymentsCount;
  final List<PaymentDetail> payments;
  final DateTime createdAt;
  final String? firstPaymentDate;
  final String? lastPaymentDate;
  final int? paymentDurationDays;
  final int createdBy;

  SlipDetail({
    required this.id,
    required this.slipNumber,
    required this.materialName,
    required this.weightTons,
    required this.pricePerTon,
    required this.totalAmount,
    required this.totalPaid,
    required this.remainingCredit,
    required this.isFullyPaid,
    required this.paymentsCount,
    required this.payments,
    required this.createdAt,
    this.firstPaymentDate,
    this.lastPaymentDate,
    this.paymentDurationDays,
    required this.createdBy,
  });

  factory SlipDetail.fromJson(Map<String, dynamic> json) {
    return SlipDetail(
      id: json['id'] as int,
      slipNumber: json['slip_number'] as String? ?? '',
      materialName: json['material']?['name'] as String? ?? '',
      weightTons: (json['weight_tons'] as num?)?.toDouble() ?? 0.0,
      pricePerTon: (json['price_per_ton'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      remainingCredit: (json['remaining_credit'] as num?)?.toDouble() ?? 0.0,
      isFullyPaid: json['is_fully_paid'] as bool? ?? false,
      paymentsCount: json['payments_count'] as int? ?? 0,
      payments: (json['payments'] as List?)
              ?.map((p) => PaymentDetail.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      firstPaymentDate: json['first_payment_date'] as String?,
      lastPaymentDate: json['last_payment_date'] as String?,
      paymentDurationDays: json['payment_duration_days'] as int?,
      createdBy: json['created_by'] as int? ?? 0,
    );
  }
}

class PaymentDetail {
  final int id;
  final String paymentType;
  final double amountPaid;
  final String paymentDate;
  final String? checkNumber;
  final String? checkDate;
  final String? checkBank;
  final String? checkStatus;
  final String? notes;
  final String? createdByUsername;
  final int createdBy;
  final DateTime? createdAt;

  PaymentDetail({
    required this.id,
    required this.paymentType,
    required this.amountPaid,
    required this.paymentDate,
    this.checkNumber,
    this.checkDate,
    this.checkBank,
    this.checkStatus,
    this.notes,
    this.createdByUsername,
    required this.createdBy,
    this.createdAt,
  });

  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      id: json['id'] as int,
      paymentType: json['payment_type'] as String? ?? '',
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] as String? ?? '',
      checkNumber: json['check_number'] as String?,
      checkDate: json['check_date'] as String?,
      checkBank: json['check_bank'] as String?,
      checkStatus: json['check_status'] as String?,
      notes: json['notes'] as String?,
      createdByUsername: json['created_by_username'] as String?,
      createdBy: json['created_by'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
