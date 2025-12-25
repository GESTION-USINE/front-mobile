class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Flutter MVVM';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 10;

  // Validation
  static const int minPasswordLength = 6;
  static const int minNameLength = 2;
}
