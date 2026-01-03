/// Période pour les statistiques d'overview
class OverviewPeriod {
  final String from;
  final String to;

  OverviewPeriod({
    required this.from,
    required this.to,
  });

  factory OverviewPeriod.fromJson(Map<String, dynamic> json) {
    return OverviewPeriod(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

/// Bloc ventes
class SalesOverview {
  final int slipsCount;
  final double salesTotal;
  final double totalWeightTons;

  SalesOverview({
    required this.slipsCount,
    required this.salesTotal,
    required this.totalWeightTons,
  });

  factory SalesOverview.fromJson(Map<String, dynamic> json) {
    return SalesOverview(
      slipsCount: json['slips_count'] as int? ?? 0,
      salesTotal: (json['sales_total'] as num?)?.toDouble() ?? 0.0,
      totalWeightTons: (json['total_weight_tons'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slips_count': slipsCount,
      'sales_total': salesTotal,
      'total_weight_tons': totalWeightTons,
    };
  }
}

/// Bloc factures
class InvoicesOverview {
  final int count;
  final double invoicesTotal;

  InvoicesOverview({
    required this.count,
    required this.invoicesTotal,
  });

  factory InvoicesOverview.fromJson(Map<String, dynamic> json) {
    return InvoicesOverview(
      count: json['count'] as int? ?? 0,
      invoicesTotal: (json['invoices_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'invoices_total': invoicesTotal,
    };
  }
}

/// Bloc paiements
class PaymentsOverview {
  final double paymentsTotal;
  final double cashTotal;
  final double checkTotal;
  final double guaranteeCheckTotal;

  PaymentsOverview({
    required this.paymentsTotal,
    required this.cashTotal,
    required this.checkTotal,
    required this.guaranteeCheckTotal,
  });

  factory PaymentsOverview.fromJson(Map<String, dynamic> json) {
    return PaymentsOverview(
      paymentsTotal: (json['payments_total'] as num?)?.toDouble() ?? 0.0,
      cashTotal: (json['cash_total'] as num?)?.toDouble() ?? 0.0,
      checkTotal: (json['check_total'] as num?)?.toDouble() ?? 0.0,
      guaranteeCheckTotal:
          (json['guarantee_check_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payments_total': paymentsTotal,
      'cash_total': cashTotal,
      'check_total': checkTotal,
      'guarantee_check_total': guaranteeCheckTotal,
    };
  }
}

/// Bloc crédits
class CreditOverview {
  final double remainingTotal;
  final int remainingSlipsCount;

  CreditOverview({
    required this.remainingTotal,
    required this.remainingSlipsCount,
  });

  factory CreditOverview.fromJson(Map<String, dynamic> json) {
    return CreditOverview(
      remainingTotal: (json['remaining_total'] as num?)?.toDouble() ?? 0.0,
      remainingSlipsCount: json['remaining_slips_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'remaining_total': remainingTotal,
      'remaining_slips_count': remainingSlipsCount,
    };
  }
}

/// Bloc dépenses
class ExpensesOverview {
  final double expensesTotal;
  final double maintenanceTotal;
  final double salariesTotal;

  ExpensesOverview({
    required this.expensesTotal,
    required this.maintenanceTotal,
    required this.salariesTotal,
  });

  factory ExpensesOverview.fromJson(Map<String, dynamic> json) {
    return ExpensesOverview(
      expensesTotal: (json['expenses_total'] as num?)?.toDouble() ?? 0.0,
      maintenanceTotal: (json['maintenance_total'] as num?)?.toDouble() ?? 0.0,
      salariesTotal: (json['salaries_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenses_total': expensesTotal,
      'maintenance_total': maintenanceTotal,
      'salaries_total': salariesTotal,
    };
  }
}

/// Statistiques d'overview globales
class OverviewStats {
  final OverviewPeriod period;
  final SalesOverview sales;
  final InvoicesOverview invoices;
  final PaymentsOverview payments;
  final CreditOverview credit;
  final ExpensesOverview expenses;
  final double netCashflow;

  OverviewStats({
    required this.period,
    required this.sales,
    required this.invoices,
    required this.payments,
    required this.credit,
    required this.expenses,
    required this.netCashflow,
  });

  factory OverviewStats.fromJson(Map<String, dynamic> json) {
    return OverviewStats(
      period:
          OverviewPeriod.fromJson(json['period'] as Map<String, dynamic>? ?? {}),
      sales: SalesOverview.fromJson(json['sales'] as Map<String, dynamic>? ?? {}),
      invoices: InvoicesOverview.fromJson(
          json['invoices'] as Map<String, dynamic>? ?? {}),
      payments: PaymentsOverview.fromJson(
          json['payments'] as Map<String, dynamic>? ?? {}),
      credit:
          CreditOverview.fromJson(json['credit'] as Map<String, dynamic>? ?? {}),
      expenses: ExpensesOverview.fromJson(
          json['expenses'] as Map<String, dynamic>? ?? {}),
      netCashflow: (json['net_cashflow'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'sales': sales.toJson(),
      'invoices': invoices.toJson(),
      'payments': payments.toJson(),
      'credit': credit.toJson(),
      'expenses': expenses.toJson(),
      'net_cashflow': netCashflow,
    };
  }
}
