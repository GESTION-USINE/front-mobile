import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../models/entities/worker.dart';
import '../../models/request/create_salary_payment_request.dart';
import '../../viewmodels/salary_payement_viewmodel.dart';

/// Formulaire pour créer un paiement de salaire
class CreateSalaryPaymentForm extends StatefulWidget {
  final Worker worker;
  final SalaryPaymentViewModel viewModel;
  final VoidCallback onSuccess;

  const CreateSalaryPaymentForm({
    super.key,
    required this.worker,
    required this.viewModel,
    required this.onSuccess,
  });

  @override
  State<CreateSalaryPaymentForm> createState() =>
      _CreateSalaryPaymentFormState();
}

class _CreateSalaryPaymentFormState extends State<CreateSalaryPaymentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedPaymentMonth;
  DateTime? _selectedPaymentDate;
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _selectedPaymentDate = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPaymentMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPaymentMonth ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.industrialText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedPaymentMonth = picked;
      });
    }
  }

  Future<void> _selectPaymentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedPaymentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.industrialPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.industrialText,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedPaymentDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPaymentMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mois de paiement'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_selectedPaymentDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date de paiement'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final request = CreateSalaryPaymentRequest(
      workerId: widget.worker.id,
      paymentMonth: _dateFormat.format(_selectedPaymentMonth!),
      amount: double.parse(_amountController.text.trim()),
      paymentDate: _selectedPaymentDate!,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final success = await widget.viewModel.createSalaryPayment(request);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paiement de salaire créé avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        _resetForm();
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.viewModel.errorMessage ?? 'Erreur lors de la création',
            ),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _amountController.clear();
    _notesController.clear();
    setState(() {
      _selectedPaymentMonth = null;
      _selectedPaymentDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SalaryPaymentViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajouter un paiement de salaire',
                      style: AppTheme.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Travailleur: ${widget.worker.fullName}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mois de paiement
                    TextFormField(
                      readOnly: true,
                      decoration: AppTheme.industrialInputDecoration(
                        hint: 'Mois de paiement *',
                        prefixIcon: Icons.calendar_month,
                      ).copyWith(
                        hintText: _selectedPaymentMonth != null
                            ? _dateFormat.format(_selectedPaymentMonth!)
                            : 'Sélectionner un mois',
                      ),
                      onTap: _selectPaymentMonth,
                      validator: (value) {
                        if (_selectedPaymentMonth == null) {
                          return 'Le mois de paiement est requis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Montant
                    TextFormField(
                      controller: _amountController,
                      decoration: AppTheme.industrialInputDecoration(
                        hint: 'Montant (DZD) *',
                        prefixIcon: Icons.attach_money,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le montant est requis';
                        }
                        final double? amount = double.tryParse(value.trim());
                        if (amount == null) {
                          return 'Veuillez entrer un montant valide';
                        }
                        if (amount <= 0) {
                          return 'Le montant doit être supérieur à 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Date de paiement
                    TextFormField(
                      readOnly: true,
                      decoration: AppTheme.industrialInputDecoration(
                        hint: 'Date de paiement *',
                        prefixIcon: Icons.calendar_today,
                      ).copyWith(
                        hintText: _selectedPaymentDate != null
                            ? _dateFormat.format(_selectedPaymentDate!)
                            : 'Sélectionner une date',
                      ),
                      onTap: _selectPaymentDate,
                      validator: (value) {
                        if (_selectedPaymentDate == null) {
                          return 'La date de paiement est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: AppTheme.industrialInputDecoration(
                        hint: 'Notes (optionnel)',
                        prefixIcon: Icons.note,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Boutons
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 400;

                        return Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: isSmall ? constraints.maxWidth : null,
                                child: OutlinedButton(
                                  onPressed: viewModel.isLoading
                                      ? null
                                      : _resetForm,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text('Réinitialiser'),
                                ),
                              ),
                              SizedBox(
                                width: isSmall ? constraints.maxWidth : null,
                                child: ElevatedButton.icon(
                                  onPressed:
                                      viewModel.isLoading ? null : _handleSubmit,
                                  style: AppTheme.industrialPrimaryButton,
                                  icon: viewModel.isLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white,
                                          ),
                                        )
                                      : const Icon(Icons.add),
                                  label: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      viewModel.isLoading
                                          ? 'Création...'
                                          : 'Créer le paiement',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
}
