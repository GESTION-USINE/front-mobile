class ClientsCreditResponse {
  final List<ClientCredit> items;
  final int page;
  final int pageSize;
  final int total;

  ClientsCreditResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  int get totalPages => (total / pageSize).ceil();

  factory ClientsCreditResponse.fromJson(Map<String, dynamic> json) {
    // Handle the actual data structure: response.data returns {status, data: {items, meta}}
    final dataObject = json['data'] as Map<String, dynamic>? ?? {};
    final itemsJson = dataObject['items'] as List? ?? [];
    final items = itemsJson
        .map((item) => ClientCredit.fromJson(item as Map<String, dynamic>))
        .toList();

    // Get pagination from meta.pagination
    final meta = dataObject['meta'] as Map<String, dynamic>? ?? {};
    final pagination = meta['pagination'] as Map<String, dynamic>? ?? {};

    return ClientsCreditResponse(
      items: items,
      page: pagination['page'] as int? ?? 1,
      pageSize: pagination['pageSize'] as int? ?? 10,
      total: pagination['total'] as int? ?? 0,
    );
  }
}

class ClientCredit {
  final int id;
  final String name;
  final String type;
  final String? email;
  final String? phone;
  final String? taxId;
  final bool canPayByCheck;
  final bool isActive;
  final DateTime createdAt;
  final double totalRemainingCredit;
  final int slipsCount;
  final List<CreditSlip> slips;

  ClientCredit({
    required this.id,
    required this.name,
    required this.type,
    this.email,
    this.phone,
    this.taxId,
    required this.canPayByCheck,
    required this.isActive,
    required this.createdAt,
    required this.totalRemainingCredit,
    required this.slipsCount,
    required this.slips,
  });

  factory ClientCredit.fromJson(Map<String, dynamic> json) {
    final slipsJson = json['slips'] as List? ?? [];
    final slips = slipsJson
        .map((slip) => CreditSlip.fromJson(slip as Map<String, dynamic>))
        .toList();

    return ClientCredit(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'particulier',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      taxId: json['tax_id'] as String?,
      canPayByCheck: (json['can_pay_by_check'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      totalRemainingCredit: (json['total_remaining_credit'] as num?)?.toDouble() ?? 0.0,
      slipsCount: json['slips_count'] as int? ?? 0,
      slips: slips,
    );
  }
}

class CreditSlip {
  final int id;
  final String slipNumber;
  final CreditMaterial material;
  final double weightTons;
  final double totalAmount;
  final double totalPaid;
  final double remainingCredit;
  final bool isFullyPaid;
  final DateTime createdAt;

  CreditSlip({
    required this.id,
    required this.slipNumber,
    required this.material,
    required this.weightTons,
    required this.totalAmount,
    required this.totalPaid,
    required this.remainingCredit,
    required this.isFullyPaid,
    required this.createdAt,
  });

  factory CreditSlip.fromJson(Map<String, dynamic> json) {
    return CreditSlip(
      id: json['id'] as int? ?? 0,
      slipNumber: json['slip_number'] as String? ?? '',
      material: CreditMaterial.fromJson(json['material'] as Map<String, dynamic>? ?? {}),
      weightTons: (json['weight_tons'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      remainingCredit: (json['remaining_credit'] as num?)?.toDouble() ?? 0.0,
      isFullyPaid: (json['is_fully_paid'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

class CreditMaterial {
  final int id;
  final String name;

  CreditMaterial({
    required this.id,
    required this.name,
  });

  factory CreditMaterial.fromJson(Map<String, dynamic> json) {
    return CreditMaterial(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',    );
  }
}