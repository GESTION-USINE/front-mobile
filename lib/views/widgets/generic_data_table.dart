import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Colonne générique pour le tableau de données
class DataTableColumn<T> {
  final String label;
  final dynamic Function(T item) value;
  final bool isWidget;
  final bool hideOnMobile;

  DataTableColumn({
    required this.label,
    required this.value,
    this.isWidget = false,
    this.hideOnMobile = false,
  });
}

/// Widget tableau générique réutilisable
class GenericDataTable<T> extends StatefulWidget {
  final List<T> items;
  final List<DataTableColumn<T>> columns;
  final Function(T item) onEdit;
  final Function(T item) onDelete;
  final bool showActions;
  final bool showEditAction;
  final bool showDeleteAction;
  final String editLabel;
  final String deleteLabel;
  final int total;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final bool showPagination;
  final double emptyHeight;
  final String emptyMessage;
  final String? errorMessage;
  final bool isLoading;
  final bool hasError;
  final Color actionTextColor;
  final IconData editIcon;
  final IconData deleteIcon;
  final bool enableCustomWindow;
  final Widget Function(BuildContext, T, VoidCallback)? customDrawerBuilder;
  final Function(T)? onOpenCustomWindow;
  final bool? isCustomWindowOpen;
  final Function(bool)? onToggleCustomWindow;
  final bool showCustomActionButton;
  final IconData customActionIcon;
  final String customActionTooltip;
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
    final isMobile = MediaQuery.of(context).size.width < 768;

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.errorMessage ?? 'Une erreur est survenue',
                  textAlign: TextAlign.center,
                ),
              ),
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

    if (!widget.enableCustomWindow) return mainContent;

    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        mainContent,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Text(
                            col.label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 2,
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
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            // Détails additionnels
            if (widget.columns.where((col) => !col.hideOnMobile).length > 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Text(
                              col.label,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.grey600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 2,
                            child: col.isWidget
                                ? (value is Widget ? value : const Text('-'))
                                : Text(
                                    value?.toString() ?? '-',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.industrialText,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            // Actions
            if (widget.showActions || widget.showCustomActionButton)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.showActions)
                      Row(
                        mainAxisSize: MainAxisSize.min,
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
                      )
                    else
                      const SizedBox.shrink(),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxHeight = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : MediaQuery.of(context).size.height * 0.6;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            color: AppColors.industrialBackground,
                            child: Row(
                              children: [
                                ...widget.columns.where((col) => !col.hideOnMobile).map((col) {
                                  return Expanded(
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  );
                                }),
                                if (widget.showActions)
                                  SizedBox(
                                    width: _getActionColumnWidth(),
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
                          // Rows (scrollable vertically with bounded height)
                          ConstrainedBox(
                            constraints: BoxConstraints(maxHeight: maxHeight),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                              return Expanded(
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
                                                width: _getActionColumnWidth(),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 8,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
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
                                                              minWidth: 36,
                                                              minHeight: 36,
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
                                                              minWidth: 36,
                                                              minHeight: 36,
                                                            ),
                                                          ),
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
                                                            minWidth: 36,
                                                            minHeight: 36,
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
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        const SizedBox(height: 16),
        if (widget.showPagination) _buildPagination(),
      ],
    );
  }

  double _getActionColumnWidth() {
    // Allow room for icon button min size (36) plus padding; prevent horizontal overflow.
    const double perButtonWidth = 72.0;
    int actionButtonCount = 0;
    if (widget.showCustomActionButton) actionButtonCount++;
    if (widget.showEditAction) actionButtonCount++;
    if (widget.showDeleteAction) actionButtonCount++;
    return actionButtonCount * perButtonWidth;
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          
          if (isMobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: ${widget.total} éléments',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
            );
          }
          
          return Row(
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
          );
        },
      ),
    );
  }

  Widget _buildSlidingPanel(BuildContext context) {
    final content = (_selectedItem != null && widget.customDrawerBuilder != null)
        ? widget.customDrawerBuilder!(context, _selectedItem as T, _closeWindow)
        : (_selectedItem != null
            ? _defaultDrawerContent(context)
            : const SizedBox.shrink());

    return content;
  }

  Widget _defaultDrawerContent(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Aucun composant de fenêtre fourni. Passez `customDrawerBuilder` pour afficher le contenu.',
          style: TextStyle(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}