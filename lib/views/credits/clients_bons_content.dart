import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/clients_with_slips_viewmodel.dart';
import '../../models/response/clients_with_slips_response.dart';
import '../../di/injection_container.dart';
import 'client_credit_details_page.dart';
import '../widgets/simple_table.dart';
import 'payment_form_dialog.dart';
import '../../models/entities/weighing_slip.dart';
import '../../viewmodels/credit_payment_viewmodel.dart';
import '../weighing_slips/weighing_slip_detail_view.dart';
import '../../services/client_service.dart';
import '../../models/response/client_credit_details_response.dart';

class ClientsBonsContent extends StatefulWidget {
  const ClientsBonsContent({super.key});

  @override
  State<ClientsBonsContent> createState() => _ClientsBonsContentState();
}

class _ClientsBonsContentState extends State<ClientsBonsContent> {
  final _currencyFormat = NumberFormat.currency(locale: 'fr_FR', symbol: 'DZD');
  ClientsWithSlipsViewModel? _viewModel;
  String _searchQuery = '';
  String _filterByStatus = 'all'; // all, active, inactive, with_credit
  String _slipFilterStatus = 'all'; // all, paid, credit
  String _slipSearchQuery = '';
  DateTime? _slipStartDate;
  DateTime? _slipEndDate;
  DateTime? _clientStartDate;
  DateTime? _clientEndDate;
  ClientWithSlips? _selectedClient;
  bool _detailsLoading = false;
  String? _detailsError;
  List<SlipDetail>? _slipDetails = const [];

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ClientsWithSlipsViewModel>();
    _viewModel!.loadClientsWithSlips();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Consumer<ClientsWithSlipsViewModel>(
        builder: (context, viewModel, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (!isWide) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bons Clients', style: AppTheme.headingLarge),
                      Text(
                        'Liste des clients avec leurs bons de pesée et crédits',
                        style: AppTheme.subtitleMedium
                            .copyWith(color: AppColors.grey600),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryCard(viewModel),
                      const SizedBox(height: 16),
                      _buildSearchAndFilterBar(),
                      const SizedBox(height: 16),
                      _buildClientsTable(viewModel, constraints),
                      const SizedBox(height: 16),
                      _buildSelectedClientHeader(),
                      const SizedBox(height: 8),
                      if (_selectedClient != null) _buildSlipsFilterBar(),
                      if (_selectedClient != null) const SizedBox(height: 8),
                      _buildSlipsTable(constraints),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchAndFilterBar(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                            child: _buildClientsTable(viewModel, constraints)),
                        const SizedBox(height: 12),
                        _buildSelectedClientHeader(),
                        const SizedBox(height: 8),
                        if (_selectedClient != null) _buildSlipsFilterBar(),
                        if (_selectedClient != null) const SizedBox(height: 8),
                        Expanded(child: _buildSlipsTable(constraints)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ClientsWithSlipsViewModel viewModel) {
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
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildStatCard(
                      'Clients', '${viewModel.totalClients}', AppColors.info),
                  _buildStatCard('Total Bons', '${viewModel.totalSlips}',
                      AppColors.primary),
                  _buildStatCard('Bons Crédit',
                      '${viewModel.totalSlipsWithCredit}', AppColors.danger),
                  _buildStatCard(
                    'Crédit Restant',
                    _currencyFormat.format(viewModel.totalCredit),
                    AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un client...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.grey600, size: 20),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _filterByStatus = value;
                });
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Row(
                    children: [
                      Icon(Icons.apps_outlined,
                          size: 18, color: AppColors.grey700),
                      SizedBox(width: 10),
                      Text('Tous'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'with_credit',
                  child: Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          size: 18, color: AppColors.warning),
                      SizedBox(width: 10),
                      Text('Avec crédit'),
                    ],
                  ),
                ),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey300, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list_outlined,
                        size: 18, color: AppColors.grey700),
                    const SizedBox(width: 4),
                    Text(
                      _getFilterLabel(),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.grey700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel() {
    switch (_filterByStatus) {
      case 'with_credit':
        return 'Crédit';
      default:
        return 'Tous';
    }
  }

  Widget _buildClientsTable(
      ClientsWithSlipsViewModel viewModel, BoxConstraints constraints) {
    // Apply filters and search
    List<ClientWithSlips> filteredClients = viewModel.clients.where((client) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (client.name.toLowerCase().contains(_searchQuery.toLowerCase())) ||
          (client.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (client.phone?.contains(_searchQuery) ?? false);

      // Apply status filter
      bool matchesStatus = true;
      switch (_filterByStatus) {
        case 'active':
          matchesStatus = client.slipsWithActiveCredit > 0;
          break;
        case 'inactive':
          matchesStatus = client.slipsWithActiveCredit == 0;
          break;
        case 'with_credit':
          matchesStatus = client.totalRemainingCredit > 0;
          break;
        default:
          matchesStatus = true;
      }

      // Apply date filter on client creation date
      bool matchesDate = true;
      if (_clientStartDate != null) {
        matchesDate = matchesDate &&
            client.createdAt
                .isAfter(_clientStartDate!.subtract(const Duration(days: 1)));
      }
      if (_clientEndDate != null) {
        matchesDate = matchesDate &&
            client.createdAt.isBefore(_clientEndDate!.add(const Duration(days: 1)));
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    final columns = <SimpleTableColumn<ClientWithSlips>>[
      SimpleTableColumn<ClientWithSlips>(
        label: 'Nom Client',
        cellBuilder: (c) => Text(
          c.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      SimpleTableColumn<ClientWithSlips>(
        label: 'Email',
        cellBuilder: (c) =>
            Text(c.email ?? '-', overflow: TextOverflow.ellipsis),
        hideOnMobile: true,
      ),
      SimpleTableColumn<ClientWithSlips>(
        label: 'Téléphone',
        cellBuilder: (c) =>
            Text(c.phone ?? '-', overflow: TextOverflow.ellipsis),
      ),
      SimpleTableColumn<ClientWithSlips>(
        label: 'Bons Payés',
        cellBuilder: (c) => Text(
          '${c.fullyPaidSlips}',
          style: const TextStyle(
              color: AppColors.success, fontWeight: FontWeight.w600),
        ),
      ),
      SimpleTableColumn<ClientWithSlips>(
        label: 'Bons Crédit',
        cellBuilder: (c) => Text(
          '${c.slipsWithActiveCredit}',
          style: const TextStyle(
              color: AppColors.danger, fontWeight: FontWeight.w600),
        ),
      ),
      SimpleTableColumn<ClientWithSlips>(
        label: 'Crédit Total',
        cellBuilder: (c) => Text(
          _currencyFormat.format(c.totalRemainingCredit),
          style: const TextStyle(
              color: AppColors.lightError, fontWeight: FontWeight.bold),
        ),
      ),
    ];

    return SimpleTable<ClientWithSlips>(
      items: filteredClients,
      columns: columns,
      onRowTap: (client) {
        setState(() {
          _selectedClient = client;
          _detailsError = null;
          _slipDetails = const [];
        });
        _loadSelectedClientDetails(client.id);
      },
      trailingBuilder: (client) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Sélectionner',
            onPressed: () {
              setState(() {
                _selectedClient = client;
                _detailsError = null;
                _slipDetails = const [];
              });
              _loadSelectedClientDetails(client.id);
            },
            icon: const Icon(Icons.check_circle_outline,
                color: AppColors.industrialPrimary, size: 20),
          ),
          IconButton(
            tooltip: 'Détails',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ClientCreditDetailsPage(clientId: client.id),
                ),
              );
            },
            icon: const Icon(Icons.info_outline,
                color: AppColors.industrialPrimary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedClientHeader() {
    if (_selectedClient == null) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        const Icon(Icons.person_outline, color: AppColors.grey700, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Client sélectionné: ${_selectedClient!.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _selectedClient = null;
            });
          },
          icon: const Icon(Icons.clear, size: 16),
          label: const Text('Effacer'),
        ),
      ],
    );
  }

  Widget _buildSlipsFilterBar() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.filter_list, color: AppColors.grey700, size: 18),
                SizedBox(width: 8),
                Text(
                  'Filtrer les bons',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 220,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _slipSearchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher un bon...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.grey600, size: 18),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
            _buildDateRangeButton(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'Tous',
                  value: 'all',
                  icon: Icons.apps_outlined,
                  color: AppColors.primary,
                ),
                _buildFilterChip(
                  label: 'Payés',
                  value: 'paid',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
                _buildFilterChip(
                  label: 'Crédit',
                  value: 'credit',
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.danger,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    final hasDate = _slipStartDate != null || _slipEndDate != null;
    return InkWell(
      onTap: _selectDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasDate ? AppColors.info.withOpacity(0.12) : AppColors.grey100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDate ? AppColors.info : AppColors.grey300,
            width: hasDate ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: hasDate ? AppColors.info : AppColors.grey600,
            ),
            const SizedBox(width: 8),
            Text(
              _getDateRangeLabel(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                color: hasDate ? AppColors.info : AppColors.grey700,
              ),
            ),
            if (hasDate) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _slipStartDate = null;
                    _slipEndDate = null;
                  });
                },
                child: const Icon(Icons.clear, size: 16, color: AppColors.info),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDateRangeLabel() {
    if (_slipStartDate != null && _slipEndDate != null) {
      return '${DateFormat('dd/MM').format(_slipStartDate!)} - ${DateFormat('dd/MM').format(_slipEndDate!)}';
    }
    if (_slipStartDate != null) {
      return 'Depuis ${DateFormat('dd/MM/yy').format(_slipStartDate!)}';
    }
    if (_slipEndDate != null) {
      return 'Jusqu\'au ${DateFormat('dd/MM/yy').format(_slipEndDate!)}';
    }
    return 'Période';
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _slipStartDate != null && _slipEndDate != null
          ? DateTimeRange(start: _slipStartDate!, end: _slipEndDate!)
          : null,
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.grey700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _slipStartDate = picked.start;
        _slipEndDate = picked.end;
      });
    }
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _slipFilterStatus == value;
    return InkWell(
      onTap: () {
        setState(() {
          _slipFilterStatus = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColors.grey600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlipsTable(BoxConstraints constraints) {
    final client = _selectedClient;
    if (client == null) {
      return SimpleTable<SlipDetail>(
        items: const [],
        columns: const [],
        emptyMessage: 'Sélectionnez un client pour voir ses bons',
      );
    }

    if (_detailsLoading) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 2)),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_detailsError != null) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 32, color: AppColors.lightError),
            const SizedBox(height: 8),
            Text(_detailsError!,
                style: const TextStyle(color: AppColors.lightError)),
          ],
        ),
      );
    }

    final List<SlipDetail> allSlips = _slipDetails ?? const [];

    final query = _slipSearchQuery.trim().toLowerCase();

    final List<SlipDetail> slips = allSlips.where((slip) {
      // Status filter
      bool matchesStatus;
      switch (_slipFilterStatus) {
        case 'paid':
          matchesStatus = slip.isFullyPaid;
          break;
        case 'credit':
          matchesStatus = !slip.isFullyPaid && slip.remainingCredit > 0;
          break;
        default:
          matchesStatus = true;
      }

      // Search filter
      final matchesSearch = query.isEmpty ||
          slip.slipNumber.toLowerCase().contains(query) ||
          slip.materialName.toLowerCase().contains(query);

      // Date filter (inclusive)
      bool matchesDate = true;
      if (_slipStartDate != null) {
        matchesDate = matchesDate &&
            slip.createdAt.isAfter(_slipStartDate!.subtract(const Duration(days: 1)));
      }
      if (_slipEndDate != null) {
        matchesDate = matchesDate &&
            slip.createdAt.isBefore(_slipEndDate!.add(const Duration(days: 1)));
      }

      return matchesStatus && matchesSearch && matchesDate;
    }).toList();

    final columns = <SimpleTableColumn<SlipDetail>>[
      SimpleTableColumn<SlipDetail>(
        label: 'N° Bon',
        cellBuilder: (s) => Text(s.slipNumber, overflow: TextOverflow.ellipsis),
      ),
      SimpleTableColumn<SlipDetail>(
        label: 'Matériau',
        cellBuilder: (s) =>
            Text(s.materialName, overflow: TextOverflow.ellipsis),
      ),
      SimpleTableColumn<SlipDetail>(
        label: 'Montant',
        cellBuilder: (s) => Text(_currencyFormat.format(s.totalAmount),
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      SimpleTableColumn<SlipDetail>(
        label: 'Payé',
        cellBuilder: (s) => Text(_currencyFormat.format(s.totalPaid),
            style: const TextStyle(
                color: AppColors.success, fontWeight: FontWeight.w600)),
      ),
      SimpleTableColumn<SlipDetail>(
        label: 'Crédit',
        cellBuilder: (s) => Text(_currencyFormat.format(s.remainingCredit),
            style: const TextStyle(
                color: AppColors.danger, fontWeight: FontWeight.bold)),
      ),
      SimpleTableColumn<SlipDetail>(
        label: 'Durée (jours)',
        cellBuilder: (s) {
          final d = s.paymentDurationDays;
          final isPaid = s.isFullyPaid;
          if (isPaid && d != null) {
            return Text('$d j',
                style: const TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.w600));
          }
          // Non payé: jours depuis création
          final daysSince = DateTime.now().difference(s.createdAt).inDays;
          return Text('$daysSince j',
              style: const TextStyle(
                  color: AppColors.warning, fontWeight: FontWeight.w600));
        },
      ),
      SimpleTableColumn<SlipDetail>(
        label: 'Date',
        cellBuilder: (s) => Text(DateFormat('dd/MM/yyyy').format(s.createdAt)),
      ),
    ];

    return SimpleTable<SlipDetail>(
      items: slips,
      columns: columns,
      emptyMessage: 'Aucun bon pour ce client',
      onRowTap: (s) => _openSlipDetailsById(s.id),
      trailingBuilder: (s) {
        final canPay = !s.isFullyPaid && s.remainingCredit > 0;
        return ElevatedButton.icon(
          onPressed: canPay ? () => _openPaymentFormDetail(client, s) : null,
          icon: const Icon(Icons.payments, size: 18),
          label: const Text('Payer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.industrialPrimary,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.grey300,
            disabledForegroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        );
      },
    );
  }

  void _openPaymentFormDetail(ClientWithSlips client, SlipDetail s) {
    final weighingSlip = WeighingSlip(
      id: s.id,
      slipNumber: s.slipNumber,
      clientId: client.id,
      clientName: client.name,
      materialId: 0, // non disponible dans SlipDetail
      materialName: s.materialName,
      weightTons: s.weightTons,
      pricePerTon: s.pricePerTon,
      totalAmount: s.totalAmount,
      invoiceId: null,
      totalPaid: s.totalPaid,
      remainingCredit: s.remainingCredit,
      isFullyPaid: s.isFullyPaid,
      createdBy: s.createdBy,
      createdAt: s.createdAt,
    );

    final vm = getIt<CreditPaymentViewModel>();
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: vm,
          child: PaymentFormPage(slip: weighingSlip),
        ),
      ),
    )
        .then((_) {
      _loadSelectedClientDetails(client.id);
      _viewModel?.loadClientsWithSlips();
    });
  }

  void _openSlipDetailsById(int slipId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WeighingSlipDetailView(
          slipId: slipId,
          initialSlip: null,
        ),
      ),
    );
  }

  Future<void> _loadSelectedClientDetails(int clientId) async {
    setState(() {
      _detailsLoading = true;
      _detailsError = null;
    });
    try {
      final service = getIt<ClientService>();
      final response = await service.getClientCreditDetails(clientId);
      setState(() {
        _slipDetails = response.slips;
        _detailsLoading = false;
      });
    } catch (e) {
      setState(() {
        _detailsError = e.toString();
        _detailsLoading = false;
      });
    }
  }
}
