/// Modèle pour représenter un matériau
class Material {
  final int id;
  final String name;
  final String category;
  final double defaultPricePerTon;
  final String? description;
  final bool isActive;
  final int? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Material({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultPricePerTon,
    this.description,
    required this.isActive,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  /// Créer un Material depuis JSON
  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      defaultPricePerTon: ((json['default_price_per_ton'] as num?) ?? 0).toDouble(),
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdBy: json['created_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'default_price_per_ton': defaultPricePerTon,
      'description': description,
      'is_active': isActive,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
