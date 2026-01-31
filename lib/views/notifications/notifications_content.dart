import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../di/injection_container.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../models/entities/notification_item.dart';

/// Contenu de la liste des notifications (sans wrapper)
class NotificationsContent extends StatefulWidget {
  const NotificationsContent({super.key});

  @override
  State<NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<NotificationsContent> {
  late final NotificationViewModel _viewModel;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  int? _selectedNotificationId;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<NotificationViewModel>();
    _viewModel.loadNotifications();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilters(viewModel),
              const SizedBox(height: 12),
              Expanded(
                child: _buildNotificationsList(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(NotificationViewModel viewModel) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<bool?>(
            value: viewModel.isReadFilter,
            isExpanded: true,
            style: const TextStyle(color: AppColors.industrialText, fontSize: 14),
            dropdownColor: AppColors.white,
            decoration: AppTheme.industrialInputDecoration(
              hint: 'Statut',
              prefixIcon: Icons.notifications,
            ).copyWith(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(
                value: null,
                child: Text('Toutes', style: TextStyle(color: AppColors.industrialText)),
              ),
              DropdownMenuItem(
                value: false,
                child: Text('Non lues', style: TextStyle(color: AppColors.industrialText)),
              ),
              DropdownMenuItem(
                value: true,
                child: Text('Lues', style: TextStyle(color: AppColors.industrialText)),
              ),
            ],
            onChanged: (value) => viewModel.filterByReadStatus(value),
          ),
        ),
        IconButton(
          onPressed: () => viewModel.refresh(),
          icon: const Icon(Icons.refresh, color: AppColors.industrialPrimary),
          tooltip: 'Rafraîchir',
        ),
      ],
    );
  }

  Widget _buildNotificationsList(NotificationViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.errorText),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage ?? 'Une erreur est survenue',
              style: const TextStyle(color: AppColors.errorText),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => viewModel.refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            const Text(
              'Aucune notification',
              style: TextStyle(fontSize: 18, color: AppColors.grey600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: viewModel.notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == viewModel.notifications.length) {
          return _buildPaginationControls(viewModel);
        }
        final notification = viewModel.notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    final isSelected = _selectedNotificationId == notification.id;
    final isRead = notification.isRead;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? AppColors.industrialPrimary
              : (isRead ? AppColors.grey200 : AppColors.industrialPrimary.withOpacity(0.3)),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () async {
          // Marquer comme lue si ce n'est pas déjà fait
          if (!isRead) {
            await _viewModel.markNotificationAsRead(notification.id);
          }
          
          setState(() {
            _selectedNotificationId = isSelected ? null : notification.id;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête : Titre + Date + Statut
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicateur non lu
                  if (!isRead)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 6, right: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.industrialPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  // Titre
                  Expanded(
                    child: Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                        color: AppColors.industrialText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icône selon le type
                  _buildTypeIcon(notification.type),
                  const SizedBox(width: 12),
                  // Date
                  Text(
                    _dateFormat.format(notification.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),

              // Message complet (si sélectionné)
              if (isSelected) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.industrialText,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'payment':
      case 'paiement':
        icon = Icons.payments;
        color = AppColors.success;
        break;
      case 'credit':
        icon = Icons.credit_card;
        color = AppColors.warning;
        break;
      case 'alert':
      case 'alerte':
        icon = Icons.warning;
        color = AppColors.errorText;
        break;
      case 'info':
        icon = Icons.info;
        color = AppColors.info;
        break;
      default:
        icon = Icons.notifications;
        color = AppColors.industrialPrimary;
    }

    return Icon(icon, size: 20, color: color);
  }

  Widget _buildPaginationControls(NotificationViewModel viewModel) {
    if (viewModel.totalPages <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: viewModel.hasPreviousPage ? () => viewModel.previousPage() : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Page précédente',
          ),
          const SizedBox(width: 16),
          Text(
            'Page ${viewModel.currentPage} / ${viewModel.totalPages}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.industrialText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: viewModel.hasNextPage ? () => viewModel.nextPage() : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Page suivante',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isRead) {
    final color = isRead ? AppColors.success : AppColors.warning;
    final label = isRead ? 'Lue' : 'Non lue';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
