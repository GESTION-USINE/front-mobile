/// Modèle représentant les données de cashflow quotidien
class DailyCashflowData {
  final String date;
  final double encaissementTotal;
  final double creditRestant;
  final double frais;
  final double salaires;
  final double netCashflow;

  DailyCashflowData({
    required this.date,
    required this.encaissementTotal,
    required this.creditRestant,
    required this.frais,
    required this.salaires,
    required this.netCashflow,
  });

  factory DailyCashflowData.fromJson(Map<String, dynamic> json) {
    return DailyCashflowData(
      date: json['date'] as String? ?? '',
      encaissementTotal: (json['encaissement_total'] as num?)?.toDouble() ?? 0.0,
      creditRestant: (json['credit_restant'] as num?)?.toDouble() ?? 0.0,
      frais: (json['frais'] as num?)?.toDouble() ?? 0.0,
      salaires: (json['salaires'] as num?)?.toDouble() ?? 0.0,
      netCashflow: (json['net_cashflow'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'encaissement_total': encaissementTotal,
      'credit_restant': creditRestant,
      'frais': frais,
      'salaires': salaires,
      'net_cashflow': netCashflow,
    };
  }
}

/// Modèle représentant les totaux de cashflow
class CashflowTotals {
  final double totalEncaissement;
  final double totalCreditRestant;
  final double totalFrais;
  final double totalSalaires;
  final double totalNetCashflow;

  CashflowTotals({
    required this.totalEncaissement,
    required this.totalCreditRestant,
    required this.totalFrais,
    required this.totalSalaires,
    required this.totalNetCashflow,
  });

  factory CashflowTotals.fromJson(Map<String, dynamic> json) {
    return CashflowTotals(
      totalEncaissement: (json['total_encaissement'] as num?)?.toDouble() ?? 0.0,
      totalCreditRestant: (json['total_credit_restant'] as num?)?.toDouble() ?? 0.0,
      totalFrais: (json['total_frais'] as num?)?.toDouble() ?? 0.0,
      totalSalaires: (json['total_salaires'] as num?)?.toDouble() ?? 0.0,
      totalNetCashflow: (json['total_net_cashflow'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_encaissement': totalEncaissement,
      'total_credit_restant': totalCreditRestant,
      'total_frais': totalFrais,
      'total_salaires': totalSalaires,
      'total_net_cashflow': totalNetCashflow,
    };
  }
}

/// Modèle représentant la période
class CashflowPeriod {
  final String from;
  final String to;

  CashflowPeriod({
    required this.from,
    required this.to,
  });

  factory CashflowPeriod.fromJson(Map<String, dynamic> json) {
    return CashflowPeriod(
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

/// Modèle représentant la réponse complète de cashflow par jour
class CashflowByDay {
  final CashflowPeriod period;
  final List<DailyCashflowData> dailyData;
  final CashflowTotals totals;

  CashflowByDay({
    required this.period,
    required this.dailyData,
    required this.totals,
  });

  factory CashflowByDay.fromJson(Map<String, dynamic> json) {
    return CashflowByDay(
      period: CashflowPeriod.fromJson(json['period'] as Map<String, dynamic>? ?? {}),
      dailyData: (json['daily_data'] as List<dynamic>?)
              ?.map((d) => DailyCashflowData.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      totals: CashflowTotals.fromJson(json['totals'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'daily_data': dailyData.map((d) => d.toJson()).toList(),
      'totals': totals.toJson(),
    };
  }
}
