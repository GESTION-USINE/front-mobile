class WeighingSlipsResponse {
  final List<dynamic> items; // may be Map or WeighingSlip
  final int page;
  final int pageSize;
  final int total;

  WeighingSlipsResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory WeighingSlipsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['items'] as List<dynamic>? ?? (json['data']?['items'] as List<dynamic>? ?? []);
    final meta = json['meta'] ?? json;
    final pagination = meta['pagination'] ?? meta;
    return WeighingSlipsResponse(
      items: data,
      page: (pagination['page'] as int?) ?? 1,
      pageSize: (pagination['pageSize'] as int?) ?? 20,
      total: (pagination['total'] as int?) ?? data.length,
    );
  }
}
