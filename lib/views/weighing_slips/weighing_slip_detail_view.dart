import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/views/credits/payment_details_page.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show base64Decode;
import 'package:open_file/open_file.dart';

// Conditional imports - only one will be used at compile time
import 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_mobile.dart'
    if (dart.library.html) 'file_saver_web.dart';

import '../../core/constants/app_colors.dart';
import '../../di/injection_container.dart';
import '../../models/entities/weighing_slip.dart';
import '../../services/weighing_slip_service.dart';

class WeighingSlipDetailView extends StatefulWidget {
  final int slipId;
  final WeighingSlip? initialSlip;
  final bool isEmployee;

  const WeighingSlipDetailView({
    super.key,
    required this.slipId,
    this.initialSlip,
    this.isEmployee = false,
  });

  @override
  State<WeighingSlipDetailView> createState() => _WeighingSlipDetailViewState();
}

class _WeighingSlipDetailViewState extends State<WeighingSlipDetailView> {
  late Future<WeighingSlip> _slipFuture;

  String _formatPaymentType(String? type) {
    if (type == null || type.isEmpty) return 'Espèces';
    switch (type.toLowerCase()) {
      case 'cash':
        return 'Espèces';
      case 'check':
      case 'cheque':
        return 'Chèque';
      default:
        return type;
    }
  }

  void _openPaymentDetails(WeighingSlip slip) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentDetailsPage(weighingSlipId: slip.id),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Toujours charger depuis l'API pour avoir toutes les données (price_per_ton, etc.)
    final service = getIt<WeighingSlipService>();
    _slipFuture = service.getSlipById(widget.slipId);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeighingSlip>(
      future: _slipFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.industrialText,
              elevation: 0,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: AppColors.warning),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Aucune donnée')),
          );
        }

        final slip = snapshot.data!;
        return Scaffold(
          backgroundColor: AppColors.grey100,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.industrialText,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/weighing-slips');
                }
              },
            ),
            title: const Text('Bon de pesée'),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Imprimer',
                onPressed: () => _printPdf(context, slip.id),
              ),
              if (!widget.isEmployee)
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Modifier',
                  onPressed: () {
                    context.go('/weighing-slips/${slip.id}/edit', extra: slip);
                  },
                ),
            ],
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.grey300, width: 2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'BON DE PESÉE',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.industrialPrimary,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'N° ${slip.slipNumber ?? '#${slip.id}'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'DATE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grey600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  slip.createdAt
                                      .toIso8601String()
                                      .substring(0, 10),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.industrialText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          // Client Info
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FACTURÉ À',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.grey600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      slip.clientName ??
                                          'Client #${slip.clientId}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.industrialText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: slip.isFullyPaid
                                      ? AppColors.success
                                      : AppColors.warning,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  slip.isFullyPaid ? 'PAYÉ' : 'IMPAYÉ',
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: const BoxDecoration(
                              color: AppColors.grey100,
                              border: Border(
                                top: BorderSide(color: AppColors.grey300),
                                bottom: BorderSide(color: AppColors.grey300),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'DESCRIPTION',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'POIDS',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'PRIX/T',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'MONTANT',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.grey600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table Row
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.grey300),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    slip.materialName ??
                                        'Matériau #${slip.materialId}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.industrialText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${slip.weightTons.toStringAsFixed(2)} T',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.industrialText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '${slip.pricePerTon.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.industrialText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    '${slip.totalAmount.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.industrialText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Total Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Sous-total: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          '${slip.totalAmount.toStringAsFixed(2)} DA',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.industrialText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Payé: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          '${(slip.totalPaid ?? 0).toStringAsFixed(2)} DA',
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Text(
                                        'Type paiement: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey600,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          _formatPaymentType(slip.paymentType),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.industrialText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 16),
                                    decoration: const BoxDecoration(
                                      color: AppColors.grey100,
                                      border: Border(
                                        top: BorderSide(
                                            color: AppColors.grey300, width: 2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text(
                                          'RESTE À PAYER: ',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.industrialText,
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            '${(slip.remainingCredit ?? 0).toStringAsFixed(2)} DA',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: slip.remainingCredit !=
                                                          null &&
                                                      slip.remainingCredit! > 0
                                                  ? AppColors.warning
                                                  : AppColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.grey100,
                        border: Border(
                          top: BorderSide(color: AppColors.grey300),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (slip.invoiceId != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Facture N°',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  Text(
                                    slip.invoiceId.toString(),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.industrialText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ),
          ),
        );
      },
    );
  }

  Future<void> _printPdf(BuildContext context, int slipId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: SizedBox(
            height: 50,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );

      final service = getIt<WeighingSlipService>();
      final response = await service.printSlipPdf(slipId);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Get filename from content-disposition or use default
      String filename = 'bon-pesee-$slipId.pdf';
      final contentDisposition = response.headers['content-disposition'];
      if (contentDisposition != null && contentDisposition.isNotEmpty) {
        final match = RegExp(r'filename=([^;]+)')
            .firstMatch(contentDisposition.toString());
        if (match != null) {
          filename = match.group(1)!.replaceAll('"', '').trim();
        }
      }

      // Handle response data
      List<int> bytes;

      // Debug: Check what type of data we received

      if (response.data is List<int>) {
        bytes = response.data as List<int>;
      } else if (response.data is List) {
        // Convert List<dynamic> to List<int>
        try {
          bytes = (response.data as List).cast<int>();
        } catch (e) {
          // If cast fails, try manual conversion
          bytes = List<int>.from(
              response.data.map((e) => e is int ? e : int.parse(e.toString())));
        }
      } else if (response.data is String) {
        // If it's a string, it might be base64 encoded
        try {
          bytes = base64Decode(response.data as String);
        } catch (e) {
          // Last resort: treat as UTF-8 encoded string (likely wrong for PDF)
          throw Exception(
              'Les données PDF ne sont pas dans le format attendu. Vérifiez la configuration du serveur.');
        }
      } else {
        throw Exception(
            'Format de données PDF invalide: ${response.data.runtimeType}');
      }

      // Save the file using platform-specific implementation
      final result = await saveFile(bytes, filename);

      if (context.mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
              action: result.filePath != null
                  ? SnackBarAction(
                      label: 'Ouvrir',
                      textColor: AppColors.white,
                      onPressed: () async {
                        try {
                          await OpenFile.open(result.filePath!);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Impossible d\'ouvrir le fichier: ${e.toString()}'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                          }
                        }
                      },
                    )
                  : null,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      }
    } on DioException catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réseau: ${e.message}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    }
  }
}
