import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  // Couleurs principales
  static const Color primaryColor = Color(0xFF271450); // Violet
  static const Color primaryVariant = Color(0xFF1A0D2E);
  static const Color secondaryColor = Color(0xFFEFD081); // Jaune
  static const Color secondaryVariant = Color(0xFF279F0F); // Vert

  // ==================== STYLES DE TEXTE RÉUTILISABLES ====================
  
  /// Titre principal (ex: "Bienvenue")
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.industrialPrimary,
    letterSpacing: 0.5,
  );

  /// Sous-titre (ex: "Connectez-vous à votre compte")
  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 16,
    color: AppColors.grey600,
    height: 1.5,
  );

  /// Label de champ de formulaire
  static const TextStyle fieldLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.industrialText,
  );

  /// Texte de placeholder/hint
  static TextStyle hintText = TextStyle(
    color: AppColors.grey400,
    fontSize: 14,
  );

  /// Texte saisi dans les champs (utilisé pour définir la couleur du texte)
  static TextStyle fieldTextStyle({Color? color}) => TextStyle(
        fontSize: 15,
        color: color ?? AppColors.industrialText,
      );

  /// Texte d'erreur
  static const TextStyle errorText = TextStyle(
    color: AppColors.errorText,
    fontSize: 14,
  );

  /// Texte de footer/copyright
  static TextStyle footerText = TextStyle(
    fontSize: 12,
    color: AppColors.grey500,
  );

  /// Texte blanc pour overlay sombre
  static const TextStyle overlayTitle = TextStyle(
    color: AppColors.white,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const TextStyle overlaySubtitle = TextStyle(
    color: Color(0xB3FFFFFF), // Blanc 70%
    fontSize: 18,
    letterSpacing: 0.5,
  );

  static const TextStyle overlayFeature = TextStyle(
    color: AppColors.white,
    fontSize: 16,
  );

  // Couleurs pour le mode clair
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFF000000);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x40000000); // Shadow

  // Couleurs pour le mode sombre
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnError = Color(0xFF000000);

  // ==================== DECORATIONS RÉUTILISABLES ====================
  
  /// Gradient industriel pour panneaux de branding
  static const LinearGradient industrialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.industrialPrimary,
      AppColors.industrialPrimaryMedium,
    ],
  );

  /// Conteneur avec fond semi-transparent pour icônes
  static BoxDecoration iconContainerDecoration = BoxDecoration(
    color: AppColors.whiteTransparent10,
    borderRadius: BorderRadius.circular(20),
  );

  /// Petit conteneur d'icône pour features
  static BoxDecoration featureIconDecoration = BoxDecoration(
    color: AppColors.whiteTransparent10,
    borderRadius: BorderRadius.circular(8),
  );

  /// Conteneur d'erreur
  static BoxDecoration errorContainerDecoration = BoxDecoration(
    color: AppColors.errorBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.errorBorder,
      width: 1,
    ),
  );

  /// Border radius standard
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;

  // Thème clair
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        error: lightError,
        onPrimary: lightOnPrimary,
        onSecondary: lightOnSecondary,
        onSurface: lightOnSurface,
        onError: lightOnError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: lightOnPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(AppColors.secondary),
          foregroundColor: const MaterialStatePropertyAll(AppColors.primary),
          elevation: const MaterialStatePropertyAll(4),
          shadowColor: const MaterialStatePropertyAll(AppTheme.shadowColor),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          minimumSize: const MaterialStatePropertyAll(Size(double.infinity, 48)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: BorderSide(color: AppColors.grey300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.industrialPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          borderSide: const BorderSide(color: AppColors.errorBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIconColor: AppColors.grey600,
        suffixIconColor: AppColors.grey600,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 0.5,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.industrialPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: const MaterialStatePropertyAll(AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  // Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        error: darkError,
        onPrimary: darkOnPrimary,
        onSecondary: darkOnSecondary,
        onSurface: darkOnSurface,
        onError: darkOnError,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: const MaterialStatePropertyAll(AppColors.secondary),
          foregroundColor: const MaterialStatePropertyAll(AppColors.primary),
          elevation: const MaterialStatePropertyAll(4),
          shadowColor: const MaterialStatePropertyAll(AppTheme.shadowColor),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          minimumSize: const MaterialStatePropertyAll(Size(double.infinity, 48)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkError),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 0.5,
      ),
    );
  }

  // ==================== STYLES DE BOUTON PERSONNALISÉS ====================
  
  /// Style de bouton primaire industriel (bleu marine)
  static ButtonStyle get industrialPrimaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.industrialPrimary,
    foregroundColor: AppColors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadiusSmall),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  /// InputDecoration pour champs de login industriel
  static InputDecoration industrialInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    Color? textColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: hintText.copyWith(color: textColor ?? AppColors.grey400),
      prefixIcon: Icon(prefixIcon, color: AppColors.grey600, size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        borderSide: BorderSide(color: AppColors.grey300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        borderSide: BorderSide(color: AppColors.grey300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusSmall),
        borderSide: const BorderSide(color: AppColors.industrialPrimary, width: 2),
      ),
      labelStyle: TextStyle(color: textColor ?? AppColors.industrialText),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
