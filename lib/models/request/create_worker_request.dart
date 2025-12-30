/// Requête pour créer un nouveau travailleur
class CreateWorkerRequest {
  final String fullName;
  final String phone;
  final String address;
  final DateTime hireDate;
  final String jobPosition;
  final double monthlySalary;
  final bool isActive;
  final String? notes;

  CreateWorkerRequest({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.hireDate,
    required this.jobPosition,
    required this.monthlySalary,
    this.isActive = true,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone': phone,
      'address': address,
      'hire_date': hireDate.toIso8601String().split('T')[0],
      'job_position': jobPosition,
      'monthly_salary': monthlySalary,
      'is_active': isActive,
      if (notes != null) 'notes': notes,
    };
  }
}
