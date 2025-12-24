/// Requête pour créer un nouveau client
class CreateClientRequest {
  final String name;
  final String type; // 'particulier' ou 'entreprise'
  final String phone;
  final String? address;
  final String? email;
  final String? taxId;
  final bool canPayByCheck;
  final String? notes;

  CreateClientRequest({
    required this.name,
    required this.type,
    required this.phone,
    this.address,
    this.email,
    this.taxId,
    this.canPayByCheck = false,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'phone': phone,
      if (address != null) 'address': address,
      if (email != null) 'email': email,
      if (taxId != null) 'tax_id': taxId,
      'can_pay_by_check': canPayByCheck,
      if (notes != null) 'notes': notes,
    };
  }
}
