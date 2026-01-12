import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../exceptions/app_exceptions.dart';

/// États possibles d'un ViewModel
enum ViewState { idle, loading, success, error }

/// Configuration de cache par défaut
const Duration _defaultCacheDuration = Duration(minutes: 30);

/// Classe pour gérer le cache avec timestamp
class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration cacheDuration;

  CacheEntry({
    required this.data,
    required this.cacheDuration,
  }) : timestamp = DateTime.now();

  /// Vérifier si le cache est encore valide
  bool get isValid {
    return DateTime.now().difference(timestamp) < cacheDuration;
  }

  /// Durée restante du cache en secondes
  int get remainingSeconds {
    final remaining = cacheDuration.inSeconds -
        DateTime.now().difference(timestamp).inSeconds;
    return remaining > 0 ? remaining : 0;
  }
}

/// ViewModel de base avec gestion d'état commune + cache intelligent
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _isDisposed = false;
  
  /// Flag pour indiquer que c'est un singleton qui ne doit pas être disposé
  bool _isSingleton = false;

  /// Cache map pour stocker les réponses
  final Map<String, CacheEntry> _cache = {};

  /// État actuel
  ViewState get state => _state;

  /// Message d'erreur
  String? get errorMessage => _errorMessage;

  /// Raccourcis pour vérifier l'état
  bool get isIdle => _state == ViewState.idle;
  bool get isLoading => _state == ViewState.loading;
  bool get isSuccess => _state == ViewState.success;
  bool get hasError => _state == ViewState.error;

  /// Passer à l'état loading
  @protected
  void setLoading() {
    if (_isDisposed) return;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// Passer à l'état success
  @protected
  void setSuccess() {
    if (_isDisposed) return;
    _state = ViewState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Passer à l'état error
  @protected
  void setError(String message) {
    if (_isDisposed) return;
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Remettre à l'état idle
  @protected
  void setIdle() {
    if (_isDisposed) return;
    _state = ViewState.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Exécuter une action async avec gestion automatique de l'état
  @protected
  Future<T?> runAsync<T>(Future<T> Function() action) async {
    setLoading();
    try {
      final result = await action();
      setSuccess();
      return result;
    } on AppException catch (e) {
      setError(e.message);
      return null;
    } on DioException catch (e) {
      // Extraire le message d'erreur de la réponse du backend
      String errorMessage = 'Une erreur est survenue';
      try {
        if (e.error is Map<String, dynamic>) {
          final errorData = e.error as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorMessage;
        } else if (e.response?.data != null) {
          final responseData = e.response!.data;
          if (responseData is Map<String, dynamic> && responseData['error'] != null) {
            errorMessage = responseData['error']['message'] ?? errorMessage;
          }
        }
      } catch (_) {
        // ignore parsing errors
      }
      // Log detailed DioException in debug mode
      try {
       
      } catch (_) {}
      setError(errorMessage);
      return null;
    } catch (e) {
      setError('Une erreur inattendue est survenue');
      return null;
    }
  }

  /// Exécuter une action async sans changer l'état en success
  /// Utile pour les actions silencieuses
  @protected
  Future<T?> runAsyncSilent<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException catch (e) {
      setError(e.message);
      return null;
    } on DioException catch (e) {
      // Extraire le message d'erreur de la réponse du backend
      String errorMessage = 'Une erreur est survenue';
      if (e.error is Map<String, dynamic>) {
        final errorData = e.error as Map<String, dynamic>;
        errorMessage = errorData['message'] ?? errorMessage;
      } else if (e.response?.data != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> && responseData['error'] != null) {
          errorMessage = responseData['error']['message'] ?? errorMessage;
        }
      }
      setError(errorMessage);
      return null;
    } catch (e) {
      setError('Une erreur inattendue est survenue');
      return null;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    if (_isDisposed) return;
    if (_errorMessage != null) {
      _errorMessage = null;
      if (_state == ViewState.error) {
        _state = ViewState.idle;
      }
      notifyListeners();
    }
  }

  // ==================== CACHE MANAGEMENT ====================

  /// Stocker une valeur en cache
  @protected
  void setCacheEntry<T>(
    String key,
    T data, {
    Duration cacheDuration = _defaultCacheDuration,
  }) {
    _cache[key] = CacheEntry<T>(
      data: data,
      cacheDuration: cacheDuration,
    );
  }

  /// Récupérer une valeur du cache si elle est valide
  @protected
  T? getCacheEntry<T>(String key) {
    final entry = _cache[key];
    if (entry != null && entry.isValid) {
      return entry.data as T;
    } else if (entry != null && !entry.isValid) {
      // Nettoyer le cache expiré
      _cache.remove(key);
    }
    return null;
  }

  /// Vérifier si une entrée cache existe et est valide
  @protected
  bool isCacheValid(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isValid) return true;
    // Nettoyer le cache expiré
    _cache.remove(key);
    return false;
  }

  /// Obtenir la durée restante du cache en secondes
  @protected
  int getCacheRemainingSeconds(String key) {
    final entry = _cache[key];
    if (entry == null) return 0;
    return entry.remainingSeconds;
  }

  /// Vider tout le cache
  @protected
  void clearAllCache() {
    _cache.clear();
  }

  /// Vider une entrée cache spécifique
  @protected
  void clearCacheEntry(String key) {
    _cache.remove(key);
  }

  /// Obtenir le nombre d'entrées en cache
  @protected
  int get cacheSize => _cache.length;

  // ==================== SINGLETON SUPPORT ====================

  /// Marquer ce ViewModel comme singleton (ne pas disposer)
  @protected
  void markAsSingleton() {
    _isSingleton = true;
  }

  /// Réinitialiser le ViewModel singleton sans vraiment le disposer
  /// Appelé quand on quitte la page mais on veut garder le singleton actif
  @protected
  void reset() {
    if (_isSingleton) {
      _isDisposed = false; // Réactiver le singleton
      _state = ViewState.idle;
      _errorMessage = null;
    }
  }

  @override
  void dispose() {
    // Les singletons ne sont JAMAIS vraiment disposés
    if (_isSingleton) {
      // Au lieu de disposer, on réinitialise simplement l'état
      _isDisposed = false;
      _state = ViewState.idle;
      _errorMessage = null;
      notifyListeners();
      return;
    }
    
    // Pour les factories normales, on dispose vraiment
    _isDisposed = true;
    super.dispose();
  }
}
