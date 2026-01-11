import 'package:intl/intl.dart';

import '../core/base/base_viewmodel.dart';
import '../models/entities/credit_payment_item.dart';
import '../models/response/credits_payments_response.dart';
import '../services/payment_service.dart';

class CreditsPaymentsViewModel extends BaseViewModel {
  final PaymentService _paymentService;

  CreditsPaymentsViewModel(this._paymentService);

  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  String _formatDate(DateTime date) => _apiDateFormat.format(date.toLocal());

  String _normalizeDateString(String raw) {
    try {
      return _formatDate(DateTime.parse(raw));
    } catch (_) {
      // Fallback: couper à 10 chars si le backend renvoie déjà au bon format
      return raw.length >= 10 ? raw.substring(0, 10) : raw;
    }
  }

  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<CreditPaymentItem> _payments = [];
  CreditsPaymentsTotals? _totals;

  String get selectedDate => _selectedDate;
  List<CreditPaymentItem> get payments => _payments;
  CreditsPaymentsTotals? get totals => _totals;

  double get totalAmount => _totals?.totalAmount ?? 0.0;
  double get cashTotal => _totals?.cashTotal ?? 0.0;
  double get checkTotal => _totals?.checkTotal ?? 0.0;
  double get guaranteeCheckTotal => _totals?.guaranteeCheckTotal ?? 0.0;
  int get count => _totals?.count ?? 0;

  // ==================== Cache Methods ====================
  String _generateCacheKey() {
    return 'credits_payments_${_selectedDate}';
  }

  /// Charger les encaissements d'une date (par défaut aujourd'hui)
  Future<void> loadCreditsPayments({DateTime? date, bool refresh = false}) async {
    if (date != null) {
      _selectedDate = _formatDate(date);
    }

    if (refresh) {
      clearAllCache();
    }

    final cacheKey = _generateCacheKey();

    // 💾 Vérifier le cache d'abord
    if (!refresh && isCacheValid(cacheKey)) {
      final cached = getCacheEntry<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        _selectedDate = cached['date'] as String? ?? _selectedDate;
        _payments = (cached['payments'] as List<CreditPaymentItem>?) ?? [];
        _totals = cached['totals'] as CreditsPaymentsTotals?;
        notifyListeners();
        return;
      }
    }

    await runAsync(() async {
      final response = await _paymentService.getCreditsPayments(date: _selectedDate);
      if (response.date.isNotEmpty) {
        _selectedDate = _normalizeDateString(response.date);
      }
      _payments = response.payments;
      _totals = response.totals;

      // 💾 Mettre en cache le résultat (durée par défaut 5 min)
      setCacheEntry(
        cacheKey,
        {
          'date': _selectedDate,
          'payments': _payments,
          'totals': _totals,
        },
      );
    });
  }

  /// Changer la date (force un fetch backend)
  Future<void> changeDate(DateTime date) async {
    _selectedDate = _formatDate(date);
    await loadCreditsPayments(refresh: true);
  }

  /// Force le rafraîchissement sur la date courante
  Future<void> refresh() async {
    await loadCreditsPayments(refresh: true);
  }
}
