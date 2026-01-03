import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/entities/daily_stats.dart';
import '../models/entities/payments_stats.dart';
import '../models/entities/expenses_stats.dart';
import '../models/entities/top_stats.dart';
import '../models/entities/overview_stats.dart';
import 'package:intl/intl.dart';

/// Service pour gérer les statistiques
class StatsService {
  final ApiClient _apiClient;

  StatsService(this._apiClient);

  /// Récupère les statistiques quotidiennes (ventes, factures, paiements, crédits)
  /// 
  /// [date] - Date au format yyyy-MM-dd
  /// 
  /// Returns DailyStats containing:
  /// - sales: total des ventes du jour
  /// - invoices: total des factures du jour
  /// - payments: total des paiements du jour
  /// - credit: total des crédits du jour
  Future<DailyStats> getDailyStats(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      
      final response = await _apiClient.get(
        '/stats/daily',
        queryParameters: {
          'date': formattedDate,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return DailyStats.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère les statistiques de paiements sur une période
  /// 
  /// [dateFrom] - Date de début au format yyyy-MM-dd
  /// [dateTo] - Date de fin au format yyyy-MM-dd
  /// 
  /// Returns PaymentsStats containing:
  /// - total_payments: montant total des paiements
  /// - number_of_payments: nombre de paiements
  /// - average_payment: montant moyen des paiements
  /// - payments_by_date: répartition des paiements par date
  Future<PaymentsStats> getPaymentsStats(
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final formattedDateFrom = DateFormat('yyyy-MM-dd').format(dateFrom);
      final formattedDateTo = DateFormat('yyyy-MM-dd').format(dateTo);
      
      final response = await _apiClient.get(
        '/stats/payments',
        queryParameters: {
          'date_from': formattedDateFrom,
          'date_to': formattedDateTo,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return PaymentsStats.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère les statistiques de dépenses sur une période
  /// 
  /// [dateFrom] - Date de début au format yyyy-MM-dd
  /// [dateTo] - Date de fin au format yyyy-MM-dd
  /// [groupBy] - Grouper par: 'day', 'week', 'month' (optionnel)
  /// 
  /// Returns ExpensesStats containing:
  /// - total_expenses: montant total des dépenses
  /// - number_of_expenses: nombre de dépenses
  /// - average_expense: montant moyen des dépenses
  /// - expenses_by_category: répartition des dépenses par catégorie
  /// - expenses_by_date: répartition des dépenses par date (selon groupBy)
  Future<ExpensesStats> getExpensesStats(
    DateTime dateFrom,
    DateTime dateTo, {
    String? groupBy,
  }) async {
    try {
      final formattedDateFrom = DateFormat('yyyy-MM-dd').format(dateFrom);
      final formattedDateTo = DateFormat('yyyy-MM-dd').format(dateTo);
      
      final queryParams = <String, dynamic>{
        'date_from': formattedDateFrom,
        'date_to': formattedDateTo,
      };
      
      if (groupBy != null) {
        queryParams['group_by'] = groupBy;
      }
      
      final response = await _apiClient.get(
        '/stats/expenses',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return ExpensesStats.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère les statistiques top (top clients, matériaux, utilisateurs) sur une période
  /// 
  /// [dateFrom] - Date de début au format yyyy-MM-dd
  /// [dateTo] - Date de fin au format yyyy-MM-dd
  /// 
  /// Returns TopStats containing:
  /// - top_clients_by_amount: top clients par montant
  /// - top_materials_by_weight: top matériaux par poids
  /// - top_users_by_sales: top utilisateurs par ventes
  Future<TopStats> getTopStats(
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final formattedDateFrom = DateFormat('yyyy-MM-dd').format(dateFrom);
      final formattedDateTo = DateFormat('yyyy-MM-dd').format(dateTo);
      
      final response = await _apiClient.get(
        '/stats/top',
        queryParameters: {
          'date_from': formattedDateFrom,
          'date_to': formattedDateTo,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return TopStats.fromJson(data);
    } on DioException {
      rethrow;
    }
  }

  /// Récupère les statistiques d'overview global (KPI dashboard) sur une période
  ///
  /// [dateFrom] - Date de début au format yyyy-MM-dd
  /// [dateTo] - Date de fin au format yyyy-MM-dd
  ///
  /// Retourne OverviewStats contenant ventes, factures, paiements, crédit, dépenses, net cashflow
  Future<OverviewStats> getOverviewStats(
    DateTime dateFrom,
    DateTime dateTo,
  ) async {
    try {
      final formattedDateFrom = DateFormat('yyyy-MM-dd').format(dateFrom);
      final formattedDateTo = DateFormat('yyyy-MM-dd').format(dateTo);

      final response = await _apiClient.get(
        '/stats/overview',
        queryParameters: {
          'date_from': formattedDateFrom,
          'date_to': formattedDateTo,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return OverviewStats.fromJson(data);
    } on DioException {
      rethrow;
    }
  }
}

