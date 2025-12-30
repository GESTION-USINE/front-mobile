import '../entities/worker.dart';

/// Métadonnées de la réponse des travailleurs
class WorkersMeta {
  final int total;

  WorkersMeta({required this.total});

  factory WorkersMeta.fromJson(Map<String, dynamic> json) {
    return WorkersMeta(
      total: json['total'] as int,
    );
  }
}

/// Réponse contenant la liste des travailleurs
class WorkersResponse {
  final List<Worker> items;
  final WorkersMeta meta;

  WorkersResponse({
    required this.items,
    required this.meta,
  });

  factory WorkersResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final itemsList = data['items'] as List<dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;

    return WorkersResponse(
      items: itemsList
          .map((item) => Worker.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: WorkersMeta.fromJson(meta),
    );
  }
}
