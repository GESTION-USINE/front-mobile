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
  NetworkException([super.message = 'Erreur de connexion']);
}

/// Erreur serveur
class ServerException extends AppException {
  ServerException([super.message = 'Erreur serveur', int? statusCode])
      : super(statusCode: statusCode);
}

/// Non autorisé (401)
class UnauthorizedException extends AppException {
  UnauthorizedException([super.message = 'Non autorisé'])
      : super(statusCode: 401);
}

/// Ressource non trouvée (404)
class NotFoundException extends AppException {
  NotFoundException([super.message = 'Ressource non trouvée'])
      : super(statusCode: 404);
}

/// Erreur de validation
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(super.message, {this.fieldErrors});
}

/// Erreur de cache/stockage local
class CacheException extends AppException {
  CacheException([super.message = 'Erreur de cache']);
}
