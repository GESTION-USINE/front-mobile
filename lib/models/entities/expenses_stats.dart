/// Modèle représentant la période des statistiques de dépenses
class ExpensePeriod {
  final String from;
  final String to;

  ExpensePeriod({
    required this.from,
    required this.to,
  });

  factory ExpensePeriod.fromJson(Map<String, dynamic> json) {
    return ExpensePeriod(
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

/// Modèle représentant les totaux des dépenses
class ExpenseTotals {
  final double frais;
  final double salaries;
  final double other;
  final double grandTotal;

  ExpenseTotals({
    required this.frais,
    required this.salaries,
    required this.other,
    required this.grandTotal,
  });

  factory ExpenseTotals.fromJson(Map<String, dynamic> json) {
    return ExpenseTotals(
      frais: (json['frais'] as num?)?.toDouble() ?? 0.0,
      salaries: (json['salaries'] as num?)?.toDouble() ?? 0.0,
      other: (json['other'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frais': frais,
      'salaries': salaries,
      'other': other,
      'grand_total': grandTotal,
    };
  }
}

/// Modèle représentant les statistiques de dépenses
class ExpensesStats {
  final ExpensePeriod period;
  final ExpenseTotals totals;

  ExpensesStats({
    required this.period,
    required this.totals,
  });

  factory ExpensesStats.fromJson(Map<String, dynamic> json) {
    return ExpensesStats(
      period: ExpensePeriod.fromJson(
          json['period'] as Map<String, dynamic>? ?? {}),
      totals:
          ExpenseTotals.fromJson(json['totals'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'totals': totals.toJson(),
    };
  }
}
