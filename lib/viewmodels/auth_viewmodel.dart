import '../core/base/base_viewmodel.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/request/login_request.dart';
import '../providers/user_provider.dart';
import '../services/interfaces/i_auth_service.dart';

class AuthViewModel extends BaseViewModel {
  final IAuthService _authService;
  final UserProvider _userProvider;
  final ApiClient _apiClient;

  AuthViewModel(this._authService, this._userProvider, this._apiClient);

  /// Connexion
  Future<bool> login(String username, String password, {bool isRemote = false}) async {
    // Validation locale
    final validationError = _validateLogin(username, password);
    if (validationError != null) {
      setError(validationError);
      return false;
    }

    final request = LoginRequest(
      username: username.trim(), 
      password: password,
      isRemote: isRemote,
    );

    final response = await runAsync(() => _authService.login(request));

    if (response != null) {
      await _userProvider.setUser(response.user, response.accessToken);
      _apiClient.setToken(response.accessToken);
      return true;
    }

    return false;
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {
      // On déconnecte même si l'appel API échoue
    }

    _apiClient.setToken(null);
    await _userProvider.clear();
  }

  /// Validation du login
  String? _validateLogin(String username, String password) {
    if (username.isEmpty) {
      return 'Le nom d\'utilisateur est requis';
    }

    if (username.length < 3) {
      return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
    }

    if (password.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (password.length < AppConstants.minPasswordLength) {
      return 'Le mot de passe doit contenir au moins ${AppConstants.minPasswordLength} caractères';
    }

    return null;
  }

  
  /// Vérifier si l'email est valide
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
