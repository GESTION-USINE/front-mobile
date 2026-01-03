import '../entities/salary_payment.dart';

/// Réponse de l'API pour la liste des paiements de salaire
class SalaryPaymentsResponse {
  final List<SalaryPayment> items;
  final int total;
  final double totalAmount;

  SalaryPaymentsResponse({
    required this.items,
    required this.total,
    required this.totalAmount,
  });

 factory SalaryPaymentsResponse.fromJson(Map<String, dynamic> json) {
  final data = json['data'] as Map<String, dynamic>;
  final meta = json['meta'] as Map<String, dynamic>;

  // Gérer total_amount comme String ou num
  final totalAmountValue = meta['total_amount'];
  final totalAmount = totalAmountValue is String 
      ? double.parse(totalAmountValue) 
      : (totalAmountValue as num).toDouble();

  return SalaryPaymentsResponse(
    items: (data['items'] as List<dynamic>)
        .map((item) => SalaryPayment.fromJson(item as Map<String, dynamic>))
        .toList(),
    total: meta['total'] as int,
    totalAmount: totalAmount,
  );
}
}
