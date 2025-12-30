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
class GenericDataTable<T> extends StatefulWidget {
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

  /// Afficher le bouton éditer
  final bool showEditAction;

  /// Afficher le bouton supprimer
  final bool showDeleteAction;

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

  /// Active la fonctionnalité de fenêtre glissante personnalisée
  final bool enableCustomWindow;

  /// Constructeur pour fournir un widget de fenêtre glissante personnalisé
  /// Signature: (BuildContext, item, VoidCallback close)
  final Widget Function(BuildContext, T, VoidCallback)? customDrawerBuilder;

  /// Callback appelé quand la fenêtre glissante s'ouvre (utile pour charger les données)
  final Function(T)? onOpenCustomWindow;

  /// Mode contrôlé: si non-null, le parent contrôle l'ouverture
  final bool? isCustomWindowOpen;
  final Function(bool)? onToggleCustomWindow;

  /// Montrer un bouton dédié dans la colonne Actions pour ouvrir la fenêtre
  final bool showCustomActionButton;
  final IconData customActionIcon;
  final String customActionTooltip;

  /// Callback pour le bouton d'action personnalisée
  final Function(T)? onCustomAction;

  const GenericDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.onEdit,
    required this.onDelete,
    this.showActions = true,
    this.showEditAction = true,
    this.showDeleteAction = true,
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
    this.enableCustomWindow = false,
    this.customDrawerBuilder,
    this.onOpenCustomWindow,
    this.isCustomWindowOpen,
    this.onToggleCustomWindow,
    this.showCustomActionButton = true,
    this.customActionIcon = Icons.local_offer,
    this.customActionTooltip = 'Prix matériaux',
    this.onCustomAction,
  });

  @override
  State<GenericDataTable<T>> createState() => _GenericDataTableState<T>();
}

class _GenericDataTableState<T> extends State<GenericDataTable<T>> with SingleTickerProviderStateMixin {
  T? _selectedItem;
  bool _internalOpen = false;

  bool get _isControlled => widget.isCustomWindowOpen != null && widget.onToggleCustomWindow != null;
  bool get _isOpen => _isControlled ? (widget.isCustomWindowOpen ?? false) : _internalOpen;

  void _openWindow(T item) {
    setState(() {
      _selectedItem = item;
      if (!_isControlled) _internalOpen = true;
    });
    if (widget.onOpenCustomWindow != null) widget.onOpenCustomWindow!(item);
    if (_isControlled) widget.onToggleCustomWindow!(true);
  }

  void _closeWindow() {
    setState(() {
      _selectedItem = null;
      if (!_isControlled) _internalOpen = false;
    });
    if (_isControlled) widget.onToggleCustomWindow!(false);
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer si c'est un petit écran
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Contenu principal (tableau / cartes)
    Widget mainContent;

    if (widget.isLoading) {
      mainContent = SizedBox(
        height: widget.emptyHeight,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (widget.hasError) {
      mainContent = SizedBox(
        height: widget.emptyHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(widget.errorMessage ?? 'Une erreur est survenue'),
            ],
          ),
        ),
      );
    } else if (widget.items.isEmpty) {
      mainContent = SizedBox(
        height: widget.emptyHeight,
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
                widget.emptyMessage,
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
    } else if (isMobile) {
      mainContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.items.map((item) => _buildMobileCard(item, context)),
          const SizedBox(height: 16),
          if (widget.showPagination) _buildPagination(),
        ],
      );
    } else {
      mainContent = _buildDesktopTable();
    }

    // Si la fonctionnalité de fenêtre est désactivée, retourner juste le contenu
    if (!widget.enableCustomWindow) return mainContent;

    // Sinon, envelopper dans un Stack pour afficher la fenêtre plein écran
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        mainContent,
        // Full screen overlay panel
        if (_isOpen)
          Positioned.fill(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isOpen ? 1.0 : 0.0,
              child: Material(
                color: AppColors.white,
                child: SizedBox(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: _buildSlidingPanel(context),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMobileCard(dynamic item, BuildContext context) {
    return InkWell(
      onTap: widget.enableCustomWindow ? () => _openWindow(item) : null,
      child: Container(
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
                children: widget.columns
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
                children: widget.columns
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
            if (widget.showActions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (widget.showEditAction)
                          IconButton(
                            onPressed: () => widget.onEdit(item),
                            icon: Icon(widget.editIcon, color: widget.actionTextColor),
                            tooltip: widget.editLabel,
                          ),
                        if (widget.showDeleteAction)
                          IconButton(
                            onPressed: () => widget.onDelete(item),
                            icon: Icon(widget.deleteIcon, color: AppColors.errorText),
                            tooltip: widget.deleteLabel,
                          ),
                      ],
                    ),
                    if (widget.showCustomActionButton)
                      if (widget.enableCustomWindow)
                        ElevatedButton.icon(
                          onPressed: () => _openWindow(item),
                          icon: Icon(widget.customActionIcon, size: 18),
                          label: const Text('Détails'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.industrialPrimary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        )
                      else if (widget.onCustomAction != null)
                        ElevatedButton.icon(
                          onPressed: () => widget.onCustomAction!(item),
                          icon: Icon(widget.customActionIcon, size: 18),
                          label: const Text('Détails'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.industrialPrimary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculer la largeur de chaque colonne
              const horizontalPadding = 0.0;
              
              // Compter le nombre de boutons d'action visibles
              int actionButtonCount = 0;
              if (widget.showEditAction) actionButtonCount++;
              if (widget.showDeleteAction) actionButtonCount++;
              if (widget.enableCustomWindow && widget.showCustomActionButton) actionButtonCount++;
              
              // Largeur fixe pour la colonne actions basée sur le nombre de boutons
              final actionColumnWidth = widget.showActions ? (actionButtonCount * 48.0) : 0.0;

              final availableWidth = constraints.maxWidth - horizontalPadding - actionColumnWidth;
              final numDataColumns = widget.columns.where((col) => !col.hideOnMobile).length;
              final columnWidth = availableWidth / numDataColumns;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header
                    Container(
                      color: AppColors.industrialBackground,
                      child: Row(
                        children: [
                          ...widget.columns.where((col) => !col.hideOnMobile).map((col) {
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
                          }),
                          if (widget.showActions)
                            SizedBox(
                              width: actionColumnWidth,
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
                    ...widget.items.map((item) {
                      return InkWell(
                        onTap: widget.enableCustomWindow ? () => _openWindow(item) : null,
                        child: Container(
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
                              ...widget.columns.where((col) => !col.hideOnMobile).map((col) {
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
                              }),
                              if (widget.showActions)
                                SizedBox(
                                  width: actionColumnWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 8,
                                    ),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                        if (widget.showEditAction)
                                          IconButton(
                                            onPressed: () => widget.onEdit(item),
                                            icon: Icon(
                                              widget.editIcon,
                                              color: widget.actionTextColor,
                                              size: 20,
                                            ),
                                            tooltip: widget.editLabel,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 20,
                                              minHeight: 40,
                                            ),
                                          ),
                                        if (widget.showDeleteAction)
                                          IconButton(
                                            onPressed: () => widget.onDelete(item),
                                            icon: Icon(
                                              widget.deleteIcon,
                                              color: AppColors.errorText,
                                              size: 20,
                                            ),
                                            tooltip: widget.deleteLabel,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 20,
                                              minHeight: 40,
                                            ),
                                          ),
                                        if (widget.showCustomActionButton)
                                          if (widget.enableCustomWindow)
                                            IconButton(
                                              onPressed: () => _openWindow(item),
                                              icon: Icon(
                                                widget.customActionIcon,
                                                color: widget.actionTextColor,
                                                size: 20,
                                              ),
                                              tooltip: widget.customActionTooltip,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 40,
                                              ),
                                            )
                                          else if (widget.onCustomAction != null)
                                            IconButton(
                                              onPressed: () => widget.onCustomAction!(item),
                                              icon: Icon(
                                                widget.customActionIcon,
                                                color: widget.actionTextColor,
                                                size: 20,
                                              ),
                                              tooltip: widget.customActionTooltip,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 40,
                                              ),
                                            ),
                                      ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (widget.showPagination) _buildPagination(),
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
            'Total: ${widget.total} éléments',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onPreviousPage,
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                'Page ${widget.currentPage} / ${widget.totalPages}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              IconButton(
                onPressed: widget.onNextPage,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingPanel(BuildContext context) {
    // Panel content is provided by the parent via customDrawerBuilder when possible
    final content = (_selectedItem != null && widget.customDrawerBuilder != null)
        ? widget.customDrawerBuilder!(context, _selectedItem as T, _closeWindow)
        : (_selectedItem != null
            ? _defaultDrawerContent(context)
            : const SizedBox.shrink());

    return content;
  }

  Widget _defaultDrawerContent(BuildContext context) {
    return Center(
      child: Text(
        'Aucun composant de fenêtre fourni. Passez `customDrawerBuilder` pour afficher le contenu.',
        style: const TextStyle(color: AppColors.grey600),
      ),
    );
  }
}