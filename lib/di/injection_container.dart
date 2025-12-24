import 'package:get_it/get_it.dart';

import '../core/network/api_client.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/interfaces/i_auth_service.dart';
import '../services/interfaces/i_product_service.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/client_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';

final getIt = GetIt.instance;

/// Initialiser toutes les dépendances
Future<void> initDependencies() async {
  // ==================== Core ====================
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // ==================== Providers ====================
  // Singletons car état global partagé
  getIt.registerLazySingleton<UserProvider>(() => UserProvider());
  getIt.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  getIt.registerLazySingleton<LocaleProvider>(() => LocaleProvider());

  // ==================== Services ====================
  // Singletons car pas d'état interne
  getIt.registerLazySingleton<IAuthService>(
    () => AuthService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<IProductService>(
    () => ProductService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ClientService>(
    () => ClientService(getIt<ApiClient>()),
  );

  // ==================== ViewModels ====================
  // Factory car nouvelle instance par écran
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      getIt<IAuthService>(),
      getIt<UserProvider>(),
      getIt<ApiClient>(),
    ),
  );


  getIt.registerFactory<ProductViewModel>(
    () => ProductViewModel(getIt<IProductService>()),
  );

  getIt.registerFactory<ClientViewModel>(
    () => ClientViewModel(getIt<ClientService>()),
  );

  // ==================== Initialisation ====================
  await _initializeProviders();
}

/// Initialiser les providers qui nécessitent une initialisation async
Future<void> _initializeProviders() async {
  await getIt<ThemeProvider>().init();
  await getIt<LocaleProvider>().init();
  await getIt<UserProvider>().init();

  // Configurer le token dans ApiClient si l'utilisateur est déjà connecté
  final token = getIt<UserProvider>().token;
  if (token != null) {
    getIt<ApiClient>().setToken(token);
  }
}
