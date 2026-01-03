/// Modèle représentant un client dans les top stats
class TopClient {
  final int clientId;
  final String name;
  final double totalAmount;

  TopClient({
    required this.clientId,
    required this.name,
    required this.totalAmount,
  });

  factory TopClient.fromJson(Map<String, dynamic> json) {
    return TopClient(
      clientId: json['client_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'client_id': clientId,
      'name': name,
      'total_amount': totalAmount,
    };
  }
}

/// Modèle représentant un matériau dans les top stats
class TopMaterial {
  final int materialId;
  final String name;
  final double totalWeightTons;

  TopMaterial({
    required this.materialId,
    required this.name,
    required this.totalWeightTons,
  });

  factory TopMaterial.fromJson(Map<String, dynamic> json) {
    return TopMaterial(
      materialId: json['material_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      totalWeightTons: (json['total_weight_tons'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'name': name,
      'total_weight_tons': totalWeightTons,
    };
  }
}

/// Modèle représentant un utilisateur dans les top stats
class TopUser {
  final int userId;
  final String username;
  final double totalAmount;

  TopUser({
    required this.userId,
    required this.username,
    required this.totalAmount,
  });

  factory TopUser.fromJson(Map<String, dynamic> json) {
    return TopUser(
      userId: json['user_id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'total_amount': totalAmount,
    };
  }
}

/// Modèle représentant la période des statistiques top
class TopStatsPeriod {
  final String from;
  final String to;

  TopStatsPeriod({
    required this.from,
    required this.to,
  });

  factory TopStatsPeriod.fromJson(Map<String, dynamic> json) {
    return TopStatsPeriod(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
    };
  }
}

/// Modèle représentant les statistiques top (clients, matériaux, utilisateurs)
class TopStats {
  final TopStatsPeriod period;
  final List<TopClient> topClientsByAmount;
  final List<TopMaterial> topMaterialsByWeight;
  final List<TopUser> topUsersBySales;

  TopStats({
    required this.period,
    required this.topClientsByAmount,
    required this.topMaterialsByWeight,
    required this.topUsersBySales,
  });

  factory TopStats.fromJson(Map<String, dynamic> json) {
    final topClientsList = (json['top_clients_by_amount'] as List<dynamic>?)
            ?.map((item) => TopClient.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    final topMaterialsList =
        (json['top_materials_by_weight'] as List<dynamic>?)
                ?.map((item) =>
                    TopMaterial.fromJson(item as Map<String, dynamic>))
                .toList() ??
            [];

    final topUsersList = (json['top_users_by_sales'] as List<dynamic>?)
            ?.map((item) => TopUser.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return TopStats(
      period: TopStatsPeriod.fromJson(
          json['period'] as Map<String, dynamic>? ?? {}),
      topClientsByAmount: topClientsList,
      topMaterialsByWeight: topMaterialsList,
      topUsersBySales: topUsersList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.toJson(),
      'top_clients_by_amount':
          topClientsByAmount.map((item) => item.toJson()).toList(),
      'top_materials_by_weight':
          topMaterialsByWeight.map((item) => item.toJson()).toList(),
      'top_users_by_sales':
          topUsersBySales.map((item) => item.toJson()).toList(),
    };
  }
}
