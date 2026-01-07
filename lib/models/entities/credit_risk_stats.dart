/// Modèle pour les statistiques de risque de crédit
class CreditRiskStats {
  final Period period;
  final Slips slips;
  final CreditPayments creditPayments;
  final ClosedCredits closedCredits;
  final ActiveCredits activeCredits;
  final Alerts alerts;
  final ClientsExceededLimit clientsExceededLimit;

  CreditRiskStats({
    required this.period,
    required this.slips,
    required this.creditPayments,
    required this.closedCredits,
    required this.activeCredits,
    required this.alerts,
    required this.clientsExceededLimit,
  });

  factory CreditRiskStats.fromJson(Map<String, dynamic> json) {
    return CreditRiskStats(
      period: Period.fromJson(json['period'] ?? {}),
      slips: Slips.fromJson(json['slips'] ?? {}),
      creditPayments: CreditPayments.fromJson(json['credit_payments'] ?? {}),
      closedCredits: ClosedCredits.fromJson(json['closed_credits'] ?? {}),
      activeCredits: ActiveCredits.fromJson(json['active_credits'] ?? {}),
      alerts: Alerts.fromJson(json['alerts'] ?? {}),
      clientsExceededLimit: ClientsExceededLimit.fromJson(json['clients_exceeded_limit'] ?? {}),
    );
  }
}

/// Période de reporting
class Period {
  final String from;
  final String to;

  Period({required this.from, required this.to});

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }
}

/// Bons de pesée
class Slips {
  final int count;
  final double totalAmount;

  Slips({required this.count, required this.totalAmount});

  factory Slips.fromJson(Map<String, dynamic> json) {
    return Slips(
      count: json['count'] ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Paiements de crédit
class CreditPayments {
  final int count;
  final double totalAmount;

  CreditPayments({required this.count, required this.totalAmount});

  factory CreditPayments.fromJson(Map<String, dynamic> json) {
    return CreditPayments(
      count: json['count'] ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Crédits fermés
class ClosedCredits {
  final int count;
  final List<ClosedCredit> closedCredits;

  ClosedCredits({required this.count, required this.closedCredits});

  factory ClosedCredits.fromJson(Map<String, dynamic> json) {
    final creditsList = (json['closed_credits'] as List<dynamic>?)?.map((c) => ClosedCredit.fromJson(c)) ?? const Iterable.empty();
    return ClosedCredits(
      count: json['count'] ?? 0,
      closedCredits: List<ClosedCredit>.from(creditsList),
    );
  }
}

/// Détails d'un crédit fermé
class ClosedCredit {
  final int creditId;
  final int slipId;
  final int clientId;
  final String clientName;
  final double totalAmount;
  final double paidAmount;

  ClosedCredit({
    required this.creditId,
    required this.slipId,
    required this.clientId,
    required this.clientName,
    required this.totalAmount,
    required this.paidAmount,
  });

  factory ClosedCredit.fromJson(Map<String, dynamic> json) {
    return ClosedCredit(
      creditId: json['credit_id'] ?? 0,
      slipId: json['slip_id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      clientName: json['client_name'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Crédits actifs
class ActiveCredits {
  final int count;
  final double totalRemaining;

  ActiveCredits({required this.count, required this.totalRemaining});

  factory ActiveCredits.fromJson(Map<String, dynamic> json) {
    return ActiveCredits(
      count: json['count'] ?? 0,
      totalRemaining: (json['total_remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Alertes de crédit
class Alerts {
  final int nearThresholdCount;
  final List<AlertDetail> nearThresholdDetails;

  Alerts({required this.nearThresholdCount, required this.nearThresholdDetails});

  factory Alerts.fromJson(Map<String, dynamic> json) {
    final alertsList = (json['near_threshold_details'] as List<dynamic>?)?.map((a) => AlertDetail.fromJson(a)) ?? const Iterable.empty();
    return Alerts(
      nearThresholdCount: json['near_threshold_count'] ?? 0,
      nearThresholdDetails: List<AlertDetail>.from(alertsList),
    );
  }
}

/// Détails d'une alerte
class AlertDetail {
  final int creditId;
  final int slipId;
  final double totalAmount;
  final double remaining;
  final double paidPercentage;

  AlertDetail({
    required this.creditId,
    required this.slipId,
    required this.totalAmount,
    required this.remaining,
    required this.paidPercentage,
  });

  factory AlertDetail.fromJson(Map<String, dynamic> json) {
    return AlertDetail(
      creditId: json['credit_id'] ?? 0,
      slipId: json['slip_id'] ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
      paidPercentage: (json['paid_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Clients ayant dépassé leur limite
class ClientsExceededLimit {
  final int count;
  final List<ClientExceededLimit> clients;

  ClientsExceededLimit({required this.count, required this.clients});

  factory ClientsExceededLimit.fromJson(Map<String, dynamic> json) {
    final clientsList = (json['clients'] as List<dynamic>?)?.map((c) => ClientExceededLimit.fromJson(c)) ?? const Iterable.empty();
    return ClientsExceededLimit(
      count: json['count'] ?? 0,
      clients: List<ClientExceededLimit>.from(clientsList),
    );
  }
}

/// Client ayant dépassé sa limite de crédit
class ClientExceededLimit {
  final int clientId;
  final String clientName;
  final double creditLimit;
  final double totalCreditUsed;
  final double exceededAmount;
  final bool isExceeded;
  final int slipsCount;

  ClientExceededLimit({
    required this.clientId,
    required this.clientName,
    required this.creditLimit,
    required this.totalCreditUsed,
    required this.exceededAmount,
    required this.isExceeded,
    required this.slipsCount,
  });

  factory ClientExceededLimit.fromJson(Map<String, dynamic> json) {
    return ClientExceededLimit(
      clientId: json['client_id'] ?? 0,
      clientName: json['client_name'] ?? '',
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      totalCreditUsed: (json['total_credit_used'] as num?)?.toDouble() ?? 0.0,
      exceededAmount: (json['exceeded_amount'] as num?)?.toDouble() ?? 0.0,
      isExceeded: json['is_exceeded'] ?? false,
      slipsCount: json['slips_count'] ?? 0,
    );
  }
}
