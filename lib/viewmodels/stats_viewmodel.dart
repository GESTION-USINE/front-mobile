import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import 'package:flutter_mvvm_template/models/entities/daily_stats.dart';
import 'package:flutter_mvvm_template/models/entities/payments_stats.dart';
import 'package:flutter_mvvm_template/models/entities/expenses_stats.dart';
import 'package:flutter_mvvm_template/models/entities/top_stats.dart';
import 'package:flutter_mvvm_template/models/entities/overview_stats.dart';
import 'package:flutter_mvvm_template/services/stats_service.dart';

/// ViewModel pour gérer les statistiques
class StatsViewModel extends BaseViewModel {
  final StatsService _statsService;

  StatsViewModel(this._statsService);

  // Daily Stats
  DailyStats? _dailyStats;
  DateTime _selectedDailyDate = DateTime.now();

  DailyStats? get dailyStats => _dailyStats;
  DateTime get selectedDailyDate => _selectedDailyDate;

  // Payments Stats
  PaymentsStats? _paymentsStats;
  DateTime _paymentsDateFrom = DateTime.now().subtract(Duration(days: 90));
  DateTime _paymentsDateTo = DateTime.now();

  PaymentsStats? get paymentsStats => _paymentsStats;
  DateTime get paymentsDateFrom => _paymentsDateFrom;
  DateTime get paymentsDateTo => _paymentsDateTo;

  // Expenses Stats
  ExpensesStats? _expensesStats;
  DateTime _expensesDateFrom = DateTime.now().subtract(Duration(days: 90));
  DateTime _expensesDateTo = DateTime.now();
  String? _groupBy;

  ExpensesStats? get expensesStats => _expensesStats;
  DateTime get expensesDateFrom => _expensesDateFrom;
  DateTime get expensesDateTo => _expensesDateTo;
  String? get groupBy => _groupBy;

  // Top Stats
  TopStats? _topStats;
  DateTime _topStatsDateFrom = DateTime.now().subtract(Duration(days: 90));
  DateTime _topStatsDateTo = DateTime.now();

  TopStats? get topStats => _topStats;
  DateTime get topStatsDateFrom => _topStatsDateFrom;
  DateTime get topStatsDateTo => _topStatsDateTo;

  // Overview Stats
  OverviewStats? _overviewStats;
  DateTime _overviewDateFrom = DateTime.now().subtract(Duration(days: 90));
  DateTime _overviewDateTo = DateTime.now();

  OverviewStats? get overviewStats => _overviewStats;
  DateTime get overviewDateFrom => _overviewDateFrom;
  DateTime get overviewDateTo => _overviewDateTo;

  /// Charge les statistiques quotidiennes pour une date donnée
  Future<void> loadDailyStats(DateTime date) async {
    _selectedDailyDate = date;

    final result = await runAsync(() async {
      return await _statsService.getDailyStats(date);
    });

    if (result != null) {
      _dailyStats = result;
      notifyListeners();
    }
  }

  /// Change la date des statistiques quotidiennes
  void setDailyDate(DateTime date) {
    _selectedDailyDate = date;
    loadDailyStats(date);
  }

  /// Charge les statistiques de paiements pour une période
  Future<void> loadPaymentsStats(DateTime dateFrom, DateTime dateTo) async {
    _paymentsDateFrom = dateFrom;
    _paymentsDateTo = dateTo;

    final result = await runAsync(() async {
      return await _statsService.getPaymentsStats(dateFrom, dateTo);
    });

    if (result != null) {
      _paymentsStats = result;
      notifyListeners();
    }
  }

  /// Change la période des statistiques de paiements
  void setPaymentsDateRange(DateTime dateFrom, DateTime dateTo) {
    loadPaymentsStats(dateFrom, dateTo);
  }

  /// Charge les statistiques de dépenses pour une période
  Future<void> loadExpensesStats(
    DateTime dateFrom,
    DateTime dateTo, {
    String? groupBy,
  }) async {
    _expensesDateFrom = dateFrom;
    _expensesDateTo = dateTo;
    _groupBy = groupBy;

    final result = await runAsync(() async {
      return await _statsService.getExpensesStats(
        dateFrom,
        dateTo,
        groupBy: groupBy,
      );
    });

    if (result != null) {
      _expensesStats = result;
      notifyListeners();
    }
  }

  /// Change la période des statistiques de dépenses
  void setExpensesDateRange(DateTime dateFrom, DateTime dateTo) {
    loadExpensesStats(dateFrom, dateTo, groupBy: _groupBy);
  }

  /// Change le groupage des statistiques de dépenses
  void setExpensesGroupBy(String? groupBy) {
    loadExpensesStats(_expensesDateFrom, _expensesDateTo, groupBy: groupBy);
  }

  /// Charge les statistiques top (clients, matériaux, utilisateurs)
  Future<void> loadTopStats(DateTime dateFrom, DateTime dateTo) async {
    _topStatsDateFrom = dateFrom;
    _topStatsDateTo = dateTo;

    final result = await runAsync(() async {
      return await _statsService.getTopStats(dateFrom, dateTo);
    });

    if (result != null) {
      _topStats = result;
      notifyListeners();
    }
  }

  /// Change la période des statistiques top
  void setTopStatsDateRange(DateTime dateFrom, DateTime dateTo) {
    loadTopStats(dateFrom, dateTo);
  }

  /// Rafraîchit les statistiques top
  Future<void> refreshTopStats() async {
    await loadTopStats(_topStatsDateFrom, _topStatsDateTo);
  }

  /// Charge les statistiques d'overview globales
  Future<void> loadOverviewStats(DateTime dateFrom, DateTime dateTo) async {
    _overviewDateFrom = dateFrom;
    _overviewDateTo = dateTo;

    final result = await runAsync(() async {
      return await _statsService.getOverviewStats(dateFrom, dateTo);
    });

    if (result != null) {
      _overviewStats = result;
      notifyListeners();
    }
  }

  /// Change la période des statistiques d'overview
  void setOverviewDateRange(DateTime dateFrom, DateTime dateTo) {
    loadOverviewStats(dateFrom, dateTo);
  }

  /// Rafraîchit les statistiques d'overview
  Future<void> refreshOverviewStats() async {
    await loadOverviewStats(_overviewDateFrom, _overviewDateTo);
  }

  /// Rafraîchit toutes les statistiques
  Future<void> refreshAll() async {
    await Future.wait([
      loadDailyStats(_selectedDailyDate),
      loadPaymentsStats(_paymentsDateFrom, _paymentsDateTo),
      loadExpensesStats(_expensesDateFrom, _expensesDateTo, groupBy: _groupBy),
      loadTopStats(_topStatsDateFrom, _topStatsDateTo),
      loadOverviewStats(_overviewDateFrom, _overviewDateTo),
    ]);
  }

  /// Rafraîchit seulement les statistiques quotidiennes
  Future<void> refreshDailyStats() async {
    await loadDailyStats(_selectedDailyDate);
  }

  /// Rafraîchit seulement les statistiques de paiements
  Future<void> refreshPaymentsStats() async {
    await loadPaymentsStats(_paymentsDateFrom, _paymentsDateTo);
  }

  /// Rafraîchit seulement les statistiques de dépenses
  Future<void> refreshExpensesStats() async {
    await loadExpensesStats(_expensesDateFrom, _expensesDateTo,
        groupBy: _groupBy);
  }
}
