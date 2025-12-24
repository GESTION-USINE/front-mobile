import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Colonne générique pour le tableau de données
class DataTableColumn<T> {
  /// Label de la colonne
  final String label;

  /// Fonction pour extraire la valeur de l'objet (Widget ou valeur simple)
  final dynamic Function(T item) value;

  /// Si true, la valeur est un Widget ; sinon c'est un texte
  final bool isWidget;

  /// Si true, cacher cette colonne sur les petits écrans
  final bool hideOnMobile;

  /// Constructeur
  DataTableColumn({
    required this.label,
    required this.value,
    this.isWidget = false,
    this.hideOnMobile = false,
  });
}

/// Widget tableau générique réutilisable
class GenericDataTable<T> extends StatelessWidget {
  /// Données à afficher
  final List<T> items;

  /// Colonnes du tableau
  final List<DataTableColumn<T>> columns;

  /// Fonction appelée au clic sur le bouton éditer
  final Function(T item) onEdit;

  /// Fonction appelée au clic sur le bouton supprimer
  final Function(T item) onDelete;

  /// Afficher la colonne d'actions
  final bool showActions;

  /// Label du bouton éditer
  final String editLabel;

  /// Label du bouton supprimer
  final String deleteLabel;

  /// Total d'éléments (pour pagination)
  final int total;

  /// Page actuelle (0-based)
  final int currentPage;

  /// Nombre de pages
  final int totalPages;

  /// Fonction appelée pour aller à la page précédente
  final VoidCallback? onPreviousPage;

  /// Fonction appelée pour aller à la page suivante
  final VoidCallback? onNextPage;

  /// Afficher la pagination
  final bool showPagination;

  /// Hauteur du message vide
  final double emptyHeight;

  /// Message quand aucune donnée
  final String emptyMessage;

  /// Message quand erreur
  final String? errorMessage;

  /// Si en cours de chargement
  final bool isLoading;

  /// Si erreur
  final bool hasError;

  /// Couleur du texte des actions
  final Color actionTextColor;

  /// Icône pour le bouton éditer
  final IconData editIcon;

  /// Icône pour le bouton supprimer
  final IconData deleteIcon;

  const GenericDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.onEdit,
    required this.onDelete,
    this.showActions = true,
    this.editLabel = 'Éditer',
    this.deleteLabel = 'Supprimer',
    this.total = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onPreviousPage,
    this.onNextPage,
    this.showPagination = true,
    this.emptyHeight = 300,
    this.emptyMessage = 'Aucune donnée trouvée',
    this.errorMessage,
    this.isLoading = false,
    this.hasError = false,
    this.actionTextColor = AppColors.industrialPrimary,
    this.editIcon = Icons.edit,
    this.deleteIcon = Icons.delete,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer si c'est un petit écran
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Affichage du chargement
    if (isLoading) {
      return SizedBox(
        height: emptyHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    // Affichage de l'erreur
    if (hasError) {
      return SizedBox(
        height: emptyHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(errorMessage ?? 'Une erreur est survenue'),
            ],
          ),
        ),
      );
    }

    // Affichage quand aucune donnée
    if (items.isEmpty) {
      return SizedBox(
        height: emptyHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.grey400,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sur mobile : afficher une liste de cartes
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((item) => _buildMobileCard(item, context)),
          const SizedBox(height: 16),
          if (showPagination) _buildPagination(),
        ],
      );
    }

    // Sur desktop : afficher le tableau
    return _buildDesktopTable();
  }

  /// Construire la vue mobile (cartes)
  Widget _buildMobileCard(dynamic item, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec infos principales
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns
                  .where((col) => !col.hideOnMobile)
                  .take(2)
                  .map((col) {
                final value = col.value(item);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        col.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey600,
                        ),
                      ),
                      Flexible(
                        child: col.isWidget
                            ? (value is Widget ? value : const Text('-'))
                            : Text(
                                value?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.industrialText,
                                ),
                                textAlign: TextAlign.right,
                              ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Détails additionnels
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: columns
                  .where((col) => !col.hideOnMobile)
                  .skip(2)
                  .map((col) {
                final value = col.value(item);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        col.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey600,
                        ),
                      ),
                      Flexible(
                        child: col.isWidget
                            ? (value is Widget ? value : const Text('-'))
                            : Text(
                                value?.toString() ?? '-',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.industrialText,
                                ),
                                textAlign: TextAlign.right,
                              ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          // Actions
          if (showActions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => onEdit(item),
                    icon: Icon(editIcon, color: actionTextColor),
                    tooltip: editLabel,
                  ),
                  IconButton(
                    onPressed: () => onDelete(item),
                    icon: Icon(deleteIcon, color: AppColors.errorText),
                    tooltip: deleteLabel,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Construire la vue desktop (tableau)
  Widget _buildDesktopTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius:
                BorderRadius.circular(AppTheme.borderRadiusMedium),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculer la largeur de chaque colonne
              const horizontalPadding = 0.0;
              
              final availableWidth = constraints.maxWidth - horizontalPadding;
              final numColumns = columns.length + (showActions ? 1 : 0);
              final columnWidth = availableWidth / numColumns;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: AppColors.industrialBackground,
                      child: Row(
                        children: [
                          ...columns.map((col) {
                            return SizedBox(
                              width: columnWidth,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Text(
                                  col.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.industrialText,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          }).toList(),
                          if (showActions)
                            SizedBox(
                              width: columnWidth,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 16,
                                ),
                                child: Text(
                                  'Actions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.industrialText,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Rows
                    ...items.map((item) {
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.grey200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            ...columns.map((col) {
                              final value = col.value(item);
                              return SizedBox(
                                width: columnWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: col.isWidget
                                      ? (value is Widget
                                          ? value
                                          : const Text('-'))
                                      : Text(
                                          value?.toString() ?? '-',
                                          style: const TextStyle(
                                            color: AppColors.industrialText,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                              );
                            }).toList(),
                            if (showActions)
                              SizedBox(
                                width: columnWidth,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => onEdit(item),
                                        icon: Icon(
                                          editIcon,
                                          color: actionTextColor,
                                        ),
                                        tooltip: editLabel,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => onDelete(item),
                                        icon: Icon(
                                          deleteIcon,
                                          color: AppColors.errorText,
                                        ),
                                        tooltip: deleteLabel,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (showPagination) _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total: $total éléments',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onPreviousPage,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Page $currentPage / $totalPages',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: onNextPage,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
