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
import '../services/material_service.dart';
import '../services/weighing_slip_service.dart';
import '../services/maintenance_service.dart';
import '../services/worker_service.dart';
import '../services/payment_service.dart';
import '../services/salary_payement.dart';
import '../services/stats_service.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/client_viewmodel.dart';
import '../viewmodels/material_viewmodel.dart';
import '../viewmodels/weighing_slip_viewmodel.dart';
import '../viewmodels/maintenance_viewmodel.dart';
import '../viewmodels/worker_viewmodel.dart';
import '../viewmodels/credit_payment_viewmodel.dart';
import '../viewmodels/salary_payement_viewmodel.dart';
import '../viewmodels/clients_credit_viewmodel.dart';
import '../viewmodels/clients_with_slips_viewmodel.dart';
import '../viewmodels/stats_viewmodel.dart';

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

  getIt.registerLazySingleton<MaterialService>(
    () => MaterialService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<WeighingSlipService>(
    () => WeighingSlipService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<MaintenanceService>(
    () => MaintenanceService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<WorkerService>(
    () => WorkerService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<PaymentService>(
    () => PaymentService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SalaryPaymentService>(
    () => SalaryPaymentService(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<StatsService>(
    () => StatsService(getIt<ApiClient>()),
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

  getIt.registerFactory<MaterialViewModel>(
    () => MaterialViewModel(getIt<MaterialService>()),
  );

  getIt.registerFactory<WeighingSlipViewModel>(
    () => WeighingSlipViewModel(getIt<WeighingSlipService>()),
  );

  getIt.registerFactory<MaintenanceViewModel>(
    () => MaintenanceViewModel(getIt<MaintenanceService>()),
  );

  getIt.registerFactory<WorkerViewModel>(
    () => WorkerViewModel(getIt<WorkerService>()),
  );

  getIt.registerFactory<CreditPaymentViewModel>(
    () => CreditPaymentViewModel(getIt<PaymentService>()),
  );

  getIt.registerFactory<SalaryPaymentViewModel>(
    () => SalaryPaymentViewModel(getIt<SalaryPaymentService>()),
  );
  getIt.registerFactory<ClientsCreditViewModel>(
    () => ClientsCreditViewModel(getIt<ClientService>()),
  );

  getIt.registerFactory<ClientsWithSlipsViewModel>(
    () => ClientsWithSlipsViewModel(getIt<ClientService>()),
  );

  getIt.registerFactory<StatsViewModel>(
    () => StatsViewModel(getIt<StatsService>()),
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
