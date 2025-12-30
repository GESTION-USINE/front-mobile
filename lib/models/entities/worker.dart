/// Entité représentant un travailleur
class Worker {
  final int id;
  final String fullName;
  final String phone;
  final String address;
  final DateTime hireDate;
  final String jobPosition;
  final double monthlySalary;
  final bool isActive;
  final String? notes;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Worker({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.hireDate,
    required this.jobPosition,
    required this.monthlySalary,
    required this.isActive,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final fullName = (json['fullName'] as String?) ?? (json['full_name'] as String? ?? '');
    final phone = json['phone'] as String? ?? '';
    final address = json['address'] as String? ?? '';

    final hireDateStr = (json['hireDate'] ?? json['hire_date']) as String?;
    final hireDate = hireDateStr != null ? DateTime.parse(hireDateStr) : DateTime.now();

    final jobPosition = (json['jobPosition'] as String?) ?? (json['job_position'] as String? ?? '');

    final salaryValue = json['monthlySalary'] ?? json['monthly_salary'];
    final monthlySalary = (salaryValue is String)
        ? double.tryParse(salaryValue) ?? 0.0
        : (salaryValue is num ? salaryValue.toDouble() : 0.0);

    final isActive = (json['isActive'] as bool?) ?? (json['is_active'] as bool? ?? true);
    final notes = json['notes'] as String?;
    final createdBy = (json['createdBy'] as int?) ?? (json['created_by'] as int?) ?? 0;

    final createdAtStr = (json['createdAt'] ?? json['created_at']) as String?;
    final updatedAtStr = (json['updatedAt'] ?? json['updated_at']) as String?;

    final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : DateTime.now();
    final updatedAt = updatedAtStr != null ? DateTime.parse(updatedAtStr) : createdAt;

    return Worker(
      id: id,
      fullName: fullName,
      phone: phone,
      address: address,
      hireDate: hireDate,
      jobPosition: jobPosition,
      monthlySalary: monthlySalary,
      isActive: isActive,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'hire_date': hireDate.toIso8601String().split('T')[0],
      'job_position': jobPosition,
      'monthly_salary': monthlySalary,
      'is_active': isActive,
      'notes': notes,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
