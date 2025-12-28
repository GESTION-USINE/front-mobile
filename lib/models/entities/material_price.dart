class MaterialPriceItem {
  final int? materialPriceId;
  final int clientId;
  final int materialId;
  final String materialName;
  final double defaultPricePerTon;
  final double? customPricePerTon;

  MaterialPriceItem({
    required this.materialPriceId,
    required this.clientId,
    required this.materialId,
    required this.materialName,
    required this.defaultPricePerTon,
    this.customPricePerTon,
  });

  factory MaterialPriceItem.fromJson(Map<String, dynamic> json) {
    return MaterialPriceItem(
      materialPriceId: json['material_price_id'] != null ? json['material_price_id'] as int : null,
      clientId: json['client_id'],
      materialId: json['material_id'],
      materialName: json['material_name'] != null ? json['material_name'] as String : '',
      defaultPricePerTon: json['default_price_per_ton'] != null ?
          (json['default_price_per_ton'] as num).toDouble() : 0.0,
      customPricePerTon: json['custom_price_per_ton'] != null
          ? (json['custom_price_per_ton'] as num).toDouble()
          : null,
    );
  }

  

   
    /// Affiche tous les attributs de l'objet (debug)
  void display() {
    print('========== MaterialPriceItem ==========');
    print('clientId             : $clientId');
    print('materialId           : $materialId');
    print('materialName         : $materialName');
    print('defaultPricePerTon   : $defaultPricePerTon');
    print('customPricePerTon    : ${customPricePerTon ?? 'NULL (prix par défaut)'}');
    print('=======================================');
  }






}
