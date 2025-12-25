/// Réponse API pour la liste des matériaux
class MaterialsResponse {
  final List<dynamic> items;
  final int page;
  final int pageSize;
  final int total;

  MaterialsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  /// Créer depuis JSON
  factory MaterialsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    final pagination = meta['pagination'] as Map<String, dynamic>;

    final items = (data['items'] as List).map((item) {
      return item;
    }).toList();

    return MaterialsResponse(
      items: items,
      page: pagination['page'] as int? ?? 1,
      pageSize: pagination['pageSize'] as int? ?? 50,
      total: pagination['total'] as int? ?? 0,
    );
  }
}
