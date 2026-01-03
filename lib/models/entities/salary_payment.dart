/// Représente un paiement de salaire
class SalaryPayment {
  final int id;
  final int workerId;
  final String paymentMonth;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
  final SalaryPaymentWorker? worker;

  SalaryPayment({
    required this.id,
    required this.workerId,
    required this.paymentMonth,
    required this.amount,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
    this.worker,
  });

  // factory SalaryPayment.fromJson(Map<String, dynamic> json) {
  //   // Parser et reformater payment_month au format yyyy-MM-dd
  //   final paymentMonthRaw = json['payment_month'] as String;
  //   final paymentMonthDate = DateTime.parse(paymentMonthRaw);
  //   final paymentMonthFormatted = '${paymentMonthDate.year.toString().padLeft(4, '0')}-'
  //       '${paymentMonthDate.month.toString().padLeft(2, '0')}-'
  //       '${paymentMonthDate.day.toString().padLeft(2, '0')}';
    
  //   return SalaryPayment(
  //     id: json['id'] as int,
  //     workerId: json['worker'] != null 
  //         ? (json['worker']['id'] as int)
  //         : 0,
  //     paymentMonth: paymentMonthFormatted,
  //     amount: (json['amount'] as num).toDouble(),
  //     paymentDate: DateTime.parse(json['payment_date'] as String),
  //     notes: json['notes'] as String?,
  //     createdAt: DateTime.parse(json['created_at'] as String),
  //     worker: json['worker'] != null
  //         ? SalaryPaymentWorker.fromJson(json['worker'] as Map<String, dynamic>)
  //         : null,
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'worker_id': workerId,
  //     'payment_month': paymentMonth,
  //     'amount': amount,
  //     'payment_date': paymentDate.toIso8601String(),
  //     'notes': notes,
  //     'created_at': createdAt.toIso8601String(),
  //     'worker': worker?.toJson(),
  //   };
  // }
  factory SalaryPayment.fromJson(Map<String, dynamic> json) {
  // Parser et reformater payment_month au format yyyy-MM-dd
  final paymentMonthRaw = json['payment_month'] as String;
  final paymentMonthDate = DateTime.parse(paymentMonthRaw);
  final paymentMonthFormatted = '${paymentMonthDate.year.toString().padLeft(4, '0')}-'
      '${paymentMonthDate.month.toString().padLeft(2, '0')}-'
      '${paymentMonthDate.day.toString().padLeft(2, '0')}';
  
  // Gérer le workerId : soit depuis worker.id, soit depuis worker_id
  final workerId = json['worker'] != null 
      ? (json['worker']['id'] as int)
      : (json['worker_id'] as int? ?? 0);
  
  // Gérer amount comme String ou num
  final amountValue = json['amount'];
  final amount = amountValue is String 
      ? double.parse(amountValue) 
      : (amountValue as num).toDouble();
  
  return SalaryPayment(
    id: json['id'] as int,
    workerId: workerId,
    paymentMonth: paymentMonthFormatted,
    amount: amount,
    paymentDate: DateTime.parse(json['payment_date'] as String),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    worker: json['worker'] != null
        ? SalaryPaymentWorker.fromJson(json['worker'] as Map<String, dynamic>)
        : null,
  );
}
}

/// Représente les informations simplifiées du travailleur dans un paiement de salaire
class SalaryPaymentWorker {
  final int id;
  final String fullName;

  SalaryPaymentWorker({
    required this.id,
    required this.fullName,
  });

  factory SalaryPaymentWorker.fromJson(Map<String, dynamic> json) {
    return SalaryPaymentWorker(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
    };
  }
}
