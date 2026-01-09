import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../exceptions/app_exceptions.dart';

/// États possibles d'un ViewModel
enum ViewState { idle, loading, success, error }

/// ViewModel de base avec gestion d'état commune
abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  bool _isDisposed = false;

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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
