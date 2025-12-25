/// Modèle pour créer un nouveau matériau
class CreateMaterialRequest {
  final String name;
  final String category;
  final double defaultPricePerTon;
  final String? description;

  CreateMaterialRequest({
    required this.name,
    required this.category,
    required this.defaultPricePerTon,
    this.description,
  });

  /// Convertir en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'default_price_per_ton': defaultPricePerTon,
      if (description != null) 'description': description,
    };
  }
}
