/// Entité Client
class Client {
  final int id;
  final String name;
  final String type; // 'particulier' ou 'entreprise'
  final String phone;
  final String? address;
  final String? email;
  final String? taxId;
  final bool canPayByCheck;
  final bool isActive;
  final String? notes;
  final double credit;
  final int createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Client({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    this.address,
    this.email,
    this.taxId,
    required this.canPayByCheck,
    required this.isActive,
    this.notes,
    this.credit = 0.0,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'particulier',
      phone: (json['phone'] as String?) ?? '',
      address: json['address'] as String?,
      email: json['email'] as String?,
      taxId: json['tax_id'] as String?,
      canPayByCheck: (json['can_pay_by_check'] as bool?) ?? false,
      isActive: (json['is_active'] as bool?) ?? true,
      notes: json['notes'] as String?,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      createdBy: (json['created_by'] as int?) ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'phone': phone,
      'address': address,
      'email': email,
      'tax_id': taxId,
      'can_pay_by_check': canPayByCheck,
      'is_active': isActive,
      'notes': notes,
      'credit': credit,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  bool get isEnterprise => type == 'entreprise';
  bool get isParticular => type == 'particulier';

  String get typeDisplay => isEnterprise ? 'Entreprise' : 'Particulier';
}
