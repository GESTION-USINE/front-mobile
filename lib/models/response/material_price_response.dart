import './../entities/material_price.dart';
class MaterialPricesResponse {
  final List<dynamic> items;
  final int page;
  final int pageSize;
  final int total;

  MaterialPricesResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory MaterialPricesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    final pagination = meta['pagination'] as Map<String, dynamic>;

    final items = (data['items'] as List)
        .map((item) => MaterialPriceItem.fromJson(item))
        .toList();

    return MaterialPricesResponse(
      items: items,
      page: pagination['page'] as int? ?? 1,
      pageSize: pagination['pageSize'] as int? ?? 50,
      total: pagination['total'] as int? ?? 0,
    );
  }
}
