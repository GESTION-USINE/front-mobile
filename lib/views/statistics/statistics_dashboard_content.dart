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
import '../../di/injection_container.dart';
import '../../viewmodels/stats_viewmodel.dart';
import 'credit_risk_stats_section.dart';

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
      vm.loadDailyStats(from),
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
                _buildHeaderFilters(viewModel),
                const SizedBox(height: 20),

                // KPI Cards
                _buildKpiRow(viewModel),
                const SizedBox(height: 20),

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
                        SizedBox(
                          width: isWide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth,
                          child: _buildMaterialsBreakdownCard(viewModel),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Section Gestion du Risque de Crédit
                if (_dateFrom != null && _dateTo != null)
                  CreditRiskStatsSection(
                    dateFrom: _dateFrom!,
                    dateTo: _dateTo!,
                  ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
Widget _buildHeaderFilters(StatsViewModel viewModel) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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

        // Bouton actualiser avec état de chargement intégré
        AnimatedBuilder(
          animation: viewModel,
          builder: (context, child) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42, maxWidth: 160),
              child: ElevatedButton.icon(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        final from = _dateFrom ?? DateTime.now();
                        final to = _dateTo ?? DateTime.now();
                        await _applyDateRange(viewModel, from, to);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.industrialPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.industrialPrimary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Actualiser',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildModeToggle() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModeButton(
          label: 'Jour',
          isActive: !_isRangeMode,
          onTap: () {
            setState(() {
              _isRangeMode = false;
              _dateFrom = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
              _dateTo = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
            });
          },
        ),
        const SizedBox(width: 4),
        _ModeButton(
          label: 'Intervalle',
          isActive: _isRangeMode,
          onTap: () {
            setState(() => _isRangeMode = true);
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.industrialPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _dateFormat.format(_selectedDay),
                style: const TextStyle(
                  color: AppColors.industrialText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.industrialPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _dateFrom != null ? _dateFormat.format(_dateFrom!) : 'Début',
                style: TextStyle(
                  color: _dateFrom != null ? AppColors.industrialText : AppColors.industrialTextLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: AppColors.industrialPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _dateTo != null ? _dateFormat.format(_dateTo!) : 'Fin',
                style: TextStyle(
                  color: _dateTo != null ? AppColors.industrialText : AppColors.industrialTextLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
    final salesTotal = _safeNum(_try(() {
      final os = vm.dailyStats as dynamic;
      return os?.weighingSlips?.totalAmount ?? 0;
    }));
    final slipsCount = _safeInt(_try(() {
      final os = vm.dailyStats as dynamic;
      return os?.weighingSlips?.count ?? 0;
    }));
    final slipsTons = _safeInt(_try(() {
      final os = vm.dailyStats as dynamic;
      return os?.weighingSlips?.totalWeightTons ?? 0;
    }));
    final creditRemaining = _safeNum(_try(() {
      final os = vm.dailyStats as dynamic;
      return os?.credit?.remaining ?? 0;
    }));
    final paymentsTotal = _safeNum(_try(() {
      final ps = vm.dailyStats as dynamic;
      return ps?.payments?.total ?? 0;
    }));
    final expensesTotal = _safeNum(_try(() {
      final es = vm.expensesStats as dynamic;
      return es?.totals?.grandTotal ?? 0;
    }));

    // Fallback net cashflow si non present
    final computedNet = paymentsTotal - expensesTotal ;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 800
          ? (constraints.maxWidth - 12 * 2) / 3
          : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Encaissements',
                value: _formatMoney(paymentsTotal),
                icon: Icons.payments,
                accent: AppColors.industrialPrimary,
                  isLoading: vm.isLoading && vm.paymentsStats == null,
                  hasError: vm.hasError && vm.paymentsStats == null,
                  titleFontSize: 12,
                  valueFontSize: 18,
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
                  titleFontSize: 12,
                  valueFontSize: 18,
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
                  titleFontSize: 12,
                  valueFontSize: 18,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Frais et Salaires',
                value: _formatMoney(expensesTotal),
                icon: Icons.receipt_long,
                accent: AppColors.industrialPrimary,
                  isLoading: vm.isLoading && vm.expensesStats == null,
                  hasError: vm.hasError && vm.expensesStats == null,
                  titleFontSize: 12,
                  valueFontSize: 18,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Total des ventes',
                value: _formatMoney(salesTotal),
                icon: Icons.bar_chart,
                accent: AppColors.industrialPrimary,
                  isLoading: vm.isLoading && vm.overviewStats == null,
                  hasError: vm.hasError && vm.overviewStats == null,
                  titleFontSize: 12,
                  valueFontSize: 18,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Bons vendus',
                value: slipsCount.toString(),
                icon: Icons.receipt,
                accent: AppColors.industrialPrimary,
                  isLoading: vm.isLoading && vm.overviewStats == null,
                  hasError: vm.hasError && vm.overviewStats == null,
                  titleFontSize: 12,
                  valueFontSize: 18,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: KpiCard(
                title: 'Slips en tonnes',
                value: slipsTons.toString(),
                icon: Icons.receipt,
                accent: AppColors.industrialPrimary,
                  isLoading: vm.isLoading && vm.overviewStats == null,
                  hasError: vm.hasError && vm.overviewStats == null,
                  titleFontSize: 12,
                  valueFontSize: 18,
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
    final cash = _safeNum(_try(() {
      final ps = vm.dailyStats as dynamic;
      return ps?.payments?.versementsTotalCash ?? 0;
    }));
    final check = _safeNum(_try(() {
      final ps = vm.dailyStats as dynamic;
      return ps?.payments?.versementsTotalCheck ?? 0;
    }));
    final check_initial = _safeNum(_try(() {
      final ps = vm.dailyStats as dynamic;
      return ps?.payments?.initialPaymentsTotalCheck ?? 0;
    }));
    final cash_initial = _safeNum(_try(() {
      final ps = vm.dailyStats as dynamic;
      return ps?.payments?.initialPaymentsTotalCash ?? 0;
    }));

    final maxVal = [cash, check, check_initial, cash_initial].fold<double>(0, (p, e) => e > p ? e : p);

    return _SectionCard(
      title: 'Repartition des paiements',
      subtitle: _periodLabel(_dateFrom, _dateTo),
      isLoading: vm.isLoading && vm.paymentsStats == null,
      hasError: vm.hasError && vm.paymentsStats == null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MiniBarRow(label: 'Cash Versé', value: cash, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Cheque Versé', value: check, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Cash initial', value: cash_initial, max: maxVal),
          const SizedBox(height: 10),
          _MiniBarRow(label: 'Cheque initial', value: check_initial, max: maxVal),
          const SizedBox(height: 16),
          Text(
            'Total: ${_formatMoney(cash + check + cash_initial + check_initial)}',
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
    final frais = _safeNum(_try(() {
      final es = vm.expensesStats as dynamic;
      return es?.totals?.frais ?? 0;
    }));
    final salaries = _safeNum(_try(() {
      final es = vm.expensesStats as dynamic;
      return es?.totals?.salaries ?? 0;
    }));
    final other = _safeNum(_try(() {
      final es = vm.expensesStats as dynamic;
      return es?.totals?.other ?? 0;
    }));

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
          const SizedBox(height: 16),
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
    final pending = _safeInt(_try(() {
      final ps = vm.paymentsStats as dynamic;
      return ps?.payments?.check?.pending ?? 0;
    }));
    final cleared = _safeInt(_try(() {
      final ps = vm.paymentsStats as dynamic;
      return ps?.payments?.check?.cleared ?? 0;
    }));
    final rejected = _safeInt(_try(() {
      final ps = vm.paymentsStats as dynamic;
      return ps?.payments?.check?.rejected ?? 0;
    }));

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

  Widget _buildMaterialsBreakdownCard(StatsViewModel vm) {
    final materials = _try(() {
      final ds = vm.dailyStats as dynamic;
      return ds?.weighingSlips?.materials ?? <dynamic>[];
    }) as List<dynamic>?;

    final items = (materials ?? [])
        .map((m) {
          final name = _try(() => m['material_name']) ?? _try(() => m.materialName) ?? _try(() => m['materialName']) ;
          final tons = _try(() => m['total_weight_tons']) ?? _try(() => m.totalWeightTons) ?? _try(() => m['totalWeightTons']);
          final amount = _try(() => m['total_amount']) ?? _try(() => m.totalAmount) ?? _try(() => m['totalAmount']);
          return {
            'material_name': name ?? '-',
            'total_weight_tons': tons ?? '0',
            'total_amount': amount ?? 0,
          };
        })
        .where((m) => m != null)
        .toList();

    return _SectionCard(
      title: 'Répartition par matériau',
      subtitle: _periodLabel(_dateFrom, _dateTo),
      isLoading: vm.isLoading && vm.dailyStats == null,
      hasError: vm.hasError && vm.dailyStats == null,
      child: (items.isEmpty)
          ? const Text('Aucun matériau trouvé pour cette période.', style: TextStyle(color: AppColors.industrialTextLight))
          : Column(
              children: items.map((m) {
                final name = _try(() => m['material_name']) ?? _try(() => m['materialName']) ?? '-';
                final tonsRaw = _try(() => m['total_weight_tons']) ?? _try(() => m['totalWeightTons']) ?? '0';
                final amountRaw = _try(() => m['total_amount']) ?? _try(() => m['totalAmount']) ?? 0;
                final tons = tonsRaw.toString();
                final amount = _safeNum(amountRaw);

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
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          '$tons t',
                          style: const TextStyle(color: AppColors.industrialTextLight, fontSize: 12),
                        ),
                      ),
                      Text(
                        _formatMoney(amount),
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
  final double titleFontSize;
  final double valueFontSize;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.isLoading = false,
    this.hasError = false,
    this.titleFontSize = 11,
    this.valueFontSize = 16,
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
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.15),
                  accent.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: hasError
                ? Text('Erreur', style: TextStyle(color: AppColors.danger, fontSize: titleFontSize))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.industrialTextLight,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (isLoading)
                        ShimmerLoading(
                          width: 120,
                          height: 20,
                          borderRadius: 6,
                        )
                      else
                        Text(
                          value,
                          style: TextStyle(
                            color: accent,
                            fontSize: valueFontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
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
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.hasError
              ? AppColors.danger.withOpacity(0.2)
              : AppColors.industrialPrimary.withOpacity(0.15),
        ),
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
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AppColors.industrialText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: AppColors.industrialTextLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (widget.hasError)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.error_outline, color: AppColors.danger, size: 18),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (widget.hasError)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Erreur de chargement',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 12,
                ),
              ),
            )
          else if (widget.isLoading)
            Column(
              children: [
                ShimmerLoading(width: double.infinity, height: 12),
                const SizedBox(height: 8),
                ShimmerLoading(width: double.infinity * 0.8, height: 12),
              ],
            )
          else
            widget.child,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.industrialText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              NumberFormat.decimalPattern('fr_FR').format(value),
              style: const TextStyle(
                color: AppColors.industrialTextLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.industrialPrimary,
                      AppColors.industrialPrimary.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
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

class _ModeButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.industrialPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.industrialTextLight,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

/// Widget de chargement avec effet shimmer simple
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    required this.width,
    required this.height,
    this.borderRadius = 6,
    Key? key,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
                Colors.grey.shade200,
              ],
              transform: GradientRotation(_animationController.value * 6.3),
            ),
          ),
        );
      },
    );
  }
}