import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SimpleTableColumn<T> {
  final String label;
  final Widget Function(T item) cellBuilder;
  final bool hideOnMobile;

  const SimpleTableColumn({
    required this.label,
    required this.cellBuilder,
    this.hideOnMobile = false,
  });
}

class SimpleTable<T> extends StatelessWidget {
  final List<T> items;
  final List<SimpleTableColumn<T>> columns;
  final Widget Function(T item)? trailingBuilder;
  final void Function(T item)? onRowTap;
  final String emptyMessage;
  final double maxHeightFraction;

  const SimpleTable({
    super.key,
    required this.items,
    required this.columns,
    this.trailingBuilder,
    this.onRowTap,
    this.emptyMessage = 'Aucune donnée trouvée',
    this.maxHeightFraction = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final visibleColumns =
        columns.where((c) => !(isMobile && c.hideOnMobile)).toList();

    if (items.isEmpty) {
      return _buildEmpty();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 4,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxHeight =
                MediaQuery.of(context).size.height * maxHeightFraction;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  color: AppColors.industrialBackground,
                  child: Row(
                    children: [
                      ...visibleColumns.map(
                        (col) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 0),
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
                        ),
                      ),
                      if (trailingBuilder != null)
                        const SizedBox(
                          width: 120,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
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
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: items.map((item) {
                          return InkWell(
                            onTap:
                                onRowTap != null ? () => onRowTap!(item) : null,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: AppColors.grey200, width: 1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  ...visibleColumns.map((col) => Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 12),
                                          child: col.cellBuilder(item),
                                        ),
                                      )),
                                  if (trailingBuilder != null)
                                    SizedBox(
                                      width: 120,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: trailingBuilder!(item),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
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
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.grey400),
          const SizedBox(height: 8),
          Text(
            emptyMessage,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}
