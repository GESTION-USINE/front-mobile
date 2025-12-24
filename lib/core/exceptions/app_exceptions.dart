/// Exception de base pour l'application
class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Erreur de connexion réseau
class NetworkException extends AppException {
  NetworkException([String message = 'Erreur de connexion'])
      : super(message);
}

/// Erreur serveur
class ServerException extends AppException {
  ServerException([String message = 'Erreur serveur', int? statusCode])
      : super(message, statusCode: statusCode);
}

/// Non autorisé (401)
class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Non autorisé'])
      : super(message, statusCode: 401);
}

/// Ressource non trouvée (404)
class NotFoundException extends AppException {
  NotFoundException([String message = 'Ressource non trouvée'])
      : super(message, statusCode: 404);
}

/// Erreur de validation
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(String message, {this.fieldErrors}) : super(message);
}

/// Erreur de cache/stockage local
class CacheException extends AppException {
  CacheException([String message = 'Erreur de cache']) : super(message);
}
