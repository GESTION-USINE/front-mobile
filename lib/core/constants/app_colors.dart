import 'package:flutter/material.dart';

/// Constantes de couleurs centralisées
/// Cette approche permet de :
/// - Réutiliser les couleurs partout dans l'app
/// - Changer une couleur globalement en un seul endroit
/// - Garder une cohérence visuelle
class AppColors {
  AppColors._(); // Constructeur privé pour empêcher l'instantiation

  // ==================== COULEURS PRINCIPALES (DESIGN) ====================
  static const Color primary = Color(0xFF271450); // Violet
  static const Color primaryVariant = Color(0xFF1A0D2E);
  static const Color secondary = Color(0xFFEFD081); // Jaune
  static const Color secondaryVariant = Color(0xFFD4B85F);
  static const Color accent = Color(0xFF279F0F); // Vert

  // ==================== MODE CLAIR ====================
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFF000000);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // ==================== MODE SOMBRE ====================
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnError = Color(0xFF000000);

  // ==================== COULEURS NEUTRES ====================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);

  // ==================== COULEURS SÉMANTIQUES ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  static const Color danger = Color(0xFFF44336);

  // ==================== DESIGN INDUSTRIEL (USINE) ====================
  // Couleurs principales pour l'interface de gestion d'usine
  static const Color industrialPrimary = Color(0xFF1E3A5F); // Bleu marine foncé
  static const Color industrialPrimaryMedium = Color(0xFF2C5F8D); // Bleu marine moyen
  static const Color industrialBackground = Color(0xFFF5F7FA); // Gris très clair
  static const Color industrialText = Color(0xFF37474F); // Gris foncé pour texte
  static const Color industrialTextLight = Color(0xFF757575); // Gris moyen pour texte secondaire
  static const Color industrialBorder = Color(0xFFE0E0E0); // Gris clair pour bordures
  static const Color industrialHover = Color(0xFF1565C0); // Bleu pour hover
  
  // Couleurs pour messages d'erreur
  static const Color errorBackground = Color(0xFFFFEBEE);
  static const Color errorBorder = Color(0xFFEF5350);
  static const Color errorText = Color(0xFFD32F2F);

  // ==================== OMBRES & TRANSPARENCES ====================
  /// Shadow: 0px 10px 4px 0px #00000040
  static const Color shadowColor = Color(0x40000000); // 25% opacity noir
  static const Color transparentBlack = Color(0x00000000);
  static const Color semiTransparentBlack = Color(0x80000000); // 50% opacity
  static const Color whiteTransparent10 = Color(0x1AFFFFFF); // 10% opacity blanc
  static const Color whiteTransparent20 = Color(0x33FFFFFF); // 20% opacity blanc
}
