import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../di/injection_container.dart';
import '../../models/entities/credit_risk_stats.dart';
import '../../viewmodels/credit_risk_viewmodel.dart';

/// Widget pour afficher les statistiques de risque de crédit
class CreditRiskStatsSection extends StatefulWidget {
  final DateTime dateFrom;
  final DateTime dateTo;

  const CreditRiskStatsSection({
    required this.dateFrom,
    required this.dateTo,
    Key? key,
  }) : super(key: key);

  @override
  State<CreditRiskStatsSection> createState() => _CreditRiskStatsSectionState();
}

class _CreditRiskStatsSectionState extends State<CreditRiskStatsSection> {
  late final CreditRiskViewModel _viewModel;
  final _currencyFormat = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CreditRiskViewModel>();
    _loadData();
  }

  void _loadData() {
    _viewModel.setDateRange(widget.dateFrom, widget.dateTo);
  }

  @override
  void didUpdateWidget(CreditRiskStatsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateFrom != widget.dateFrom ||
        oldWidget.dateTo != widget.dateTo) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CreditRiskViewModel>(
        builder: (context, viewModel, child) {
          final stats = viewModel.creditRiskStats;

          if (viewModel.isLoading && stats == null) {
            return const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (viewModel.hasError && stats == null) {
            return Center(
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.danger, size: 40),
                  const SizedBox(height: 12),
                  const Text('Erreur de chargement des données'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          if (stats == null) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildMainKpis(stats),
              const SizedBox(height: 16),
              _buildAlertsSection(stats),
              const SizedBox(height: 16),
              _buildExceededLimitsSection(stats),
              const SizedBox(height: 16),
              _buildClosedCreditsSection(stats),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.industrialPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.industrialPrimary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.industrialPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.warning_amber,
              color: AppColors.industrialPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gestion du Risque de Crédit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.industrialText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Suivi des crédits actifs et des clients à risque',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.industrialTextLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainKpis(CreditRiskStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final cardWidth = isWide
            ? (constraints.maxWidth - 12 * 3) / 4
            : constraints.maxWidth >= 600
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: _CreditKpiCard(
                title: 'Crédits Actifs',
                value: stats.activeCredits.count.toString(),
                subtitle: 'Solde: ${_currencyFormat.format(stats.activeCredits.totalRemaining)} DZD',
                icon: Icons.account_balance_wallet,
                color: AppColors.industrialPrimary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CreditKpiCard(
                title: 'Crédits Fermés',
                value: stats.closedCredits.count.toString(),
                subtitle: 'Période',
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CreditKpiCard(
                title: 'Alertes',
                value: stats.alerts.nearThresholdCount.toString(),
                subtitle: 'Approche du seuil (80%)',
                icon: Icons.warning_amber,
                color: stats.alerts.nearThresholdCount > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: _CreditKpiCard(
                title: 'Limites Dépassées',
                value: stats.clientsExceededLimit.count.toString(),
                subtitle: 'Clients à risque',
                icon: Icons.trending_up,
                color: stats.clientsExceededLimit.count > 0
                    ? AppColors.danger
                    : AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAlertsSection(CreditRiskStats stats) {
    if (stats.alerts.nearThresholdDetails.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.warning_amber,
                    color: AppColors.warning, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crédits en Alerte',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.industrialText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.alerts.nearThresholdCount} crédit(s) approchent du seuil de 80%',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.industrialTextLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.alerts.nearThresholdDetails
              .take(5)
              .map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildAlertRow(alert),
                  ))
              .toList(),
          if (stats.alerts.nearThresholdDetails.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${stats.alerts.nearThresholdDetails.length - 5} autres',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.industrialTextLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertRow(AlertDetail alert) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bon #${alert.slipId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.industrialText,
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      color: Colors.grey.shade200,
                    ),
                    FractionallySizedBox(
                      widthFactor: alert.paidPercentage / 100,
                      child: Container(
                        height: 6,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${alert.paidPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.warning,
              ),
            ),
            Text(
              'Restant: ${_currencyFormat.format(alert.remaining)} DZD',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.industrialTextLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExceededLimitsSection(CreditRiskStats stats) {
    if (stats.clientsExceededLimit.clients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.trending_up,
                    color: AppColors.danger, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Limites de Crédit Dépassées',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.industrialText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.clientsExceededLimit.count} client(s) ont dépassé leur limite',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.industrialTextLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.clientsExceededLimit.clients
              .take(5)
              .map((client) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildExceededLimitRow(client),
                  ))
              .toList(),
          if (stats.clientsExceededLimit.clients.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${stats.clientsExceededLimit.clients.length - 5} autres',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.industrialTextLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExceededLimitRow(ClientExceededLimit client) {
    final exceeded = (client.exceededAmount / client.creditLimit) * 100;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.industrialText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Limit: ${_currencyFormat.format(client.creditLimit)} DZD',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.industrialTextLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${_currencyFormat.format(client.exceededAmount)} DZD',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
                fontSize: 13,
              ),
            ),
            Text(
              '${exceeded.toStringAsFixed(1)}% dépassement',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClosedCreditsSection(CreditRiskStats stats) {
    if (stats.closedCredits.closedCredits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check_circle,
                    color: AppColors.success, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Crédits Fermés',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.industrialText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.closedCredits.count} crédit(s) entièrement payé(s)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.industrialTextLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stats.closedCredits.closedCredits
              .take(5)
              .map((credit) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildClosedCreditRow(credit),
                  ))
              .toList(),
          if (stats.closedCredits.closedCredits.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '+${stats.closedCredits.closedCredits.length - 5} autres',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.industrialTextLight,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClosedCreditRow(ClosedCredit credit) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                credit.clientName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.industrialText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bon #${credit.slipId}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.industrialTextLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _currencyFormat.format(credit.totalAmount),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

/// Carte KPI pour le crédit
class _CreditKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CreditKpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.industrialTextLight,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.industrialTextLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
