import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert' show base64Decode;
import 'dart:io' show File, Platform;
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';

// Conditional imports - only one will be used at compile time
import '../weighing_slips/file_saver_stub.dart'
    if (dart.library.io) '../weighing_slips/file_saver_mobile.dart'
    if (dart.library.html) '../weighing_slips/file_saver_web.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/entities/invoice.dart';
import '../../viewmodels/invoice_viewmodel.dart';
import '../../services/invoice_service.dart';
import '../../providers/user_provider.dart';
import '../../routes/app_router.dart';

class InvoiceDetailView extends StatefulWidget {
  final int invoiceId;
  final Invoice? initialInvoice;

  const InvoiceDetailView({
    super.key,
    required this.invoiceId,
    this.initialInvoice,
  });

  @override
  State<InvoiceDetailView> createState() => _InvoiceDetailViewState();
}

class _InvoiceDetailViewState extends State<InvoiceDetailView> {
  late final InvoiceViewModel _viewModel;
  Invoice? _invoice;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<InvoiceViewModel>();
    _invoice = widget.initialInvoice;
    _loadInvoiceDetails();
  }

  Future<void> _loadInvoiceDetails() async {
    setState(() {
      _isLoading = true;
    });

    final invoice = await _viewModel.loadInvoiceDetails(widget.invoiceId);

    if (mounted) {
      setState(() {
        _invoice = invoice ?? widget.initialInvoice;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    final userRole = user?.role.toLowerCase() ?? '';
    final bool canEdit = userRole == 'super_admin' || userRole == 'associe';

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
              context.go(AppRouter.invoices);
            }
          },
        ),
        title: const Text('Facture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Imprimer',
            onPressed: _invoice != null ? () => _printInvoice() : null,
          ),
          if (canEdit && _invoice != null)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
              onPressed: () {
                context.go('/invoices/${widget.invoiceId}/edit', extra: _invoice);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _invoice == null
              ? _buildNotFound()
              : Align(
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
                      child: _buildContent(),
                    ),
                  ),
                ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Facture non trouvée',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRouter.invoices),
            style: AppTheme.industrialPrimaryButton,
            child: const Text('Retour aux factures'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final slips = _invoice!.weighingSlips ?? [];

    return Column(
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.grey300),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Titre facture
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FACTURE',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.industrialPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _invoice!.invoiceNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _formatDate(_invoice!.createdAt),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
                          _invoice!.clientName ?? 'Client #${_invoice!.clientId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_invoice!.clientPhone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _invoice!.clientPhone!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                        if (_invoice!.clientAddress != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _invoice!.clientAddress!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _invoice!.isFullyPaid
                          ? AppColors.success
                          : AppColors.warning,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _invoice!.isFullyPaid ? 'PAYÉE' : 'EN COURS',
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      flex: 2,
                      child: Text(
                        'BON DE PESÉE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'MATÉRIAU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'POIDS',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w600,
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
                          fontWeight: FontWeight.w600,
                          color: AppColors.grey600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Table Rows
              if (slips.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.grey300),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucun bon de pesée',
                      style: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              else
                ...slips.map((slip) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.grey300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  slip.slipNumber ?? 'Bon #${slip.id}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: slip.isFullyPaid
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.warning.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    slip.isFullyPaid ? 'Payé' : 'Crédit',
                                    style: TextStyle(
                                      color: slip.isFullyPaid
                                          ? AppColors.success
                                          : AppColors.warning,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              slip.materialName ?? 'Matériau',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.grey700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '${slip.weightTons.toStringAsFixed(2)} T',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '${slip.pricePerTon.toStringAsFixed(2)}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              '${slip.totalAmount.toStringAsFixed(2)} DA',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

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
                            'Sous-total:',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(width: 40),
                          SizedBox(
                            width: 140,
                            child: Text(
                              '${_invoice!.totalAmount.toStringAsFixed(2)} DA',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Payé:',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey600,
                            ),
                          ),
                          const SizedBox(width: 40),
                          SizedBox(
                            width: 140,
                            child: Text(
                              '${_invoice!.totalPaid.toStringAsFixed(2)} DA',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'RESTE À PAYER:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.grey700,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Text(
                              '${_invoice!.remainingCredit.toStringAsFixed(2)} DA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _invoice!.remainingCredit > 0
                                    ? AppColors.errorText
                                    : AppColors.success,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre de bons:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    '${_invoice!.weighingSlipsCount} bon(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Créé le:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  Text(
                    _formatDate(_invoice!.createdAt),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _printInvoice() async {
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

      final service = getIt<InvoiceService>();
      final response = await service.printInvoicePdf(widget.invoiceId);

      if (mounted) {
        Navigator.of(context).pop();
      }

      // Get filename from content-disposition or use default
      String filename = 'facture-${_invoice!.invoiceNumber}.pdf';
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
          throw Exception(
              'Les données PDF ne sont pas dans le format attendu. Vérifiez la configuration du serveur.');
        }
      } else {
        throw Exception(
            'Format de données PDF invalide: ${response.data.runtimeType}');
      }

      // Desktop: laisser choisir l'emplacement
      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: 'Enregistrer la facture',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (savePath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Enregistrement annulé'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
          return;
        }

        final file = File(savePath.endsWith('.pdf') ? savePath : '$savePath.pdf');
        await file.writeAsBytes(bytes, flush: true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Enregistré dans ${file.path}'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Ouvrir',
                textColor: AppColors.white,
                onPressed: () async {
                  try {
                    await OpenFile.open(file.path);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Impossible d'ouvrir le fichier: ${e.toString()}"),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      } else {
        // Mobile / Web : fallback vers le saveFile existant (Downloads / dialog web)
        final result = await saveFile(bytes, filename);

        if (mounted) {
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
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Impossible d'ouvrir le fichier: ${e.toString()}"),
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
      }
    } on DioException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur réseau: ${e.message}'),
            backgroundColor: AppColors.errorText,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.errorText,
          ),
        );
      }
    }
  }
}
