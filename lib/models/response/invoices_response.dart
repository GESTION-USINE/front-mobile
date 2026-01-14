import '../entities/invoice.dart';

/// Réponse de la liste des factures
class InvoicesResponse {
  final List<Invoice> items;
  final int page;
  final int pageSize;
  final int total;

  InvoicesResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory InvoicesResponse.fromJson(Map<String, dynamic> json) {
    try {
      int _asInt(dynamic v) {
        if (v is int) return v;
        if (v is double) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
        return 0;
      }

      final rawData = json['data'];
      print('INVOICES RESPONSE RAW DATA:');
      print(rawData);

      // Le backend renvoie data: { items: [], ... } – on s'aligne sur cette forme.
      final List<dynamic> data;
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map<String, dynamic>) {
        data = rawData['items'] as List<dynamic>? ?? [];
      } else {
        data = const [];
      }

      final meta = json['meta'] ?? (rawData is Map<String, dynamic> ? rawData['meta'] : null) ?? json;
      final pagination = meta is Map<String, dynamic> ? (meta['pagination'] ?? meta) : meta;
      final response = InvoicesResponse(
        items: data.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList(),
        page: _asInt(pagination['page']) == 0 ? 1 : _asInt(pagination['page']),
        pageSize: _asInt(pagination['pageSize']) != 0
            ? _asInt(pagination['pageSize'])
            : (_asInt(pagination['page_size']) != 0 ? _asInt(pagination['page_size']) : 20),
        total: _asInt(pagination['total']) != 0 ? _asInt(pagination['total']) : data.length,
      );
      print('INVOICES RESPONSE PARSED:');
      print(response);
      return response;
    } catch (e, stack) {
      print('INVOICES RESPONSE PARSE ERROR: $e');
      print(stack);
      return InvoicesResponse(items: const [], page: 1, pageSize: 20, total: 0);
    }
  }
}
