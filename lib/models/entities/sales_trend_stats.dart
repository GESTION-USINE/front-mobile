/// Période pour les statistiques de tendance des ventes
class SalesTrendPeriod {
  final String from;
  final String to;

  SalesTrendPeriod({
    required this.from,
    required this.to,
  });

  factory SalesTrendPeriod.fromJson(Map<String, dynamic> json) {
    return SalesTrendPeriod(
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

/// Point de données pour une période (jour, semaine, mois)
class SalesTrendDataPoint {
  final String date;
  final int slipsCount;
  final double totalWeightTons;
  final double salesTotal;

  SalesTrendDataPoint({
    required this.date,
    required this.slipsCount,
    required this.totalWeightTons,
    required this.salesTotal,
  });

  factory SalesTrendDataPoint.fromJson(Map<String, dynamic> json) {
    return SalesTrendDataPoint(
      date: json['date'] as String? ?? '',
      slipsCount: json['slips_count'] as int? ?? 0,
      totalWeightTons: (json['total_weight_tons'] as num?)?.toDouble() ?? 0.0,
      salesTotal: (json['sales_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'slips_count': slipsCount,
      'total_weight_tons': totalWeightTons,
      'sales_total': salesTotal,
    };
  }
}

/// Totaux de la tendance des ventes
class SalesTrendTotals {
  final int slipsCount;
  final double totalWeightTons;
  final double salesTotal;

  SalesTrendTotals({
    required this.slipsCount,
    required this.totalWeightTons,
    required this.salesTotal,
  });

  factory SalesTrendTotals.fromJson(Map<String, dynamic> json) {
    return SalesTrendTotals(
      slipsCount: json['slips_count'] as int? ?? 0,
      totalWeightTons: (json['total_weight_tons'] as num?)?.toDouble() ?? 0.0,
      salesTotal: (json['sales_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slips_count': slipsCount,
      'total_weight_tons': totalWeightTons,
      'sales_total': salesTotal,
    };
  }
}

/// Statistiques de tendance des ventes avec groupage
class SalesTrendStats {
  final SalesTrendPeriod period;
  final String groupBy;
  final List<SalesTrendDataPoint> series;
  final SalesTrendTotals totals;

  SalesTrendStats({
    required this.period,
    required this.groupBy,
    required this.series,
    required this.totals,
  });

  factory SalesTrendStats.fromJson(Map<String, dynamic> json) {
    final seriesList = (json['series'] as List<dynamic>?)
            ?.map((item) =>
                SalesTrendDataPoint.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return SalesTrendStats(
      period: SalesTrendPeriod.fromJson(
          json['period'] as Map<String, dynamic>? ?? {}),
      groupBy: json['group_by'] as String? ?? 'day',
      series: seriesList,
      totals: SalesTrendTotals.fromJson(
          json['totals'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'group_by': groupBy,
      'series': series.map((item) => item.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }
}
