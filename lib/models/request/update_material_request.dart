/// Modèle pour mettre à jour un matériau
class UpdateMaterialRequest {
  final String? name;
  final String? category;
  final double? defaultPricePerTon;
  final String? description;
  final bool? isActive;

  UpdateMaterialRequest({
    this.name,
    this.category,
    this.defaultPricePerTon,
    this.description,
    this.isActive,
  });

  /// Convertir en JSON pour l'API
  /// Seulement les champs modifiés sont inclus
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (category != null) data['category'] = category;
    if (defaultPricePerTon != null) data['default_price_per_ton'] = defaultPricePerTon;
    if (description != null) data['description'] = description;
    if (isActive != null) data['is_active'] = isActive;

    return data;
  }
}
