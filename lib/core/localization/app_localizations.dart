import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
  ];

  // Traductions
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'Flutter MVVM',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'retry': 'Retry',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',

      // Auth
      'login': 'Login',
      'signup': 'Sign Up',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'name': 'Name',
      'forgot_password': 'Forgot Password?',
      'no_account': 'Don\'t have an account?',
      'have_account': 'Already have an account?',
      'login_success': 'Login successful',
      'signup_success': 'Account created successfully',
      'logout_confirm': 'Are you sure you want to logout?',

      // Validation
      'email_required': 'Email is required',
      'email_invalid': 'Please enter a valid email',
      'password_required': 'Password is required',
      'password_min_length': 'Password must be at least 6 characters',
      'name_required': 'Name is required',
      'name_min_length': 'Name must be at least 2 characters',
      'passwords_not_match': 'Passwords do not match',

      // Home
      'home': 'Home',
      'welcome': 'Welcome',
      'welcome_message': 'Welcome to our app!',

      // Products
      'products': 'Products',
      'product_details': 'Product Details',
      'add_product': 'Add Product',
      'no_products': 'No products available',
      'price': 'Price',
      'description': 'Description',

      // Profile
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'my_account': 'My Account',

      // Settings
      'settings': 'Settings',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'system_mode': 'System Default',
      'english': 'English',
      'french': 'French',
      'appearance': 'Appearance',
      'about': 'About',
      'version': 'Version',

      // Errors
      'network_error': 'Network error. Please check your connection.',
      'server_error': 'Server error. Please try again later.',
      'unauthorized_error': 'Session expired. Please login again.',
      'unknown_error': 'An unexpected error occurred.',
    },
    'fr': {
      // Général
      'app_name': 'Flutter MVVM',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'retry': 'Réessayer',
      'ok': 'OK',
      'yes': 'Oui',
      'no': 'Non',

      // Auth
      'login': 'Connexion',
      'signup': 'Inscription',
      'logout': 'Déconnexion',
      'email': 'Email',
      'password': 'Mot de passe',
      'confirm_password': 'Confirmer le mot de passe',
      'name': 'Nom',
      'forgot_password': 'Mot de passe oublié ?',
      'no_account': 'Pas encore de compte ?',
      'have_account': 'Déjà un compte ?',
      'login_success': 'Connexion réussie',
      'signup_success': 'Compte créé avec succès',
      'logout_confirm': 'Êtes-vous sûr de vouloir vous déconnecter ?',

      // Validation
      'email_required': 'L\'email est requis',
      'email_invalid': 'Veuillez entrer un email valide',
      'password_required': 'Le mot de passe est requis',
      'password_min_length': 'Le mot de passe doit contenir au moins 6 caractères',
      'name_required': 'Le nom est requis',
      'name_min_length': 'Le nom doit contenir au moins 2 caractères',
      'passwords_not_match': 'Les mots de passe ne correspondent pas',

      // Home
      'home': 'Accueil',
      'welcome': 'Bienvenue',
      'welcome_message': 'Bienvenue dans notre application !',

      // Products
      'products': 'Produits',
      'product_details': 'Détails du produit',
      'add_product': 'Ajouter un produit',
      'no_products': 'Aucun produit disponible',
      'price': 'Prix',
      'description': 'Description',

      // Profile
      'profile': 'Profil',
      'edit_profile': 'Modifier le profil',
      'my_account': 'Mon compte',

      // Settings
      'settings': 'Paramètres',
      'language': 'Langue',
      'theme': 'Thème',
      'dark_mode': 'Mode sombre',
      'light_mode': 'Mode clair',
      'system_mode': 'Système par défaut',
      'english': 'Anglais',
      'french': 'Français',
      'appearance': 'Apparence',
      'about': 'À propos',
      'version': 'Version',

      // Erreurs
      'network_error': 'Erreur réseau. Vérifiez votre connexion.',
      'server_error': 'Erreur serveur. Veuillez réessayer plus tard.',
      'unauthorized_error': 'Session expirée. Veuillez vous reconnecter.',
      'unknown_error': 'Une erreur inattendue est survenue.',
    },
  };

  /// Obtenir une traduction par clé
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Raccourcis pratiques
  String get appName => translate('app_name');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get retry => translate('retry');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');

  // Auth
  String get login => translate('login');
  String get signup => translate('signup');
  String get logout => translate('logout');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get name => translate('name');
  String get forgotPassword => translate('forgot_password');
  String get noAccount => translate('no_account');
  String get haveAccount => translate('have_account');
  String get loginSuccess => translate('login_success');
  String get signupSuccess => translate('signup_success');
  String get logoutConfirm => translate('logout_confirm');

  // Validation
  String get emailRequired => translate('email_required');
  String get emailInvalid => translate('email_invalid');
  String get passwordRequired => translate('password_required');
  String get passwordMinLength => translate('password_min_length');
  String get nameRequired => translate('name_required');
  String get nameMinLength => translate('name_min_length');
  String get passwordsNotMatch => translate('passwords_not_match');

  // Home
  String get home => translate('home');
  String get welcome => translate('welcome');
  String get welcomeMessage => translate('welcome_message');

  // Products
  String get products => translate('products');
  String get productDetails => translate('product_details');
  String get addProduct => translate('add_product');
  String get noProducts => translate('no_products');
  String get price => translate('price');
  String get description => translate('description');

  // Profile
  String get profile => translate('profile');
  String get editProfile => translate('edit_profile');
  String get myAccount => translate('my_account');

  // Settings
  String get settings => translate('settings');
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get systemMode => translate('system_mode');
  String get english => translate('english');
  String get french => translate('french');
  String get appearance => translate('appearance');
  String get about => translate('about');
  String get version => translate('version');

  // Errors
  String get networkError => translate('network_error');
  String get serverError => translate('server_error');
  String get unauthorizedError => translate('unauthorized_error');
  String get unknownError => translate('unknown_error');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension pour un accès facile
extension LocalizationExtension on BuildContext {
  AppLocalizations get tr => AppLocalizations.of(this);
}
