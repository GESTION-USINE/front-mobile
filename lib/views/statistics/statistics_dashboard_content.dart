// import 'package:flutter/material.dart';

// class StatisticsDashboardContent extends StatelessWidget {
//   const StatisticsDashboardContent({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Tableau de bord')),
//       body: const Center(
//         child: Text('Page Tableau de bord'),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/stats_viewmodel.dart';

class StatisticsDashboardContent extends StatefulWidget {
  const StatisticsDashboardContent({super.key});

  @override
  State<StatisticsDashboardContent> createState() => _StatisticsDashboardContentState();
}

class _StatisticsDashboardContentState extends State<StatisticsDashboardContent> {
  late final StatsViewModel _viewModel;
  bool _isRangeMode = false; // false = Jour (par defaut)
  DateTime _selectedDay = DateTime.now();
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<StatsViewModel>();

    // Par defaut, on aligne le dashboard sur l'overview (periode globale)
   
_dateFrom = DateTime.now();
_dateTo = DateTime.now();
_selectedDay = DateTime.now();

_viewModel.refreshAll();
    // Charge initial
    _viewModel.refreshAll();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _applyDateRange(StatsViewModel vm, DateTime from, DateTime to) async {
    // On aligne toutes les periodes sur le meme filtre global
    await Future.wait([
      vm.loadOverviewStats(from, to),
      vm.loadPaymentsStats(from, to),
      vm.loadExpensesStats(from, to, groupBy: vm.groupBy),
      vm.loadTopStats(from, to),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<StatsViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statistiques - Tableau de bord', style: AppTheme.headingLarge),
                const SizedBox(height: 8),
                const Text(
                  'Vue globale : ventes, encaissements, credit, depenses, et indicateurs rapides.',
                  style: AppTheme.subtitleMedium,
                ),
                const SizedBox(height: 12),

                _buildHeaderFilters(viewModel),
                const SizedBox(height: 12),

                // KPI Cards
                _buildKpiRow(viewModel),
                const SizedBox(height: 16),

                // Graphiques
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                          child: _buildPaymentsChartCard(viewModel),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                          child: _buildExpensesChartCard(viewModel),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Mini blocs
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 900;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                          child: _buildChecksMiniCard(viewModel),
                        ),
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                          child: _buildTopClientsCard(viewModel),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
Widget _buildHeaderFilters(StatsViewModel viewModel) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildModeToggle(),
            if (!_isRangeMode) _buildDayPicker(viewModel) else ...[
              _buildFromPicker(),
              _buildToPicker(),
            ],
          ],
        ),
      ),
      const SizedBox(width: 12),

      // ✅ bouton a droite, largeur finie (PAS infinity)
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 42, maxWidth: 160),
            child: ElevatedButton.icon(
              onPressed: () async {
                final from = _dateFrom ?? DateTime.now();
                final to = _dateTo ?? DateTime.now();
                await _applyDateRange(viewModel, from, to);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.industrialPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Actualiser',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          if (viewModel.isLoading) ...[
            const SizedBox(height: 8),
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      ),
    ],
  );
}

Widget _buildModeToggle() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.industrialPrimary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _isRangeMode ? 'Intervalle' : 'Jour',
          style: const TextStyle(
            color: AppColors.industrialText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 6),
        Switch(
          value: _isRangeMode,
          activeColor: AppColors.industrialPrimary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (v) {
            setState(() {
              _isRangeMode = v;

              // Quand on repasse en mode Jour, on synchronise from/to sur le jour courant selectionne
              if (!_isRangeMode) {
                _dateFrom = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
                _dateTo = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
              }
            });
          },
        ),
      ],
    ),
  );
}

Widget _buildDayPicker(StatsViewModel vm) {
  return SizedBox(
    width: 180,
    child: InkWell(
      onTap: () async {
        final picked = await _pickDate(context, _selectedDay);
        if (picked != null) {
          setState(() {
            _selectedDay = picked;
            _dateFrom = DateTime(picked.year, picked.month, picked.day);
            _dateTo = DateTime(picked.year, picked.month, picked.day);
          });

          // Mode Jour => recharge directement
          await _applyDateRange(vm, _dateFrom!, _dateTo!);
        }
      },
      child: InputDecorator(
        decoration: AppTheme.industrialInputDecoration(
          hint: 'Date',
          prefixIcon: Icons.calendar_today,
        ),
        child: Text(
          _dateFormat.format(_selectedDay),
          style: const TextStyle(
            color: AppColors.industrialText,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

Widget _buildFromPicker() {
  return SizedBox(
    width: 180,
    child: InkWell(
      onTap: () async {
        final picked = await _pickDate(context, _dateFrom ?? DateTime.now());
        if (picked != null) {
          setState(() => _dateFrom = picked);
        }
      },
      child: InputDecorator(
        decoration: AppTheme.industrialInputDecoration(
          hint: 'Date debut',
          prefixIcon: Icons.calendar_today,
        ),
        child: Text(
          _dateFrom != null ? _dateFormat.format(_dateFrom!) : 'Date debut',
          style: TextStyle(
            color: _dateFrom != null ? AppColors.industrialText : AppColors.industrialTextLight,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

Widget _buildToPicker() {
  return SizedBox(
    width: 180,
    child: InkWell(
      onTap: () async {
        final picked = await _pickDate(context, _dateTo ?? DateTime.now());
        if (picked != null) {
          setState(() => _dateTo = picked);
        }
      },
      child: InputDecorator(
        decoration: AppTheme.industrialInputDecoration(
          hint: 'Date fin',
          prefixIcon: Icons.calendar_today,
        ),
        child: Text(
          _dateTo != null ? _dateFormat.format(_dateTo!) : 'Date fin',
          style: TextStyle(
            color: _dateTo != null ? AppColors.industrialText : AppColors.industrialTextLight,
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.industrialPrimary),
        ),
        child: child!,
      );
    },
  );
}

  // -------------------------
  // KPI Row
  // -------------------------
  Widget _buildKpiRow(StatsViewModel vm) {
    // Récupération safe des valeurs
    final salesTotal = _safeNum(_try(() => vm.overviewStats?.sales?.salesTotal));
    final creditRemaining = _safeNum(_try(() => vm.overviewStats?.credit?.remainingTotal));
    final netCashflow = _safeNum(_try(() => vm.overviewStats?.netCashflow));
    final paymentsTotal = _safeNum(_try(() => vm.paymentsStats?.grandTotal));
    final expensesTotal = _safeNum(_try(() => vm.expensesStats?.totals?.grandTotal));

    // Fallback net cashflow si non present
    final computedNet = (netCashflow == 0) ? (paymentsTotal - expensesTotal) : netCashflow;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 1100
            ? (constraints.maxWidth - 12 * 4) / 5
            : constraints.maxWidth >= 800
                ? (constraints.maxWidth - 12 * 2) / 3
                : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'CA total',
                value: _formatMoney(salesTotal),
                icon: Icons.bar_chart,
                accent: AppColors.industrialPrimary,
                isLoading: vm.isLoading && vm.overviewStats == null,
                hasError: vm.hasError && vm.overviewStats == null,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Encaissements',
                value: _formatMoney(paymentsTotal),
                icon: Icons.payments,
                accent: AppColors.industrialPrimary,
                isLoading: vm.isLoading && vm.paymentsStats == null,
                hasError: vm.hasError && vm.paymentsStats == null,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Credit restant',
                value: _formatMoney(creditRemaining),
                icon: Icons.account_balance_wallet,
                accent: creditRemaining > 0 ? AppColors.warning : AppColors.success,
                isLoading: vm.isLoading && vm.overviewStats == null,
                hasError: vm.hasError && vm.overviewStats == null,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Depenses',
                value: _formatMoney(expensesTotal),
                icon: Icons.receipt_long,
                accent: AppColors.industrialPrimary,
                isLoading: vm.isLoading && vm.expensesStats == null,
                hasError: vm.hasError && vm.expensesStats == null,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Net cashflow',
                value: _formatMoney(computedNet),
                icon: Icons.trending_up,
                accent: computedNet >= 0 ? AppColors.success : AppColors.danger,
                isLoading: vm.isLoading,
                hasError: vm.hasError && (vm.paymentsStats == null || vm.expensesStats == null),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------
  // Payments chart card (simple bar visualization)
  // -------------------------
  Widget _buildPaymentsChartCard(StatsViewModel vm) {
    final cash = _safeNum(_try(() => vm.paymentsStats?.payments?.cash?.totalAmount));
    final check = _safeNum(_try(() => vm.paymentsStats?.payments?.check?.totalAmount));
    final guarantee = _safeNum(_try(() => vm.paymentsStats?.payments?.guaranteeCheck?.totalAmount));

    final maxVal = [cash, check, guarantee].fold<double>(0, (p, e) => e > p ? e : p);

    return _SectionCard(
      title: 'Repartition des paiements',
      subtitle: _periodLabel(_dateFrom, _dateTo),
      isLoading: vm.isLoading && vm.paymentsStats == null,
      hasError: vm.hasError && vm.paymentsStats == null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniBarRow(label: 'Cash', value: cash, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Cheque', value: check, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Cheque garanti', value: guarantee, max: maxVal),
          const SizedBox(height: 12),
          Text(
            'Total: ${_formatMoney(cash + check + guarantee)}',
            style: const TextStyle(
              color: AppColors.industrialText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Expenses chart card (simple bar visualization)
  // -------------------------
  Widget _buildExpensesChartCard(StatsViewModel vm) {
    final frais = _safeNum(_try(() => vm.expensesStats?.totals?.frais));
    final salaries = _safeNum(_try(() => vm.expensesStats?.totals?.salaries));
    final other = _safeNum(_try(() => vm.expensesStats?.totals?.other));

    final maxVal = [frais, salaries, other].fold<double>(0, (p, e) => e > p ? e : p);

    return _SectionCard(
      title: 'Repartition des depenses',
      subtitle: _periodLabel(_dateFrom, _dateTo),
      isLoading: vm.isLoading && vm.expensesStats == null,
      hasError: vm.hasError && vm.expensesStats == null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniBarRow(label: 'Frais', value: frais, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Salaires', value: salaries, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Autres', value: other, max: maxVal),
          const SizedBox(height: 12),
          Text(
            'Total: ${_formatMoney(frais + salaries + other)}',
            style: const TextStyle(
              color: AppColors.industrialText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Checks mini card
  // -------------------------
  Widget _buildChecksMiniCard(StatsViewModel vm) {
    final pending = _safeInt(_try(() => vm.paymentsStats?.payments?.check?.pending));
    final cleared = _safeInt(_try(() => vm.paymentsStats?.payments?.check?.cleared));
    final rejected = _safeInt(_try(() => vm.paymentsStats?.payments?.check?.rejected));

    final hasAny = (pending + cleared + rejected) > 0;

    return _SectionCard(
      title: 'Cheques',
      subtitle: 'Resume etats',
      isLoading: vm.isLoading && vm.paymentsStats == null,
      hasError: vm.hasError && vm.paymentsStats == null,
      child: Row(
        children: [
          _StatChip(label: 'Pending', value: pending, color: AppColors.warning),
          const SizedBox(width: 8),
          _StatChip(label: 'Cleared', value: cleared, color: AppColors.success),
          const SizedBox(width: 8),
          _StatChip(label: 'Rejected', value: rejected, color: AppColors.danger),
          const Spacer(),
          if (hasAny)
            TextButton.icon(
              onPressed: () {
                // TODO: naviguer vers page cheques si tu as une route
                // Exemple:
                // context.go('/stats/checks');
              },
              icon: const Icon(Icons.open_in_new, size: 18, color: AppColors.industrialPrimary),
              label: const Text('Voir', style: TextStyle(color: AppColors.industrialPrimary)),
            ),
        ],
      ),
    );
  }

  // -------------------------
  // Top clients card (Top 5)
  // -------------------------
  Widget _buildTopClientsCard(StatsViewModel vm) {
    final clients = _try(() => vm.topStats?.topClientsByAmount) as List<dynamic>?;

    return _SectionCard(
      title: 'Top 5 clients',
      subtitle: _periodLabel(_dateFrom, _dateTo),
      isLoading: vm.isLoading && vm.topStats == null,
      hasError: vm.hasError && vm.topStats == null,
      child: (clients == null || clients.isEmpty)
          ? const Text(
              'Aucun client trouve pour cette periode.',
              style: TextStyle(color: AppColors.industrialTextLight),
            )
          : Column(
              children: clients.take(5).map((c) {
                // Ajuste ici selon ton modele TopStats
                final name = _try(() => c.name) ?? _try(() => c['name']) ?? '-';
                final total = _safeNum(_try(() => c.totalAmount) ?? _try(() => c['total_amount']));
                final slips = _safeInt(_try(() => c.slipsCount) ?? _try(() => c['slips_count']));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          name.toString(),
                          style: const TextStyle(
                            color: AppColors.industrialText,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (slips > 0)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Text(
                            '$slips bons',
                            style: const TextStyle(color: AppColors.industrialTextLight, fontSize: 12),
                          ),
                        ),
                      Text(
                        _formatMoney(total),
                        style: const TextStyle(
                          color: AppColors.industrialPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  // -------------------------
  // Date pickers
  // -------------------------
  Future<void> _selectDateFrom(BuildContext context, StatsViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.industrialPrimary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateFrom = picked);
    }
  }

  Future<void> _selectDateTo(BuildContext context, StatsViewModel viewModel) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.industrialPrimary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateTo = picked);
    }
  }

  // -------------------------
  // Helpers
  // -------------------------
  String _periodLabel(DateTime? from, DateTime? to) {
    if (from == null || to == null) return 'Periode';
    return '${_dateFormat.format(from)} - ${_dateFormat.format(to)}';
  }

  String _formatMoney(num value) {
    final f = NumberFormat.decimalPattern('fr_FR');
    return '${f.format(value)} DZD';
  }

  Object? _try(Object? Function() fn) {
    try {
      return fn();
    } catch (_) {
      return null;
    }
  }

  double _safeNum(Object? v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  int _safeInt(Object? v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

// -------------------------
// Widgets
// -------------------------

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final bool isLoading;
  final bool hasError;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: hasError
                ? const Text('Erreur', style: TextStyle(color: AppColors.danger))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.industrialTextLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isLoading)
                        Container(
                          height: 18,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        )
                      else
                        Text(
                          value,
                          style: TextStyle(
                            color: accent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool isLoading;
  final bool hasError;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.industrialText, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.industrialTextLight, fontSize: 12)),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (hasError)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasError)
            const Text('Erreur de chargement', style: TextStyle(color: AppColors.danger))
          else
            child,
        ],
      ),
    );
  }
}

class _MiniBarRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;

  const _MiniBarRow({
    required this.label,
    required this.value,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (max <= 0) ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: AppColors.industrialText)),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.industrialPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            NumberFormat.decimalPattern('fr_FR').format(value),
            textAlign: TextAlign.right,
            style: const TextStyle(color: AppColors.industrialTextLight),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: AppColors.industrialTextLight, fontSize: 12)),
          Text(
            value.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
