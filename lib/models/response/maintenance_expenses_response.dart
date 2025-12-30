import '../entities/maintenance_expense.dart';

/// Métadonnées de la réponse des dépenses de maintenance
class MaintenanceExpensesMeta {
  final int total;
  final double totalCost;

  MaintenanceExpensesMeta({
    required this.total,
    required this.totalCost,
  });

  factory MaintenanceExpensesMeta.fromJson(Map<String, dynamic> json) {
    return MaintenanceExpensesMeta(
      total: json['total'] as int,
      totalCost: (json['total_cost'] is String) 
          ? double.parse(json['total_cost'] as String)
          : (json['total_cost'] as num).toDouble(),
    );
  }
}

/// Réponse contenant la liste des dépenses de maintenance
class MaintenanceExpensesResponse {
  final List<MaintenanceExpense> items;
  final MaintenanceExpensesMeta meta;

  MaintenanceExpensesResponse({
    required this.items,
    required this.meta,
  });

  factory MaintenanceExpensesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemsList = data['items'] as List<dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;

    return MaintenanceExpensesResponse(
      items: itemsList
          .map((item) => MaintenanceExpense.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: MaintenanceExpensesMeta.fromJson(meta),
    );
  }
}
