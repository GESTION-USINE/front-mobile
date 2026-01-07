import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/material_viewmodel.dart';
import '../widgets/generic_data_table.dart';

/// Contenu de la liste des matériaux (sans wrapper)
class MaterialsContent extends StatefulWidget {
  const MaterialsContent({super.key});

  @override
  State<MaterialsContent> createState() => _MaterialsContentState();
}

class _MaterialsContentState extends State<MaterialsContent> {
  late final MaterialViewModel _viewModel;
  final _searchController = TextEditingController();
  String? _selectedCategory;
  bool? _selectedIsActive;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<MaterialViewModel>();
    _viewModel.loadMaterials();
    _selectedCategory = _viewModel.categoryFilter ?? '';
    _selectedIsActive = _viewModel.isActiveFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<MaterialViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête et actions sur une seule ligne (wrap responsive)
                _buildFilters(viewModel),
                const SizedBox(height: 12),
                // Liste des matériaux
                _buildMaterialsList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(MaterialViewModel viewModel) {
    final Widget addButton = SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRouter.materialsCreate),
        style: AppTheme.industrialPrimaryButton.copyWith(
          minimumSize: MaterialStateProperty.all(const Size(170, 44)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Nouveau matériau'),
      ),
    );

    final List<Widget> filters = [
      // Recherche
      SizedBox(
        width: 320,
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: AppColors.industrialText),
          decoration: AppTheme.industrialInputDecoration(
            hint: 'Rechercher par nom, description...',
            prefixIcon: Icons.search,
          ).copyWith(
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.searchMaterials('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            viewModel.searchMaterials(value);
          },
        ),
      ),

      // Filtre Catégorie
      SizedBox(
        width: 220,
        child: DropdownButtonFormField<String?>(
          key: ValueKey(_selectedCategory),
          value: _selectedCategory ?? '',
          isExpanded: true,
          style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
          dropdownColor: AppColors.white,
          decoration: AppTheme.industrialInputDecoration(
            hint: 'Catégorie',
            prefixIcon: Icons.category,
          ).copyWith(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 2,
            ),
          ),
          items: const [
            DropdownMenuItem(
                value: '',
                child: Text('Toutes les catégories',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: 'Metaux',
                child: Text('Métaux',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: 'Plastiques',
                child: Text('Plastiques',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: 'Carton',
                child: Text('Carton',
                    style: TextStyle(color: AppColors.industrialText))),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
            viewModel.filterByCategory(value == '' ? null : value);
          },
        ),
      ),

      // Filtre Statut
      SizedBox(
        width: 125,
        child: DropdownButtonFormField<bool?>(
          key: ValueKey(_selectedIsActive),
          value: _selectedIsActive,
          isExpanded: true,
          style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
          dropdownColor: AppColors.white,
          decoration: AppTheme.industrialInputDecoration(
            hint: 'Statut',
            prefixIcon: Icons.toggle_on,
          ).copyWith(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: const [
            DropdownMenuItem(
                value: null,
                child: Text('Tous',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: true,
                child: Text('Actif',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: false,
                child: Text('Inactif',
                    style: TextStyle(color: AppColors.industrialText))),
          ],
          onChanged: (value) {
            setState(() {
              _selectedIsActive = value;
            });
            viewModel.filterByIsActive(value);
          },
        ),
      ),

      // Bouton reset filtres
      IconButton(
        onPressed: () {
          setState(() {
            _searchController.clear();
            _selectedCategory = '';
            _selectedIsActive = null;
          });
          viewModel.resetFilters();
        },
        icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
        tooltip: 'Réinitialiser les filtres',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [...filters, addButton],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: filters,
              ),
            ),
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }

  Widget _buildMaterialsList(MaterialViewModel viewModel) {
    // Colonnes à afficher
    final columnsToDisplay = <DataTableColumn<dynamic>>[
      DataTableColumn<dynamic>(
        label: 'Nom',
        value: (material) => material?.name ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Catégorie',
        value: (material) => material?.category ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Prix/Tonne',
        value: (material) {
          final dynamic price = material?.defaultPricePerTon;
          final double p = price is num ? price.toDouble() : 0.0;
          return '${p.toStringAsFixed(2)} DZD';
        },
      ),
      DataTableColumn<dynamic>(
        label: 'Description',
        value: (material) => material?.description ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Statut',
        value: (material) => (material?.isActive ?? false) ? 'Actif' : 'Inactif',
      ),
    ];

    return GenericDataTable<dynamic>(
      items: viewModel.materials,
      columns: columnsToDisplay,
      showActions: true,
      showEditAction: true,
      showDeleteAction: false,
      onEdit: (material) {
        context.go('/materials/${material.id}/edit', extra: material);
      },
      onDelete: (material) {
        // Delete action disabled
      },
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasError,
      errorMessage: viewModel.errorMessage,
      emptyMessage: 'Aucun matériau trouvé',
      total: viewModel.total,
      currentPage: viewModel.currentPage,
      totalPages: viewModel.totalPages,
      onPreviousPage: viewModel.hasPreviousPage
          ? () => viewModel.previousPage()
          : null,
      onNextPage:
          viewModel.hasNextPage ? () => viewModel.nextPage() : null,
       enableCustomWindow: false,
         showCustomActionButton: false,
    );
  }
}
