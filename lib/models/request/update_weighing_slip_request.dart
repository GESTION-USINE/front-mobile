class UpdateWeighingSlipRequest {
  final int? clientId;
  final int? materialId;
  final double? weightTons;

  UpdateWeighingSlipRequest({
    this.clientId,
    this.materialId,
    this.weightTons,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (clientId != null) data['client_id'] = clientId;
    if (materialId != null) data['material_id'] = materialId;
    if (weightTons != null) data['weight_tons'] = weightTons;
    return data;
  }
}
