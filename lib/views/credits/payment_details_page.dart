import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/response/payment_details_response.dart';
import '../../services/payment_service.dart';

class PaymentDetailsPage extends StatefulWidget {
  final int weighingSlipId;

  const PaymentDetailsPage({
    super.key,
    required this.weighingSlipId,
  });

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  late Future<PaymentDetailsResponse> _futureDetails;
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    final paymentService = getIt<PaymentService>();
    _futureDetails = paymentService.getPaymentDetails(widget.weighingSlipId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Bon de Pesée'),
        backgroundColor: AppColors.industrialPrimary,
        foregroundColor: AppColors.white,
      ),
      body: FutureBuilder<PaymentDetailsResponse>(
        future: _futureDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.success || snapshot.data!.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data?.error ?? 'Impossible de charger les détails',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data!;
          final slip = data.slip;
          final payments = data.payments;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Slip Information Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bon n° ${slip.slipNumber ?? '-'}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.industrialPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow('Client', slip.client.name),
                            _buildInfoRow('Matériau', slip.material.name),
                            _buildInfoRow('Date création', _dateFormat.format(slip.createdAt)),
                            const Divider(height: 24),
                            _buildInfoRow('Poids (tonnes)', slip.weightTons.toStringAsFixed(2)),
                            _buildInfoRow('Prix/tonne', _currencyFormat.format(slip.pricePerTon)),
                            _buildInfoRow(
                              'Montant total',
                              _currencyFormat.format(slip.totalAmount),
                              isHighlight: true,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Montant payé',
                              _currencyFormat.format(slip.creditInfo.totalPaid),
                              color: AppColors.success,
                            ),
                            _buildInfoRow(
                              'Crédit restant',
                              _currencyFormat.format(slip.creditInfo.remainingCredit),
                              color: AppColors.warning,
                            ),
                            _buildInfoRow(
                              'Statut',
                              slip.creditInfo.isFullyPaid ? 'Payé' : 'Crédit',
                              color: slip.creditInfo.isFullyPaid ? AppColors.success : AppColors.warning,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Payments Header
                    const Text(
                      'Versements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Payments List
                    if (payments.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              'Aucun versement enregistré',
                              style: TextStyle(
                                color: AppColors.grey600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ...payments.map((payment) => _buildPaymentCard(payment)).toList(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color, bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.grey600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.industrialText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(PaymentDetail payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versement du ${payment.paymentDate}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPaymentTypeColor(payment.paymentType),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    payment.paymentType == 'cash' ? 'Espèces' : 'Chèque',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Montant',
              _currencyFormat.format(payment.amountPaid),
              color: AppColors.success,
              isHighlight: true,
            ),
            const SizedBox(height: 8),
            if (payment.paymentType == 'check') ...[
              _buildInfoRow('Numéro chèque', payment.checkNumber ?? '-'),
              _buildInfoRow('Banque', payment.checkBank ?? '-'),
              _buildInfoRow('Date chèque', payment.checkDate ?? '-'),
              _buildInfoRow(
                'Statut chèque',
                _getCheckStatusLabel(payment.checkStatus),
              ),
            ],
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Notes', payment.notes!),
            ],
            const SizedBox(height: 8),
            Text(
              'Enregistré par: ${payment.createdByUsername ?? 'Utilisateur'} (${_dateFormat.format(payment.createdAt)})',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentTypeColor(String type) {
    return type == 'cash' ? AppColors.success : AppColors.industrialPrimary;
  }

  String _getCheckStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'cleared':
        return 'Compensé';
      case 'bounced':
        return 'Rejeté';
      default:
        return status ?? '-';
    }
  }
}
