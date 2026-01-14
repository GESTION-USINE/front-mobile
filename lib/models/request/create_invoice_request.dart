/// Requête de création d'une facture
class CreateInvoiceRequest {
  final List<int> weighingSlipIds;

  CreateInvoiceRequest({
    required this.weighingSlipIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'weighing_slip_ids': weighingSlipIds,
    };
  }
}
