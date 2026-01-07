import '../core/network/api_client.dart';
import '../models/entities/credit_risk_stats.dart';

/// Service pour les statistiques de risque de crédit
class CreditRiskService {
  final ApiClient _apiClient;

  CreditRiskService(this._apiClient);

  /// Récupère les statistiques de risque de crédit pour une période donnée
  /// 
  /// [dateFrom]: Date de début (format: YYYY-MM-DD)
  /// [dateTo]: Date de fin (format: YYYY-MM-DD)
  Future<CreditRiskStats> getCreditRiskStats(
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    final response = await _apiClient.get(
      '/stats/credit-risk',
      queryParameters: {
        'date_from': _formatDate(dateFrom),
        'date_to': _formatDate(dateTo),
      },
    );

    return CreditRiskStats.fromJson(response.data as Map<String, dynamic>);
  }

  /// Formate une date au format YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '-${date.month.toString().padLeft(2, '0')}'
        '-${date.day.toString().padLeft(2, '0')}';
  }
}
