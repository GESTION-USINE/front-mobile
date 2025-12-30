/// Requête pour mettre à jour une dépense de maintenance existante
class UpdateMaintenanceExpenseRequest {
  final String? machineType;
  final String? description;
  final double? cost;
  final DateTime? maintenanceDate;
  final String? notes;

  UpdateMaintenanceExpenseRequest({
    this.machineType,
    this.description,
    this.cost,
    this.maintenanceDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (machineType != null) json['machine_type'] = machineType;
    if (description != null) json['description'] = description;
    if (cost != null) json['cost'] = cost;
    if (maintenanceDate != null) json['maintenance_date'] = maintenanceDate!.toIso8601String().split('T')[0];
    if (notes != null) json['notes'] = notes;
    
    return json;
  }
}
