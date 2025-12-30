/// Entité représentant une dépense de maintenance
class MaintenanceExpense {
  final int id;
  final String machineType;
  final String description;
  final double cost;
  final DateTime maintenanceDate;
  final String? notes;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceExpense({
    required this.id,
    required this.machineType,
    required this.description,
    required this.cost,
    required this.maintenanceDate,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaintenanceExpense.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final machineType = (json['machineType'] as String?) ?? (json['machine_type'] as String? ?? '');
    final description = json['description'] as String? ?? '';

    final costValue = json['cost'];
    final cost = (costValue is String)
        ? double.tryParse(costValue) ?? 0.0
        : (costValue is num ? costValue.toDouble() : 0.0);

    final maintenanceDateStr = (json['maintenanceDate'] ?? json['maintenance_date']) as String?;
    final maintenanceDate = maintenanceDateStr != null
        ? DateTime.parse(maintenanceDateStr)
        : DateTime.now();

    final notes = json['notes'] as String?;
    final createdBy = (json['createdBy'] as int?) ?? (json['created_by'] as int?) ?? 0;

    final createdAtStr = (json['createdAt'] ?? json['created_at']) as String?;
    final updatedAtStr = (json['updatedAt'] ?? json['updated_at']) as String?;

    final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();
    final updatedAt = updatedAtStr != null
        ? DateTime.parse(updatedAtStr)
        : createdAt;

    return MaintenanceExpense(
      id: id,
      machineType: machineType,
      description: description,
      cost: cost,
      maintenanceDate: maintenanceDate,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machine_type': machineType,
      'description': description,
      'cost': cost,
      'maintenance_date': maintenanceDate.toIso8601String(),
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
