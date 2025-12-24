import 'package:flutter/material.dart';
import '../exceptions/app_exceptions.dart';

/// États possibles d'un ViewModel
enum ViewState { idle, loading, success, error }

/// ViewModel de base avec gestion d'état commune
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

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
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  /// Passer à l'état success
  @protected
  void setSuccess() {
    _state = ViewState.success;
    _errorMessage = null;
    notifyListeners();
  }

  /// Passer à l'état error
  @protected
  void setError(String message) {
    _state = ViewState.error;
    _errorMessage = message;
    notifyListeners();
  }

  /// Remettre à l'état idle
  @protected
  void setIdle() {
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
    } catch (e) {
      setError('Une erreur inattendue est survenue');
      return null;
    }
  }

  /// Effacer l'erreur
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      if (_state == ViewState.error) {
        _state = ViewState.idle;
      }
      notifyListeners();
    }
  }
}
