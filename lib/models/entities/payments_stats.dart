/// Modèle représentant la période des statistiques de paiements
class PaymentPeriod {
  final String dateFrom;
  final String dateTo;

  PaymentPeriod({
    required this.dateFrom,
    required this.dateTo,
  });

  factory PaymentPeriod.fromJson(Map<String, dynamic> json) {
    return PaymentPeriod(
      dateFrom: json['date_from'] as String? ?? '',
      dateTo: json['date_to'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_from': dateFrom,
      'date_to': dateTo,
    };
  }
}

/// Modèle représentant les paiements en espèces
class CashPaymentStats {
  final int count;
  final double totalAmount;

  CashPaymentStats({
    required this.count,
    required this.totalAmount,
  });

  factory CashPaymentStats.fromJson(Map<String, dynamic> json) {
    return CashPaymentStats(
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

/// Modèle représentant les paiements par chèque
class CheckPaymentStats {
  final int count;
  final double totalAmount;
  final int pending;
  final int cleared;
  final int rejected;

  CheckPaymentStats({
    required this.count,
    required this.totalAmount,
    required this.pending,
    required this.cleared,
    required this.rejected,
  });

  factory CheckPaymentStats.fromJson(Map<String, dynamic> json) {
    return CheckPaymentStats(
      count: json['count'] as int? ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      pending: json['pending'] as int? ?? 0,
      cleared: json['cleared'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'total_amount': totalAmount,
      'pending': pending,
      'cleared': cleared,
      'rejected': rejected,
    };
  }
}

/// Modèle représentant les paiements par chèque de garantie
class GuaranteeCheckPaymentStats {
  final int count;
  final double totalAmount;

  GuaranteeCheckPaymentStats({
    required this.count,
    required this.totalAmount,
  });

  factory GuaranteeCheckPaymentStats.fromJson(Map<String, dynamic> json) {
    return GuaranteeCheckPaymentStats(
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

/// Modèle représentant l'ensemble des paiements
class PaymentsData {
  final CashPaymentStats cash;
  final CheckPaymentStats check;
  final GuaranteeCheckPaymentStats guaranteeCheck;

  PaymentsData({
    required this.cash,
    required this.check,
    required this.guaranteeCheck,
  });

  factory PaymentsData.fromJson(Map<String, dynamic> json) {
    return PaymentsData(
      cash: CashPaymentStats.fromJson(
          json['cash'] as Map<String, dynamic>? ?? {}),
      check: CheckPaymentStats.fromJson(
          json['check'] as Map<String, dynamic>? ?? {}),
      guaranteeCheck: GuaranteeCheckPaymentStats.fromJson(
          json['guarantee_check'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash': cash.toJson(),
      'check': check.toJson(),
      'guarantee_check': guaranteeCheck.toJson(),
    };
  }
}

/// Modèle représentant les statistiques de paiements
class PaymentsStats {
  final PaymentPeriod period;
  final PaymentsData payments;
  final double grandTotal;

  PaymentsStats({
    required this.period,
    required this.payments,
    required this.grandTotal,
  });

  factory PaymentsStats.fromJson(Map<String, dynamic> json) {
    return PaymentsStats(
      period: PaymentPeriod.fromJson(
          json['period'] as Map<String, dynamic>? ?? {}),
      payments: PaymentsData.fromJson(
          json['payments'] as Map<String, dynamic>? ?? {}),
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'payments': payments.toJson(),
      'grand_total': grandTotal,
    };
  }
}
