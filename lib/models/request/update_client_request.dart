/// Modèle pour la mise à jour d'un client existant
class UpdateClientRequest {
  final String? name;
  final String? phone;
  final String? email;
  final bool? canPayByCheck;
  final bool? isActive;
  final String? notes;
  final num? creditLimit;

  UpdateClientRequest({
    this.name,
    this.phone,
    this.email,
    this.canPayByCheck,
    this.isActive,
    this.notes,
    this.creditLimit,
  });

  /// Convertir en JSON pour l'API
  /// Seulement les champs modifiés sont inclus
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (email != null) data['email'] = email;
    if (canPayByCheck != null) data['can_pay_by_check'] = canPayByCheck;
    if (isActive != null) data['is_active'] = isActive;
    if (notes != null) data['notes'] = notes;
    if (creditLimit != null) data['credit_limit'] = creditLimit;
    
    return data;
  }
}
