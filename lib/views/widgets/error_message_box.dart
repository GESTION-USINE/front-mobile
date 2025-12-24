import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Widget réutilisable pour afficher des messages d'erreur
/// avec un style cohérent dans toute l'application
class ErrorMessageBox extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ErrorMessageBox({
    super.key,
    required this.message,
    this.margin = const EdgeInsets.only(bottom: 20),
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: AppTheme.errorContainerDecoration,
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.errorText,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.errorText,
            ),
          ),
        ],
      ),
    );
  }
}
