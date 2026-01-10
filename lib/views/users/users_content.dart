import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../widgets/generic_data_table.dart';
import '../../models/user.dart';

/// Contenu de la liste des utilisateurs (sans wrapper)
class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  late final UserViewModel _viewModel;
  final _searchController = TextEditingController();
  String? _selectedRole;
  bool? _selectedIsActive;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<UserViewModel>();
    _viewModel.loadUsers();
    _selectedRole = _viewModel.listRole ?? '';
    _selectedIsActive = _viewModel.listIsActive;
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
      child: Consumer<UserViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre de recherche et filtres
                _buildFilters(viewModel),
                const SizedBox(height: 12),
                // Liste des utilisateurs
                _buildUsersList(viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilters(UserViewModel viewModel) {
    final Widget addButton = SizedBox(
      height: 44,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRouter.usersCreate),
        style: AppTheme.industrialPrimaryButton.copyWith(
          minimumSize: MaterialStateProperty.all(const Size(170, 44)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          ),
        ),
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Nouvel utilisateur'),
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
            hint: 'Rechercher par nom, email, téléphone...',
            prefixIcon: Icons.search,
          ).copyWith(
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.setListSearch('');
                      viewModel.loadUsers();
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            viewModel.setListSearch(value);
          },
          onSubmitted: (value) {
            viewModel.loadUsers();
          },
        ),
      ),

      // Filtre Rôle
      SizedBox(
        width: 220,
        child: DropdownButtonFormField<String?>(
          key: ValueKey(_selectedRole),
          value: _selectedRole ?? '',
          isExpanded: true,
          style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
          dropdownColor: AppColors.white,
          decoration: AppTheme.industrialInputDecoration(
            hint: 'Rôle',
            prefixIcon: Icons.admin_panel_settings,
          ).copyWith(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 2,
              vertical: 2,
            ),
          ),
          items: const [
            DropdownMenuItem(
                value: '',
                child: Text('Tous les rôles',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: 'super_admin',
                child: Text('Super Admin',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: 'associe',
                child: Text('Associé',
                    style: TextStyle(color: AppColors.industrialText))),
            DropdownMenuItem(
                value: 'employe',
                child: Text('Employé',
                    style: TextStyle(color: AppColors.industrialText))),
          ],
          onChanged: (value) {
            setState(() {
              _selectedRole = value;
            });
            viewModel.setListRole(value == '' ? null : value);
            viewModel.loadUsers();
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
            viewModel.setListIsActive(value);
            viewModel.loadUsers();
          },
        ),
      ),

      // Bouton reset filtres
      IconButton(
        onPressed: () {
          setState(() {
            _searchController.clear();
            _selectedRole = '';
            _selectedIsActive = null;
          });
          viewModel.refresh();
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

  Widget _buildUsersList(UserViewModel viewModel) {
    // Colonnes à afficher
    final columnsToDisplay = <DataTableColumn<dynamic>>[
      DataTableColumn<dynamic>(
        label: 'Nom d\'utilisateur',
        value: (user) => user?.username ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Téléphone',
        value: (user) => user?.phone ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Limite Crédit',
        value: (user) => user?.creditLimit ?? '-',
      ),
       DataTableColumn<dynamic>(
        label: 'Crédit Utilisé',
        value: (user) => user?.currentCreditUsed ?? '-',
      ),
      DataTableColumn<dynamic>(
        label: 'Rôle',
        value: (user) {
          final String role = user?.role ?? '-';
          if (role == 'super_admin') return 'Super Admin';
          if (role == 'associe') return 'Associé';
          if (role == 'employe') return 'Employé';
          return role;
        },
      ),
      DataTableColumn<dynamic>(
        label: 'Statut',
        value: (user) => (user?.isActive ?? false) ? 'Actif' : 'Inactif',
      ),
    ];

    return GenericDataTable<dynamic>(
      items: viewModel.users,
      columns: columnsToDisplay,
      showActions: true,
      showEditAction: true,
      showDeleteAction: true,
      deleteLabel: 'Désactiver',
      deleteIcon: Icons.block,
      onEdit: (user) {
        context.go('/users/${user.id}/edit', extra: user);
      },
      onDelete: (user) {
        _confirmDeactivate(user as User, viewModel);
      },
      isLoading: viewModel.isLoading,
      hasError: viewModel.hasError,
      errorMessage: viewModel.errorMessage,
      emptyMessage: 'Aucun utilisateur trouvé',
      total: viewModel.usersPagination?.total ?? 0,
      currentPage: viewModel.listPage,
      totalPages: viewModel.usersPagination?.totalPages ?? 1,
      onPreviousPage: (viewModel.usersPagination?.hasPreviousPage ?? false)
          ? () => viewModel.previousPage()
          : null,
      onNextPage: (viewModel.usersPagination?.hasNextPage ?? false)
          ? () => viewModel.nextPage()
          : null,
      enableCustomWindow: false,
      showCustomActionButton: false,
    );
  }

  Future<void> _confirmDeactivate(User user, UserViewModel viewModel) async {
    if (!mounted) return;

    if (!user.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur déjà désactivé'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver l\'utilisateur ?'),
        content: Text(
            'Utilisateur : ${user.username}\nCette action bloque les accès de cet utilisateur.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: AppTheme.industrialPrimaryButton,
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    viewModel.clearError();
    await viewModel.deactivateUser(user.id);

    if (!mounted) return;

    if (viewModel.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur désactivé avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
      await viewModel.loadUsers(refresh: true);
    } else if (viewModel.hasError) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Désactivation impossible'),
          content: Text(viewModel.errorMessage ?? 'Erreur inconnue'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }
  }
}

