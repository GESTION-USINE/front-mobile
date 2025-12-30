/// Requête pour mettre à jour un travailleur existant
class UpdateWorkerRequest {
  final String? fullName;
  final String? phone;
  final String? address;
  final DateTime? hireDate;
  final String? jobPosition;
  final double? monthlySalary;
  final bool? isActive;
  final String? notes;

  UpdateWorkerRequest({
    this.fullName,
    this.phone,
    this.address,
    this.hireDate,
    this.jobPosition,
    this.monthlySalary,
    this.isActive,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    if (fullName != null) json['full_name'] = fullName;
    if (phone != null) json['phone'] = phone;
    if (address != null) json['address'] = address;
    if (hireDate != null) json['hire_date'] = hireDate!.toIso8601String().split('T')[0];
    if (jobPosition != null) json['job_position'] = jobPosition;
    if (monthlySalary != null) json['monthly_salary'] = monthlySalary;
    if (isActive != null) json['is_active'] = isActive;
    if (notes != null) json['notes'] = notes;
    
    return json;
  }
}
