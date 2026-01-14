/// Entité Invoice (Facture)
class Invoice {
  final int id;
  final String invoiceNumber;
  final int clientId;
  final String? clientName;
  final String? clientType;
  final String? clientPhone;
  final String? clientAddress;
  final double totalAmount;
  final double totalPaid;
  final double remainingCredit;
  final int weighingSlipsCount;
  final int fullyPaidCount;
  final int creditCount;
  final List<InvoiceWeighingSlip>? weighingSlips;
  final InvoiceCreator? creator;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.clientId,
    this.clientName,
    this.clientType,
    this.clientPhone,
    this.clientAddress,
    required this.totalAmount,
    this.totalPaid = 0,
    this.remainingCredit = 0,
    this.weighingSlipsCount = 0,
    this.fullyPaidCount = 0,
    this.creditCount = 0,
    this.weighingSlips,
    this.creator,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    // Parse client info
    final client = json['client'] as Map<String, dynamic>?;
    
    // Parse weighing slips if present
    List<InvoiceWeighingSlip>? slips;
    if (json['weighing_slips'] != null) {
      slips = (json['weighing_slips'] as List)
          .map((e) => InvoiceWeighingSlip.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse creator if present
    InvoiceCreator? creator;
    if (json['created_by'] is Map<String, dynamic>) {
      creator = InvoiceCreator.fromJson(json['created_by'] as Map<String, dynamic>);
    }
   final response = Invoice(
      id: json['id'] as int,
      invoiceNumber: json['invoice_number'] as String,
      clientId: (json['client_id'] as int?) ?? (client?['id'] as int?) ?? 0,
      clientName: client?['name'] as String?,
      clientType: client?['type'] as String?,
      clientPhone: client?['phone'] as String?,
      clientAddress: client?['address'] as String?,
      totalAmount: ((json['total_amount'] as num?) ?? 0).toDouble(),
      totalPaid: ((json['total_paid'] as num?) ?? 0).toDouble(),
      remainingCredit: ((json['remaining_credit'] as num?) ?? 0).toDouble(),
      weighingSlipsCount: (json['weighing_slips_count'] as int?) ?? 0,
      fullyPaidCount: (json['fully_paid_count'] as int?) ?? 0,
      creditCount: (json['credit_count'] as int?) ?? 0,
      weighingSlips: slips,
      creator: creator,
      createdBy: json['created_by'] is int ? json['created_by'] as int : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      deletedAt: json['deleted_at'] != null 
          ? DateTime.parse(json['deleted_at'] as String) 
          : null,
    );  

    print("INVOICE PARSED:");
    print(response);
    return response ; 
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'client_id': clientId,
      'client': {
        'id': clientId,
        'name': clientName,
        'type': clientType,
        'phone': clientPhone,
        'address': clientAddress,
      },
      'total_amount': totalAmount,
      'total_paid': totalPaid,
      'remaining_credit': remainingCredit,
      'weighing_slips_count': weighingSlipsCount,
      'fully_paid_count': fullyPaidCount,
      'credit_count': creditCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  /// Vérifie si la facture est entièrement payée
  bool get isFullyPaid => remainingCredit <= 0;
}

/// Bon de pesée inclus dans une facture
class InvoiceWeighingSlip {
  final int id;
  final String? slipNumber;
  final String? materialName;
  final double weightTons;
  final double pricePerTon;
  final double totalAmount;
  final double totalPaid;
  final double remainingCredit;
  final bool isFullyPaid;
  final DateTime createdAt;

  InvoiceWeighingSlip({
    required this.id,
    this.slipNumber,
    this.materialName,
    required this.weightTons,
    required this.pricePerTon,
    required this.totalAmount,
    this.totalPaid = 0,
    this.remainingCredit = 0,
    this.isFullyPaid = false,
    required this.createdAt,
  });

  factory InvoiceWeighingSlip.fromJson(Map<String, dynamic> json) {
    return InvoiceWeighingSlip(
      id: json['id'] as int,
      slipNumber: json['slip_number'] as String?,
      materialName: json['material_name'] as String?,
      weightTons: ((json['weight_tons'] as num?) ?? 0).toDouble(),
      pricePerTon: ((json['price_per_ton'] as num?) ?? 0).toDouble(),
      totalAmount: ((json['total_amount'] as num?) ?? 0).toDouble(),
      totalPaid: ((json['total_paid'] as num?) ?? 0).toDouble(),
      remainingCredit: ((json['remaining_credit'] as num?) ?? 0).toDouble(),
      isFullyPaid: (json['is_fully_paid'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Créateur de la facture
class InvoiceCreator {
  final int id;
  final String username;
  final String role;

  InvoiceCreator({
    required this.id,
    required this.username,
    required this.role,
  });

  factory InvoiceCreator.fromJson(Map<String, dynamic> json) {
    return InvoiceCreator(
      id: json['id'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }
}
