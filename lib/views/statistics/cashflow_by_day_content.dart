import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/views/widgets/generic_data_table.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/stats_viewmodel.dart';

class CashflowByDayContent extends StatefulWidget {
  const CashflowByDayContent({super.key});

  @override
  State<CashflowByDayContent> createState() => _CashflowByDayContentState();
}

class _CashflowByDayContentState extends State<CashflowByDayContent> {
  late final StatsViewModel _viewModel;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<StatsViewModel>();
    
    _dateFrom = _viewModel.cashflowDateFrom;
    _dateTo = _viewModel.cashflowDateTo;

    // Charge initial
    _viewModel.loadCashflowByDay(_dateFrom!, _dateTo!);
  }

  Future<void> _applyDateRange() async {
    if (_dateFrom != null && _dateTo != null) {
      await _viewModel.loadCashflowByDay(_dateFrom!, _dateTo!);
    }
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

                // Totals row
                _buildTotalsCard(viewModel),
                const SizedBox(height: 20),

                // Data table
                _buildDataTable(viewModel),
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
                _buildFromPicker(),
                _buildToPicker(),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Bouton actualiser
          AnimatedBuilder(
            animation: viewModel,
            builder: (context, child) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 42, maxWidth: 160),
                child: ElevatedButton.icon(
                  onPressed: viewModel.isLoading ? null : _applyDateRange,
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

  Widget _buildTotalsCard(StatsViewModel vm) {
    final cashflow = vm.cashflowByDay;
    final totals = cashflow?.totals;

    if (totals == null && vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (totals == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.industrialPrimary.withOpacity(0.2)),
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
          const Text(
            'Totaux',
            style: TextStyle(
              color: AppColors.industrialText,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _TotalChip(
                label: 'Encaissement',
                value: totals.totalEncaissement,
                color: AppColors.success,
              ),
              _TotalChip(
                label: 'Crédit restant',
                value: totals.totalCreditRestant,
                color: AppColors.warning,
              ),
              _TotalChip(
                label: 'Frais',
                value: totals.totalFrais,
                color: AppColors.danger,
              ),
              _TotalChip(
                label: 'Salaires',
                value: totals.totalSalaires,
                color: AppColors.danger,
              ),
              _TotalChip(
                label: 'Net Cashflow',
                value: totals.totalNetCashflow,
                color: totals.totalNetCashflow >= 0 ? AppColors.success : AppColors.danger,
                isHighlight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(StatsViewModel vm) {
    final cashflow = vm.cashflowByDay;
    final dailyData = cashflow?.dailyData ?? [];

    if (dailyData.isEmpty && vm.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dailyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Text(
            'Aucune donnée pour cette période',
            style: TextStyle(color: AppColors.industrialTextLight),
          ),
        ),
      );
    }

    final columns = <DataTableColumn<dynamic>>[
      DataTableColumn<dynamic>(label: 'Date', value: (e) => _formatDate(e.date)),
      DataTableColumn<dynamic>(label: 'Encaissement', value: (e) => _formatMoney(e.encaissementTotal)),
      DataTableColumn<dynamic>(label: 'Crédit restant', value: (e) => _formatMoney(e.creditRestant)),
      DataTableColumn<dynamic>(label: 'Frais', value: (e) => _formatMoney(e.frais)),
      DataTableColumn<dynamic>(label: 'Salaires', value: (e) => _formatMoney(e.salaires)),
      DataTableColumn<dynamic>(
        label: 'Net Cashflow',
        value: (e) {
          final value = e.netCashflow;
          return _formatMoney(value);
        },
      ),
    ];

    return GenericDataTable<dynamic>(
      columns: columns,
      items: dailyData,
      onEdit: (item) {},
      onDelete: (item) {},
      showActions: false,
      total: dailyData.length,
      currentPage: 1,
      totalPages: 1,
      showPagination: false,
      emptyMessage: 'Aucune donnée',
      isLoading: vm.isLoading,
    );
  }

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return _dateFormat.format(d);
    } catch (_) {
      return date;
    }
  }

  String _formatMoney(num value) {
    final f = NumberFormat.decimalPattern('fr_FR');
    return '${f.format(value)} DZD';
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isHighlight;

  const _TotalChip({
    required this.label,
    required this.value,
    required this.color,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHighlight ? 16 : 12,
        vertical: isHighlight ? 10 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: isHighlight ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.industrialTextLight,
              fontSize: isHighlight ? 13 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.decimalPattern('fr_FR').format(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isHighlight ? 18 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
