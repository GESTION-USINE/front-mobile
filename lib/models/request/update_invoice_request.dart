/// Requête de mise à jour d'une facture
class UpdateInvoiceRequest {
  final List<int>? addSlipIds;
  final List<int>? removeSlipIds;

  UpdateInvoiceRequest({
    this.addSlipIds,
    this.removeSlipIds,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    
    if (addSlipIds != null && addSlipIds!.isNotEmpty) {
      json['add_slip_ids'] = addSlipIds;
    }
    
    if (removeSlipIds != null && removeSlipIds!.isNotEmpty) {
      json['remove_slip_ids'] = removeSlipIds;
    }
    
    return json;
  }
}
