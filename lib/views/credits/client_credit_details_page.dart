import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/response/client_credit_details_response.dart';
import '../../models/entities/weighing_slip.dart';
import '../../services/client_service.dart';
import '../../viewmodels/credit_payment_viewmodel.dart';
import '../../di/injection_container.dart';
import 'payment_form_dialog.dart';

class ClientCreditDetailsPage extends StatefulWidget {
  final int clientId;

  const ClientCreditDetailsPage({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientCreditDetailsPage> createState() => _ClientCreditDetailsPageState();
}

class _ClientCreditDetailsPageState extends State<ClientCreditDetailsPage> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  final _clientService = getIt<ClientService>();
  bool _isLoading = true;
  String? _error;
  ClientCreditDetailsResponse? _details;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _clientService.getClientCreditDetails(widget.clientId);
      setState(() {
        _details = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  WeighingSlip _convertToWeighingSlip(SlipDetail slip) {
    return WeighingSlip(
      id: slip.id,
      slipNumber: slip.slipNumber,
      clientId: _details!.client.id,
      clientName: _details!.client.name,
      materialId: 0, // Not available in SlipDetail
      materialName: slip.materialName,
      weightTons: slip.weightTons,
      pricePerTon: slip.pricePerTon,
      totalAmount: slip.totalAmount,
      invoiceId: null,
      totalPaid: slip.totalPaid,
      remainingCredit: slip.remainingCredit,
      isFullyPaid: slip.isFullyPaid,
      createdBy: slip.createdBy,
      createdAt: slip.createdAt,
    );
  }

  void _openPaymentPage(SlipDetail slip) {
    final weighingSlip = _convertToWeighingSlip(slip);
    final viewModel = getIt<CreditPaymentViewModel>();
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: viewModel,
          child: PaymentFormPage(slip: weighingSlip),
        ),
      ),
    ).then((_) {
      // Reload details after payment
      _loadDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text(
          'Détails Crédit Client',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.industrialText,
        elevation: 0,
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.lightError),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(color: AppColors.lightError)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDetails,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }
Widget _buildContent() {
  if (_details == null) return const SizedBox();

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Les deux cartes sur une seule ligne
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: _buildClientCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildSummaryCard(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSlipsList(),
        ],
      ),
    ),
  );
}

  Widget _buildClientCard() {
    final client = _details!.client;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.05),
              AppColors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Informations Client',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Nom', client.name, icon: Icons.badge),
              _buildInfoRow('Type', client.type == 'particulier' ? 'Particulier' : 'Entreprise', icon: Icons.business),
              if (client.email != null) _buildInfoRow('Email', client.email!, icon: Icons.email_outlined),
              if (client.phone != null) _buildInfoRow('Téléphone', client.phone!, icon: Icons.phone_outlined),
              if (client.address != null) _buildInfoRow('Adresse', client.address!, icon: Icons.location_on_outlined),
              if (client.taxId != null) _buildInfoRow('NIF', client.taxId!, icon: Icons.receipt_long),
              _buildInfoRow('Paiement par chèque', client.canPayByCheck ? 'Oui' : 'Non', icon: Icons.check_circle_outline),
              
            ],
          ),
        ),
      ),
    );
  }

Widget _buildSummaryCard() {
  final summary = _details!.creditSummary;
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.grey200, width: 1),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.03),
            AppColors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Résumé Crédit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Bons', '${summary.totalSlips}', AppColors.info)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Avec Crédit', '${summary.slipsWithActiveCredit}', AppColors.lightError)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Payés', '${summary.fullyPaidSlips}', AppColors.success)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200, width: 1),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Montant Total', 
                    _currencyFormat.format(summary.totalAmount), 
                    icon: Icons.receipt_long_outlined,
                    valueColor: AppColors.grey600,
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 20),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    'Total Payé', 
                    _currencyFormat.format(summary.totalPaid), 
                    valueColor: AppColors.success, 
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(height: 4),
                  const Divider(height: 20),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    'Crédit Restant', 
                    _currencyFormat.format(summary.totalRemainingCredit), 
                    valueColor: summary.totalRemainingCredit > 0 ? AppColors.lightError : AppColors.success, 
                    icon: Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildStatCard(String label, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.15),
          color.withOpacity(0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.4), // Bordure plus visible (0.4 au lieu de 0.3)
        width: 1.5,
      ),
    ),
    child: Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            // Couleur plus foncée pour le texte jaune
            color: color == AppColors.warning 
                ? AppColors.warning.withOpacity(0.95)
                : color.withOpacity(0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
        ),
      ],
    ),
  );
}
  Widget _buildSlipsList() {
    final slips = _details!.slips;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bons de Pesée (${slips.length})',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...slips.map((slip) => _buildSlipCard(slip)),
      ],
    );
  }

  Widget _buildSlipCard(SlipDetail slip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: slip.isFullyPaid ? AppColors.success.withOpacity(0.3) : AppColors.warning.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              slip.isFullyPaid 
                ? AppColors.success.withOpacity(0.05)
                : AppColors.warning.withOpacity(0.05),
              AppColors.white,
            ],
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (slip.isFullyPaid ? AppColors.success : AppColors.warning).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              slip.isFullyPaid ? Icons.check_circle : Icons.pending_outlined,
              color: slip.isFullyPaid ? AppColors.success : AppColors.warning,
              size: 22,
            ),
          ),
          title: Text(
            slip.slipNumber,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            '${slip.materialName} - ${slip.weightTons.toStringAsFixed(2)}T',
            style: const TextStyle(fontSize: 13),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: slip.isFullyPaid ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (slip.isFullyPaid ? AppColors.success : AppColors.warning).withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _currencyFormat.format(slip.remainingCredit),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
                Text(
                  slip.isFullyPaid ? 'Payé' : 'Crédit',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Date', DateFormat('dd/MM/yyyy').format(slip.createdAt)),
                _buildInfoRow('Prix/Tonne', _currencyFormat.format(slip.pricePerTon)),
                _buildInfoRow('Montant Total', _currencyFormat.format(slip.totalAmount)),
                _buildInfoRow('Total Payé', _currencyFormat.format(slip.totalPaid), valueColor: AppColors.success),
                _buildInfoRow('Crédit Restant', _currencyFormat.format(slip.remainingCredit), valueColor: AppColors.warning),
                if (slip.firstPaymentDate != null) ...[
                  const Divider(height: 16),
                  _buildInfoRow('Premier paiement', slip.firstPaymentDate!),
                  if (slip.lastPaymentDate != null) _buildInfoRow('Dernier paiement', slip.lastPaymentDate!),
                  if (slip.paymentDurationDays != null) 
                    _buildInfoRow('Durée paiement', '${slip.paymentDurationDays} jours'),
              ],
              if (!slip.isFullyPaid) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openPaymentPage(slip),
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text('Ajouter un paiement'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
              if (slip.payments.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    'Paiements (${slip.payments.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...slip.payments.map((payment) => _buildPaymentRow(payment)),
                ],
              ],
            ),
          ),
        ],
          ),
        ),
      );
  }

  Widget _buildPaymentRow(PaymentDetail payment) {
    final isCash = payment.paymentType.toLowerCase() == 'cash';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.success.withOpacity(0.08),
            AppColors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isCash ? Icons.payments_outlined : Icons.receipt_long_outlined,
                      size: 20,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isCash ? 'Espèce' : 'Chèque',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currencyFormat.format(payment.amountPaid),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Date: ${payment.paymentDate}', style: const TextStyle(fontSize: 12)),
          if (!isCash && payment.checkNumber != null) ...[
            Text('Chèque N°: ${payment.checkNumber}', style: const TextStyle(fontSize: 12)),
            if (payment.checkDate != null) Text('Date chèque: ${payment.checkDate}', style: const TextStyle(fontSize: 12)),
            if (payment.checkBank != null) Text('Banque: ${payment.checkBank}', style: const TextStyle(fontSize: 12)),
            if (payment.checkStatus != null) Text('Statut: ${payment.checkStatus}', style: const TextStyle(fontSize: 12)),
          ],
          if (payment.notes != null && payment.notes!.isNotEmpty)
            Text('Note: ${payment.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          if (payment.createdByUsername != null)
            Text('Par: ${payment.createdByUsername}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          if (payment.createdAt != null)
            Text('Créé le: ${DateFormat('dd/MM/yyyy HH:mm').format(payment.createdAt!)}', 
              style: const TextStyle(fontSize: 11, color: AppColors.grey600)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.grey500),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.grey600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColors.grey700,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
