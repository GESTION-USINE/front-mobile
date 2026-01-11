import 'package:flutter_mvvm_template/models/entities/credit_payment_item.dart';

class CreditsPaymentsResponse {
  final String date;
  final List<CreditPaymentItem> payments;
  final CreditsPaymentsTotals totals;

  CreditsPaymentsResponse({
    required this.date,
    required this.payments,
    required this.totals,
  });

  factory CreditsPaymentsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final paymentsJson = data['payments'] as List<dynamic>? ?? [];
    return CreditsPaymentsResponse(
      date: (data['date'] as String?) ?? '',
      payments: paymentsJson
          .map((p) => CreditPaymentItem.fromJson(p as Map<String, dynamic>))
          .toList(),
      totals: CreditsPaymentsTotals.fromJson(
        data['totals'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class CreditsPaymentsTotals {
  final int count;
  final double totalAmount;
  final double cashTotal;
  final double checkTotal;
  final double guaranteeCheckTotal;

  CreditsPaymentsTotals({
    required this.count,
    required this.totalAmount,
    required this.cashTotal,
    required this.checkTotal,
    required this.guaranteeCheckTotal,
  });

  factory CreditsPaymentsTotals.fromJson(Map<String, dynamic> json) {
    return CreditsPaymentsTotals(
      count: (json['count'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      cashTotal: (json['cash_total'] as num?)?.toDouble() ?? 0.0,
      checkTotal: (json['check_total'] as num?)?.toDouble() ?? 0.0,
      guaranteeCheckTotal:
          (json['guarantee_check_total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
