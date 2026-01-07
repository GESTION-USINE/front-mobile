import 'package:flutter_mvvm_template/core/base/base_viewmodel.dart';
import '../models/entities/credit_risk_stats.dart';
import '../services/credit_risk_service.dart';

/// ViewModel pour les statistiques de risque de crédit
class CreditRiskViewModel extends BaseViewModel {
  final CreditRiskService _creditRiskService;

  CreditRiskViewModel(this._creditRiskService);

  CreditRiskStats? _creditRiskStats;
  DateTime _dateFrom = DateTime.now().subtract(Duration(days: 90));
  DateTime _dateTo = DateTime.now();

  CreditRiskStats? get creditRiskStats => _creditRiskStats;
  DateTime get dateFrom => _dateFrom;
  DateTime get dateTo => _dateTo;

  /// Charge les statistiques de risque de crédit
  Future<void> loadCreditRiskStats([
    DateTime? dateFrom,
    DateTime? dateTo,
  ]) async {
    if (dateFrom != null) _dateFrom = dateFrom;
    if (dateTo != null) _dateTo = dateTo;

    final result = await runAsync(() async {
      return await _creditRiskService.getCreditRiskStats(_dateFrom, _dateTo);
    });

    if (result != null) {
      _creditRiskStats = result;
      notifyListeners();
    }
  }

  /// Change la période et recharge les données
  Future<void> setDateRange(DateTime from, DateTime to) async {
    _dateFrom = from;
    _dateTo = to;
    await loadCreditRiskStats(from, to);
  }

  /// Rafraîchit les statistiques
  Future<void> refreshCreditRiskStats() async {
    await loadCreditRiskStats();
  }
}
