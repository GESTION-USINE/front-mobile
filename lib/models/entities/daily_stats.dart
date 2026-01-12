/// Modèle représentant les données des bons de pesée dans les stats quotidiennes
class WeighingSlipsStats {
  final int count;
  final String totalWeightTons;
  final String totalAmount;
  final List<MaterialSummary> materials;

  WeighingSlipsStats({
    required this.count,
    required this.totalWeightTons,
    required this.totalAmount,
    this.materials = const [],
  });

  factory WeighingSlipsStats.fromJson(Map<String, dynamic> json) {
    return WeighingSlipsStats(
      count: json['count'] as int? ?? 0,
      totalWeightTons: (json['total_weight_tons'] is num)
          ? (json['total_weight_tons'] as num).toString()
          : (json['total_weight_tons'] as String? ?? '0'),
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toString()
          : (json['total_amount'] as String? ?? '0'),
      materials: (json['materials'] as List<dynamic>?)
              ?.map((m) => MaterialSummary.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'total_weight_tons': totalWeightTons,
      'total_amount': totalAmount,
      'materials': materials.map((m) => m.toJson()).toList(),
    };
  }
}

class MaterialSummary {
  final int materialId;
  final String materialName;
  final String totalWeightTons;
  final double totalAmount;

  MaterialSummary({
    required this.materialId,
    required this.materialName,
    required this.totalWeightTons,
    required this.totalAmount,
  });

  factory MaterialSummary.fromJson(Map<String, dynamic> json) {
    return MaterialSummary(
      materialId: json['material_id'] as int? ?? 0,
      materialName: json['material_name'] as String? ?? '',
      totalWeightTons: (json['total_weight_tons'] is num)
          ? (json['total_weight_tons'] as num).toString()
          : (json['total_weight_tons'] as String? ?? '0'),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'material_name': materialName,
      'total_weight_tons': totalWeightTons,
      'total_amount': totalAmount,
    };
  }
}

/// Modèle représentant les données des factures dans les stats quotidiennes
class InvoicesStats {
  final int count;
  final double totalAmount;

  InvoicesStats({
    required this.count,
    required this.totalAmount,
  });

  factory InvoicesStats.fromJson(Map<String, dynamic> json) {
    return InvoicesStats(
      count: json['count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'total_amount': totalAmount,
    };
  }
}

/// Modèle représentant les données des paiements dans les stats quotidiennes
class DailyPaymentsStats {
  final String cashTotal;
  final double checkTotal;
  final double guaranteeCheckTotal;
  final String total;
  final double initialPaymentsTotal ;
  final double initialPaymentsTotalCash;
  final double initialPaymentsTotalCheck;
  final double versementsTotal;
  final double versementsTotalCash;
  final double versementsTotalCheck;
  final double encaissementTotal;

  DailyPaymentsStats({
    required this.cashTotal,
    required this.checkTotal,
    required this.guaranteeCheckTotal,
    required this.total,
    required this.initialPaymentsTotal,
    required this.initialPaymentsTotalCash,
    required this.initialPaymentsTotalCheck,
    required this.versementsTotal,
    required this.versementsTotalCash,
    required this.versementsTotalCheck,
    required this.encaissementTotal,
  });

  factory DailyPaymentsStats.fromJson(Map<String, dynamic> json) {
    return DailyPaymentsStats(
      cashTotal: (json['cash_total'] is num)
          ? (json['cash_total'] as num).toString()
          : (json['cash_total'] as String? ?? '0'),
      checkTotal: (json['check_total'] as num?)?.toDouble() ?? 0.0,
      guaranteeCheckTotal:
          (json['guarantee_check_total'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] is num) ? (json['total'] as num).toString() : (json['total'] as String? ?? '0'),
      initialPaymentsTotal: (json['initial_payments_total'] as num?)?.toDouble() ?? 0.0,
      initialPaymentsTotalCash: (json['initial_payments_total_cash'] as num?)?.toDouble() ?? 0.0,
      initialPaymentsTotalCheck: (json['initial_payments_total_check'] as num?)?.toDouble() ?? 0.0,
      versementsTotal: (json['versements_total'] as num?)?.toDouble() ?? 0.0,
      versementsTotalCash: (json['versements_total_cash'] as num?)?.toDouble() ?? 0.0,
      versementsTotalCheck: (json['versements_total_check'] as num?)?.toDouble() ?? 0.0,
      encaissementTotal: (json['encaissement_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash_total': cashTotal,
      'check_total': checkTotal,
      'guarantee_check_total': guaranteeCheckTotal,
      'total': total,
      'initial_payments_total': initialPaymentsTotal,
      'initial_payments_total_cash': initialPaymentsTotalCash,
      'initial_payments_total_check': initialPaymentsTotalCheck,
      'versements_total': versementsTotal,
      'versements_total_cash': versementsTotalCash,
      'versements_total_check': versementsTotalCheck,
      'encaissement_total': encaissementTotal,
    };
  }
}

/// Modèle représentant les données des crédits dans les stats quotidiennes
class CreditStats {
  final String totalCreated;
  final String totalCollected;
  final double remaining;

  CreditStats({
    required this.totalCreated,
    required this.totalCollected,
    required this.remaining,
  });

  factory CreditStats.fromJson(Map<String, dynamic> json) {
    return CreditStats(
      totalCreated: (json['total_created'] is num)
          ? (json['total_created'] as num).toString()
          : (json['total_created'] as String? ?? '0'),
      totalCollected: (json['total_collected'] is num)
          ? (json['total_collected'] as num).toString()
          : (json['total_collected'] as String? ?? '0'),
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_created': totalCreated,
      'total_collected': totalCollected,
      'remaining': remaining,
    };
  }
}

/// Modèle représentant les statistiques quotidiennes complètes
class DailyStats {
  final String date;
  final WeighingSlipsStats weighingSlips;
  final InvoicesStats invoices;
  final DailyPaymentsStats payments;
  final CreditStats credit;

  DailyStats({
    required this.date,
    required this.weighingSlips,
    required this.invoices,
    required this.payments,
    required this.credit,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'] as String? ?? '',
      weighingSlips: WeighingSlipsStats.fromJson(
          json['weighing_slips'] as Map<String, dynamic>? ?? {}),
      invoices: InvoicesStats.fromJson(
          json['invoices'] as Map<String, dynamic>? ?? {}),
      payments: DailyPaymentsStats.fromJson(
          json['payments'] as Map<String, dynamic>? ?? {}),
      credit: CreditStats.fromJson(
          json['credit'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'weighing_slips': weighingSlips.toJson(),
      'invoices': invoices.toJson(),
      'payments': payments.toJson(),
      'credit': credit.toJson(),
    };
  }
}
