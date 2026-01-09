import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/entities/weighing_slip.dart';
import '../../models/request/create_payment_request.dart';
import '../../viewmodels/credit_payment_viewmodel.dart';

class PaymentFormPage extends StatefulWidget {
  final WeighingSlip slip;

  const PaymentFormPage({
    super.key,
    required this.slip,
  });

  @override
  State<PaymentFormPage> createState() => _PaymentFormPageState();
}

class _PaymentFormPageState extends State<PaymentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _checkBankController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentType = 'cash';
  DateTime _paymentDate = DateTime.now();
  DateTime _checkDate = DateTime.now();
  String _checkStatus = 'cashed';
  bool _isLoading = false;

  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');

  @override
  void initState() {
    super.initState();
    _amountController.text = (widget.slip.remainingCredit ?? 0).toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _checkNumberController.dispose();
    _checkBankController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckDate ? _checkDate : _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() {
        if (isCheckDate) {
          _checkDate = picked;
        } else {
          _paymentDate = picked;
        }
      });
    }
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = CreatePaymentRequest(
        weighingSlipId: widget.slip.id,
        paymentType: _paymentType,
        amountPaid: double.parse(_amountController.text.replaceAll(',', '.')),
        paymentDate: DateFormat('yyyy-MM-dd').format(_paymentDate),
        checkNumber: _paymentType != 'cash' ? _checkNumberController.text.trim() : null,
        checkDate: _paymentType != 'cash'
            ? DateFormat('yyyy-MM-dd').format(_checkDate)
            : null,
        checkBank: _paymentType != 'cash' ? _checkBankController.text.trim() : null,
        checkStatus: _paymentType != 'cash' ? 'cashed' : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      );

      final response = await context.read<CreditPaymentViewModel>().createPayment(request);

      if (!mounted) return;
      if (response.success) {
        Navigator.of(context).pop();
        _showSuccessDialog();
      } else {
        _showErrorDialog(response.error ?? 'Une erreur est survenue', response.details);
      }
    } catch (e) {
      if (!mounted) return;
      
      // Parse DioException to extract error code
      if (e is DioException && e.response != null) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        // Handle 403 - CHECK_NOT_ALLOWED
        if (statusCode == 403) {
          _showErrorDialog('CHECK_NOT_ALLOWED', null);
          return;
        }
        
        // Try to extract error from response body
        if (data is Map) {
          if (data['error'] is Map) {
            final err = data['error'] as Map;
            final code = err['code']?.toString();
            final message = err['message']?.toString();
            final details = err['details'] is Map ? err['details'] as Map<String, dynamic> : null;
            _showErrorDialog(code ?? message ?? e.toString(), details);
            return;
          } else if (data['error'] is String) {
            _showErrorDialog(data['error'] as String, null);
            return;
          }
        }
      }
      
      _showErrorDialog(e.toString(), null);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String error, Map<String, dynamic>? details) {
    String message = error;

    if (error == 'WEIGHING_SLIP_NOT_FOUND') {
      message = 'Bon de pesée introuvable';
    } else if (error == 'FORBIDDEN_NOT_TODAY') {
      message = 'Vous ne pouvez payer que les bons d\'aujourd\'hui';
    } else if (error == 'CHECK_NOT_ALLOWED') {
      message = 'Le paiement par chèque n\'est pas autorisé pour ce client';
    } else if (error == 'PAYMENT_EXCEEDS_REMAINING') {
      message = 'Le montant dépasse le crédit restant';
      if (details != null && details['remaining_credit'] != null) {
        message += '\nCrédit restant: ${_currencyFormat.format(details['remaining_credit'])}';
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Erreur'),
          ],
        ),
        content: Text("Client n'a pas possibilite de payer par cheque."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 32),
            SizedBox(width: 12),
            Text('Succès'),
          ],
        ),
        content: const Text(
          'Le paiement a été enregistré avec succès',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enregistrer un paiement'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.industrialText,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bon n° ${widget.slip.slipNumber ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Client: ${widget.slip.clientName ?? '-'}'),
                              const SizedBox(height: 4),
                              Text(
                                'Montant total: ${_currencyFormat.format(widget.slip.totalAmount)}',
                                style: const TextStyle(color: AppColors.grey700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Déjà payé: ${_currencyFormat.format(widget.slip.totalPaid ?? 0)}',
                                style: const TextStyle(color: AppColors.success),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Crédit restant: ${_currencyFormat.format(widget.slip.remainingCredit ?? 0)}',
                                style: const TextStyle(color: AppColors.lightError),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Type de paiement',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('Espèces'),
                              selected: _paymentType == 'cash',
                              onSelected: (value) {
                                if (value) {
                                  setState(() {
                                    _paymentType = 'cash';
                                  });
                                }
                              },
                            ),
                            ChoiceChip(
                              label: const Text('Chèque'),
                              selected: _paymentType == 'check',
                              onSelected: (value) {
                                if (value) {
                                  setState(() {
                                    _paymentType = 'check';
                                  });
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Montant payé',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]{0,2}')),
                          ],
                          decoration: InputDecoration(
                            prefixText: 'DZD ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer un montant';
                            }
                            final parsed = double.tryParse(value.replaceAll(',', '.'));
                            if (parsed == null) {
                              return 'Montant invalide';
                            }
                            if (parsed <= 0) {
                              return 'Le montant doit être supérieur à 0';
                            }
                            if (parsed > (widget.slip.remainingCredit ?? 0)) {
                              return 'Le montant dépasse le crédit restant';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            final normalized = value.replaceAll(',', '.');
                            if (normalized != value) {
                              _amountController.value = _amountController.value.copyWith(
                                text: normalized,
                                selection: TextSelection.collapsed(offset: normalized.length),
                              );
                            }
                          },
                        ),

                        const SizedBox(height: 16),

                        if (_paymentType == 'check') ...[
                          const Text(
                            'Informations chèque',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),

                          const Text(
                            'Numéro du chèque',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _checkNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(20),
                            ],
                            decoration: InputDecoration(
                              hintText: '20 chiffres requis',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (_paymentType == 'check') {
                                if (value == null || value.isEmpty) {
                                  return 'Numéro de chèque requis';
                                }
                                if (value.length != 20) {
                                  return 'Le numéro doit contenir exactement 20 chiffres';
                                }
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            'Banque',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _checkBankController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (_paymentType == 'check' && (value == null || value.isEmpty)) {
                                return 'Banque requise';
                              }
                              return null;
                            },
                          ),

                        ],

                        const SizedBox(height: 16),

                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              TextButton(
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                                child: const Text('Annuler'),
                              ),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _submitPayment,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : const Icon(Icons.check),
                                label: Text(_isLoading ? 'Enregistrement...' : 'Enregistrer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
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
            ),
          ),
        ),
      ),
    );
  }
}
