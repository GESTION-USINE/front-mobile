/// Requête pour créer une nouvelle dépense de maintenance
class CreateMaintenanceExpenseRequest {
  final String machineType;
  final String description;
  final double cost;
  final DateTime maintenanceDate;
  final String? notes;

  CreateMaintenanceExpenseRequest({
    required this.machineType,
    required this.description,
    required this.cost,
    required this.maintenanceDate,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'machine_type': machineType,
      'description': description,
      'cost': cost,
      'maintenance_date': maintenanceDate.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
    };
  }
}
