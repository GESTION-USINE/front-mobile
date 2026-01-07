import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/stats_viewmodel.dart';

class SalesStatsContent extends StatefulWidget {
  const SalesStatsContent({super.key});

  @override
  State<SalesStatsContent> createState() => _SalesStatsContentState();
}

class _SalesStatsContentState extends State<SalesStatsContent> {
  late final StatsViewModel _viewModel;

  // UI state
  bool _isRangeMode = true; // true = Intervalle, false = Jour
  DateTime _selectedDay = DateTime.now();
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<StatsViewModel>();

    // Par defaut: Intervalle (90 jours) comme ton VM, mais tu peux mettre aujourd'hui si tu veux
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    _dateTo = _selectedDay;
    _dateFrom = _selectedDay.subtract(const Duration(days: 30));

    _refreshSales();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _refreshSales() async {
    final from = _dateFrom ?? _selectedDay;
    final to = _dateTo ?? _selectedDay;

    // Charge en parallele: daily + trend + top
    await Future.wait([
      _viewModel.loadDailyStats(_selectedDay),
      _viewModel.loadSalesTrend(from, to, groupBy: _viewModel.salesTrendGroupBy),
      _viewModel.loadTopStats(from, to),
    ]);
  }

  Future<void> _applyRange(DateTime from, DateTime to) async {
    setState(() {
      _dateFrom = DateTime(from.year, from.month, from.day);
      _dateTo = DateTime(to.year, to.month, to.day);
    });

    // daily = dernier jour selectionne (to)
    _selectedDay = _dateTo!;

    await _refreshSales();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<StatsViewModel>(
        builder: (context, vm, child) {
          final daily = vm.dailyStats;
          final trend = vm.salesTrendStats;

          // KPI (safe parse)
          final slipsCount = _safeInt(_try(() => daily?.weighingSlips.count));
          final totalWeight = _safeNum(_try(() => daily?.weighingSlips.totalWeightTons));
          final totalAmount = _safeNum(_try(() => daily?.weighingSlips.totalAmount));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statistiques - Ventes', style: AppTheme.headingLarge),
                const SizedBox(height: 8),
                const Text(
                  'Suivi de l\'activite commerciale: bons, poids, montants, et evolution sur une periode.',
                  style: AppTheme.subtitleMedium,
                ),
                const SizedBox(height: 12),

                _buildHeader(vm),
                const SizedBox(height: 12),

                // KPI row
                _buildKpiRow(
                  isLoading: vm.isLoading && daily == null,
                  hasError: vm.hasError && daily == null,
                  slipsCount: slipsCount,
                  totalWeight: totalWeight,
                  totalAmount: totalAmount,
                ),
                const SizedBox(height: 16),

                // Chart (bar) + Top 3 materials
                _buildTrendCard(vm, trend),
                const SizedBox(height: 12),
                _buildTopMaterialsCard(vm),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // -------------------------
  // Header with filters + refresh
  // -------------------------
  Widget _buildHeader(StatsViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildModeToggle(vm),

              if (!_isRangeMode)
                _buildDayPicker(vm)
              else ...[
                _buildFromPicker(),
                _buildToPicker(),
                _buildGroupBySelector(vm),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),

        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42, maxWidth: 160),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (!_isRangeMode) {
                    await _applyRange(_selectedDay, _selectedDay);
                  } else {
                    final from = _dateFrom ?? DateTime.now();
                    final to = _dateTo ?? DateTime.now();
                    await _applyRange(from, to);
                  }
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
            if (vm.isLoading) ...[
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

  Widget _buildModeToggle(StatsViewModel vm) {
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
            onChanged: (v) async {
              setState(() => _isRangeMode = v);

              // Passe en Jour => from=to=selectedDay et recharge direct
              if (!v) {
                await _applyRange(_selectedDay, _selectedDay);
              }
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
            final day = DateTime(picked.year, picked.month, picked.day);
            setState(() => _selectedDay = day);
            await _applyRange(day, day);
          }
        },
        child: InputDecorator(
          decoration: AppTheme.industrialInputDecoration(
            hint: 'Date',
            prefixIcon: Icons.calendar_today,
          ),
          child: Text(
            _dateFormat.format(_selectedDay),
            style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
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
            setState(() => _dateFrom = DateTime(picked.year, picked.month, picked.day));
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
            setState(() => _dateTo = DateTime(picked.year, picked.month, picked.day));
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

  Widget _buildGroupBySelector(StatsViewModel vm) {
    return SizedBox(
      width: 160,
      child: DropdownButtonFormField<String>(
        value: vm.salesTrendGroupBy,
        decoration: AppTheme.industrialInputDecoration(
          hint: 'Group by',
          prefixIcon: Icons.tune,
        ),
        items: const [
          DropdownMenuItem(value: 'day', child: Text('Jour')),
          DropdownMenuItem(value: 'week', child: Text('Semaine')),
          DropdownMenuItem(value: 'month', child: Text('Mois')),
        ],
        onChanged: (v) async {
          if (v == null) return;
          vm.setSalesTrendGroupBy(v);
          final from = _dateFrom ?? _selectedDay;
          final to = _dateTo ?? _selectedDay;
          await _applyRange(from, to);
        },
      ),
    );
  }

  // -------------------------
  // KPI Row
  // -------------------------
  Widget _buildKpiRow({
    required bool isLoading,
    required bool hasError,
    required int slipsCount,
    required double totalWeight,
    required double totalAmount,
  }) {
    final money = _formatMoney(totalAmount);
    final weight = '${NumberFormat.decimalPattern('fr_FR').format(totalWeight)} t';

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth >= 900
            ? (constraints.maxWidth - 12 * 2) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                title: 'Nombre de bons',
                value: slipsCount.toString(),
                icon: Icons.receipt,
                accent: AppColors.industrialPrimary,
                isLoading: isLoading,
                hasError: hasError,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                title: 'Poids total',
                value: weight,
                icon: Icons.scale,
                accent: AppColors.industrialPrimary,
                isLoading: isLoading,
                hasError: hasError,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _KpiCard(
                title: 'Montant total',
                value: money,
                icon: Icons.attach_money,
                accent: AppColors.industrialPrimary,
                isLoading: isLoading,
                hasError: hasError,
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------
  // Trend card (BAR CHART)
  // -------------------------
  Widget _buildTrendCard(StatsViewModel vm, dynamic trend) {
    final series = _try(() => trend?.series) as List<dynamic>?;

    return _SectionCard(
      title: 'Evolution des ventes',
      subtitle: _periodLabel(_dateFrom, _dateTo) +
          (_isRangeMode ? ' (group: ${vm.salesTrendGroupBy})' : ''),
      isLoading: vm.isLoading && trend == null,
      hasError: vm.hasError && trend == null,
      child: (series == null || series.isEmpty)
          ? const Text(
              'Aucune donnee sur la periode.',
              style: TextStyle(color: AppColors.industrialTextLight),
            )
          : _BarChart(
              bars: series.map((e) {
                final val = _safeNum(
                  _try(() => e.salesTotal) ??
                      _try(() => e['sales_total']) ??
                      _try(() => e.totalAmount) ??
                      _try(() => e['total_amount']),
                );
                final label = (_try(() => e.date) ?? _try(() => e['date']) ?? '').toString();
                return _BarItem(label: label, value: val);
              }).toList(),
            ),
    );
  }

  // -------------------------
  // Top 3 materials
  // -------------------------
  Widget _buildTopMaterialsCard(StatsViewModel vm) {
    final top = vm.topStats;

    final materials = _try(() => top?.topMaterialsByWeight) as List<dynamic>?;

    final items = (materials ?? []).take(3).toList();

    return _SectionCard(
      title: 'Top 3 materials (poids)',
      subtitle: _periodLabel(_dateFrom, _dateTo),
      isLoading: vm.isLoading && top == null,
      hasError: vm.hasError && top == null,
      child: items.isEmpty
          ? const Text(
              'Aucun material sur la periode.',
              style: TextStyle(color: AppColors.industrialTextLight),
            )
          : Column(
              children: items.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final m = entry.value;

                final name = (_try(() => m.name) ?? _try(() => m['name']) ?? '-').toString();
                final weight = _safeNum(
                  _try(() => m.totalWeightTons) ?? _try(() => m['total_weight_tons']),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.industrialPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.18)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.industrialPrimary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$idx',
                          style: const TextStyle(
                            color: AppColors.industrialPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.industrialText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${NumberFormat.decimalPattern('fr_FR').format(weight)} t',
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
  // Utils
  // -------------------------
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
// Small UI components
// -------------------------

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accent;
  final bool isLoading;
  final bool hasError;

  const _KpiCard({
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.industrialText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.industrialTextLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
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

// -------------------------
// BAR CHART (no external lib)
// -------------------------

class _BarItem {
  final String label;
  final double value;
  const _BarItem({required this.label, required this.value});
}

class _BarChart extends StatefulWidget {
  final List<_BarItem> bars;

  const _BarChart({required this.bars});

  @override
  State<_BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<_BarChart> {
  int? _hoveredIndex;
  Offset? _hoverPosition;

  @override
  Widget build(BuildContext context) {
    if (widget.bars.isEmpty) {
      return const Text(
        'Aucune donnee sur la periode.',
        style: TextStyle(color: AppColors.industrialTextLight),
      );
    }

    final maxV = widget.bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;

    return MouseRegion(
      onHover: (event) {
        final localPos = event.localPosition;
        final hoveredIdx = _getBarIndexAtPosition(localPos);
        if (hoveredIdx != _hoveredIndex) {
          setState(() {
            _hoveredIndex = hoveredIdx;
            _hoverPosition = hoveredIdx != null ? localPos : null;
          });
        }
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = null;
          _hoverPosition = null;
        });
      },
      child: Stack(
        children: [
          SizedBox(
            height: 240,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarChartPainter(
                bars: widget.bars,
                maxV: safeMax,
                hoveredIndex: _hoveredIndex,
              ),
            ),
          ),
          if (_hoveredIndex != null && _hoverPosition != null)
            Positioned(
              left: _hoverPosition!.dx + 10,
              top: _hoverPosition!.dy - 40,
              child: _buildTooltip(widget.bars[_hoveredIndex!]),
            ),
        ],
      ),
    );
  }

  int? _getBarIndexAtPosition(Offset pos) {
    const leftPad = 6.0;
    const bottomPad = 20.0;
    const topPad = 8.0;
    const spacing = 10.0;

    final n = widget.bars.length;
    final chartW = context.size?.width ?? 0;
    if (chartW <= leftPad) return null;

    final totalSpacing = spacing * (n + 1);
    final rawBarW = (chartW - leftPad - totalSpacing) / n;
    final barW = rawBarW.clamp(6.0, 38.0);

    final chartH = 240 - bottomPad - topPad;
    final baseY = topPad + chartH;

    // Vérifie si le curseur est dans la zone du graphique
    if (pos.dy < topPad || pos.dy > baseY) return null;

    for (int i = 0; i < n; i++) {
      final x = leftPad + spacing + i * (barW + spacing);
      if (pos.dx >= x && pos.dx <= x + barW) {
        return i;
      }
    }

    return null;
  }

  Widget _buildTooltip(_BarItem bar) {
    final money = NumberFormat.decimalPattern('fr_FR').format(bar.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.industrialText.withOpacity(0.92),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bar.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$money DZD',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<_BarItem> bars;
  final double maxV;
  final int? hoveredIndex;

  _BarChartPainter({
    required this.bars,
    required this.maxV,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.black.withOpacity(0.10)
      ..strokeWidth = 1;

    final gridPaint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;

    final barPaint = Paint()
      ..color = AppColors.industrialPrimary
      ..style = PaintingStyle.fill;

    final barHoverPaint = Paint()
      ..color = AppColors.industrialPrimary.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final textStyle = const TextStyle(
      color: AppColors.industrialTextLight,
      fontSize: 10,
    );

    const leftPad = 6.0;
    const bottomPad = 20.0;
    const topPad = 8.0;

    final chartH = size.height - bottomPad - topPad;
    final chartW = size.width - leftPad;

    final baseY = topPad + chartH;

    // Axe X
    canvas.drawLine(Offset(leftPad, baseY), Offset(leftPad + chartW, baseY), axisPaint);

    // Grille horizontale (3 lignes)
    for (int i = 1; i <= 3; i++) {
      final y = topPad + chartH * (i / 4.0);
      canvas.drawLine(Offset(leftPad, y), Offset(leftPad + chartW, y), gridPaint);
    }

    // Bars
    final n = bars.length;
    final spacing = 10.0;
    final totalSpacing = spacing * (n + 1);
    final rawBarW = (chartW - totalSpacing) / n;
    final barW = rawBarW.clamp(6.0, 38.0);

    for (int i = 0; i < n; i++) {
      final b = bars[i];
      final x = leftPad + spacing + i * (barW + spacing);

      final h = (b.value / maxV) * chartH;
      final topY = baseY - h;

      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, topY, barW, h),
        const Radius.circular(6),
      );
      
      // Applique une couleur différente si la barre est hover
      final paintToUse = i == hoveredIndex ? barHoverPaint : barPaint;
      canvas.drawRRect(r, paintToUse);

      // Label court
      final label = _shortLabel(b.label);
      final tp = TextPainter(
        text: TextSpan(text: label, style: textStyle),
        textDirection: ui.TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: barW + 6);

      tp.paint(canvas, Offset(x - 2, baseY + 2));
    }
  }

  String _shortLabel(String raw) {
    // "YYYY-MM-DD" => "DD/MM"
    if (raw.length >= 10 && raw[4] == '-' && raw[7] == '-') {
      final mm = raw.substring(5, 7);
      final dd = raw.substring(8, 10);
      return '$dd/$mm';
    }
    return raw;
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.bars != bars || 
           oldDelegate.maxV != maxV || 
           oldDelegate.hoveredIndex != hoveredIndex;
  }
}
