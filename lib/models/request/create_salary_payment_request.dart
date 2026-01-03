/// Requête pour créer un nouveau paiement de salaire
class CreateSalaryPaymentRequest {
  final int workerId;
  final String paymentMonth;
  final double amount;
  final DateTime paymentDate;
  final String? notes;

  CreateSalaryPaymentRequest({
    required this.workerId,
    required this.paymentMonth,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    // Format yyyy-MM-dd
    final formattedDate = '${paymentDate.year.toString().padLeft(4, '0')}-'
        '${paymentDate.month.toString().padLeft(2, '0')}-'
        '${paymentDate.day.toString().padLeft(2, '0')}';
    
    return {
      'worker_id': workerId,
      'payment_month': paymentMonth,
      'amount': amount,
      'payment_date': formattedDate,
      if (notes != null) 'notes': notes,
    };
  }
}
