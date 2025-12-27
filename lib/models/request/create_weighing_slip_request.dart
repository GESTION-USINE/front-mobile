class CreateWeighingSlipRequest {
  final int clientId;
  final int materialId;
  final double weightTons;

  CreateWeighingSlipRequest({
    required this.clientId,
    required this.materialId,
    required this.weightTons,
  });

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'material_id': materialId,
      'weight_tons': weightTons,
    };
  }
}

class CreatePaymentRequest {
  final int weighingSlipId;
  final String paymentType; // 'cash', 'check', 'guarantee_check'
  final double amountPaid;
  final String paymentDate;
  final String? checkNumber;
  final String? checkDate;
  final String? checkBank;
  final String? checkStatus;
  final String? notes;

  CreatePaymentRequest({
    required this.weighingSlipId,
    required this.paymentType,
    required this.amountPaid,
    required this.paymentDate,
    this.checkNumber,
    this.checkDate,
    this.checkBank,
    this.checkStatus,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'weighing_slip_id': weighingSlipId,
      'payment_type': paymentType,
      'amount_paid': amountPaid,
      'payment_date': paymentDate,
      if (checkNumber != null) 'check_number': checkNumber,
      if (checkDate != null) 'check_date': checkDate,
      if (checkBank != null) 'check_bank': checkBank,
      if (checkStatus != null) 'check_status': checkStatus,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}
