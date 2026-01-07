class ClientsWithSlipsResponse {
  final List<ClientWithSlips> items;
  final int page;
  final int pageSize;
  final int total;

  ClientsWithSlipsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  int get totalPages => (total / pageSize).ceil();

  factory ClientsWithSlipsResponse.fromJson(Map<String, dynamic> json) {
    final dataObject = json['data'] as Map<String, dynamic>? ?? {};
    final itemsJson = dataObject['items'] as List? ?? [];
    final items = itemsJson
        .map((item) => ClientWithSlips.fromJson(item as Map<String, dynamic>))
        .toList();

    final meta = dataObject['meta'] as Map<String, dynamic>? ?? {};
    final pagination = meta['pagination'] as Map<String, dynamic>? ?? {};

    return ClientsWithSlipsResponse(
      items: items,
      page: pagination['page'] as int? ?? 1,
      pageSize: pagination['pageSize'] as int? ?? 10,
      total: pagination['total'] as int? ?? 0,
    );
  }
}

class ClientWithSlips {
  final int id;
  final String name;
  final String type;
  final String? phone;
  final String? email;
  final String? taxId;
  final bool canPayByCheck;
  final bool isActive;
  final DateTime createdAt;
  final int slipsCount;
  final int slipsWithActiveCredit;
  final int fullyPaidSlips;
  final double totalAmount;
  final double totalPaid;
  final double totalRemainingCredit;
  final List<SlipSummary> slips;

  ClientWithSlips({
    required this.id,
    required this.name,
    required this.type,
    this.phone,
    this.email,
    this.taxId,
    required this.canPayByCheck,
    required this.isActive,
    required this.createdAt,
    required this.slipsCount,
    required this.slipsWithActiveCredit,
    required this.fullyPaidSlips,
    required this.totalAmount,
    required this.totalPaid,
    required this.totalRemainingCredit,
    required this.slips,
  });

  factory ClientWithSlips.fromJson(Map<String, dynamic> json) {
    return ClientWithSlips(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? 'particulier',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      taxId: json['tax_id'] as String?,
      canPayByCheck: (json['can_pay_by_check'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      slipsCount: json['slips_count'] as int? ?? 0,
      slipsWithActiveCredit: json['slips_with_active_credit'] as int? ?? 0,
      fullyPaidSlips: json['fully_paid_slips'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      totalRemainingCredit: (json['total_remaining_credit'] as num?)?.toDouble() ?? 0.0,
      slips: (json['slips'] as List?)
              ?.map((s) => SlipSummary.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SlipSummary {
  final int id;
  final String slipNumber;
  final Material material;
  final double weightTons;
  final double totalAmount;
  final double totalPaid;
  final double remainingCredit;
  final bool isFullyPaid;
  final DateTime createdAt;

  SlipSummary({
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

  factory SlipSummary.fromJson(Map<String, dynamic> json) {
    return SlipSummary(
      id: json['id'] as int? ?? 0,
      slipNumber: json['slip_number'] as String? ?? '',
      material: Material.fromJson(json['material'] as Map<String, dynamic>? ?? {}),
      weightTons: (json['weight_tons'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      remainingCredit: (json['remaining_credit'] as num?)?.toDouble() ?? 0.0,
      isFullyPaid: (json['is_fully_paid'] as bool?) ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

class Material {
  final int id;
  final String name;

  Material({
    required this.id,
    required this.name,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}
