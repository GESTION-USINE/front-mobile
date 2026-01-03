class CreatePaymentRequest {
  final int weighingSlipId;
  final String paymentType; // 'cash', 'check', 'guarantee_check'
  final double amountPaid;
  final String paymentDate; // Format: YYYY-MM-DD
  final String? checkNumber;
  final String? checkDate; // Format: YYYY-MM-DD
  final String? checkBank;
  final String? checkStatus; // 'pending', 'cleared', 'bounced'
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
      if (notes != null) 'notes': notes,
    };
  }
}
