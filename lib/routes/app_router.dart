import 'package:flutter/material.dart';
import 'package:flutter_mvvm_template/views/maintenance/maintenance_content.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_provider.dart';
import '../models/entities/client.dart';
import '../models/entities/material.dart' as material_entity;
import '../models/entities/weighing_slip.dart';
import '../models/entities/maintenance_expense.dart';
import '../models/entities/worker.dart';
import '../models/user.dart';
import '../views/auth/login_view.dart';
import '../views/layouts/app_shell.dart';
import '../views/users/users_content.dart';
import '../views/product/product_list_content.dart';
import '../views/product/product_detail_view.dart';
import '../views/invoices/invoices_content.dart';
import '../views/reports/reports_content.dart';
import '../views/traceability/traceability_content.dart';
import '../views/settings/settings_content.dart';
import '../views/clients/clients_content.dart';
import '../views/clients/create_client_view.dart';
import '../views/clients/edit_client_view.dart';
import '../views/materials/materials_content.dart';
import '../views/materials/create_material_view.dart';
import '../views/materials/edit_material_view.dart';
import '../views/weighing_slips/weighing_slips_content.dart';
import '../views/weighing_slips/weighing_slip_detail_view.dart';
import '../views/weighing_slips/edit_weighing_slip_view.dart';
import '../views/weighing_slips/create_weighing_slip_view.dart';
import '../views/maintenance/edit_maintenance_view.dart';
import '../views/maintenance/create_maintenance_view.dart';
import '../views/workers/workers_content.dart';
import '../views/workers/create_worker_view.dart';
import '../views/workers/edit_worker_view.dart';
import '../views/users/create_user_view.dart';
import '../views/users/edit_user_view.dart';
import '../views/credits/credits_content.dart';
import '../views/credits/credits_payments_content.dart';
import '../views/statistics/statistics_dashboard_content.dart';
import '../views/statistics/statistics_sales_content.dart';
import '../views/statistics/statistics_purchases_content.dart';
import '../views/statistics/statistics_inventory_content.dart';
import '../views/statistics/statistics_workers_content.dart';
import '../views/statistics/cashflow_by_day_content.dart';
import '../views/credits/clients_bons_content.dart';
import '../views/credits/client_credit_content.dart';
import '../views/profile/profile_view.dart';

class AppRouter {
  AppRouter._();

  // Clé de navigation globale
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Noms des routes
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String users = '/users';
  static const String usersCreate = '/users/create';
  static const String usersEdit = '/users/:id/edit';
  static const String clients = '/clients';
  static const String clientsCreate = '/clients/create';
  static const String clientsEdit = '/clients/:id/edit';
  static const String materials = '/materials';
  static const String materialsCreate = '/materials/create';
  static const String materialsEdit = '/materials/:id/edit';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String invoices = '/invoices';
  static const String reports = '/reports';
  static const String maintenance = '/maintenance';
  static const String maintenanceCreate = '/maintenance/create';
  static const String maintenanceEdit = '/maintenance/:id/edit';
  static const String workers = '/workers';
  static const String workersCreate = '/workers/create';
  static const String workersEdit = '/workers/:id/edit';
  static const String traceability = '/traceability';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String slips = '/weighing-slips';
  static const String slipsCreate = '/weighing-slips/create';
  static const String slipsDetail = '/weighing-slips/:id';
  static const String slipsEdit = '/weighing-slips/:id/edit';
  static const String credits = '/credits';
  static const String creditsPayments = '/credits-payments';
  static const String clientsBons = '/clients-bons';
  static const String clientsCredit = '/clients-credit';
  static const String statisticsPath = '/statistics';
  static const String statisticsDashboard = '/statistics/dashboard';
  static const String statisticsSales = '/statistics/sales';
  static const String statisticsPurchases = '/statistics/purchases';
  static const String statisticsInventory = '/statistics/inventory';
  static const String statisticsWorkers = '/statistics/workers';
  static const String statisticsCashflow = '/statistics/cashflow';

  /// Crée le router avec redirection basée sur l'authentification
  static GoRouter createRouter(UserProvider userProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: dashboard,
      debugLogDiagnostics: true,

      // Redirection basée sur l'authentification
      redirect: (context, state) {
        final isLoggedIn = userProvider.isLoggedIn;
        final isLoggingIn = state.matchedLocation == login;

        // Si pas connecté et pas sur la page login -> rediriger vers login
        if (!isLoggedIn && !isLoggingIn) {
          return login;
        }

        // Si connecté et sur la page login -> rediriger vers dashboard
        if (isLoggedIn && isLoggingIn) {
          return dashboard;
        }

        // Pas de redirection nécessaire
        return null;
      },

      // Rafraîchir le router quand l'état d'authentification change
      refreshListenable: userProvider,

      routes: [
        // Route de login (hors du shell)
        GoRoute(
          path: login,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginView(),
        ),

        // Route de création client (hors du shell - fullscreen)
        GoRoute(
          path: clientsCreate,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CreateClientView(),
        ),

        GoRoute(
          path: slipsCreate,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CreateWeighingSlipView(),
        ),

        // Route de détails de bon de pesée (hors du shell - fullscreen)
        GoRoute(
          path: slipsDetail,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final slip = state.extra as WeighingSlip?;
            final userRole = userProvider.currentUser?.role.toLowerCase() ?? '';
            final isEmployee = userRole == 'employe';
            return WeighingSlipDetailView(
              slipId: int.parse(id),
              initialSlip: slip,
              isEmployee: isEmployee,
            );
          },
        ),

        // Route de modification client (hors du shell - fullscreen)
        GoRoute(
          path: clientsEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final client = state.extra as Client;
            return EditClientView(
              clientId: int.parse(id),
              initialClient: client,
            );
          },
        ),

        // Route de création matériau (hors du shell - fullscreen, seulement pour non-employés)
        GoRoute(
          path: materialsCreate,
          parentNavigatorKey: _rootNavigatorKey,
          redirect: (context, state) {
            final userRole = userProvider.currentUser?.role;
            if (userRole != null && userRole.toLowerCase() == 'employe') {
              return '/materials'; // Rediriger les employés vers la liste
            }
            return null;
          },
          builder: (context, state) => const CreateMaterialView(),
        ),

        // Route de création de frais de maintenance (hors du shell - fullscreen)
        GoRoute(
          path: maintenanceCreate,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CreateMaintenanceView(),
        ),

        // Route de modification matériau (hors du shell - fullscreen, seulement pour non-employés)
        GoRoute(
          path: materialsEdit,
          parentNavigatorKey: _rootNavigatorKey,
          redirect: (context, state) {
            final userRole = userProvider.currentUser?.role;
            if (userRole != null && userRole.toLowerCase() == 'employe') {
              return '/materials'; // Rediriger les employés vers la liste
            }
            return null;
          },
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final material = state.extra as material_entity.Material;
            return EditMaterialView(
              materialId: int.parse(id),
              initialMaterial: material,
            );
          },
        ),

        // Route de modification de frais de maintenance (hors du shell - fullscreen)
        GoRoute(
          path: maintenanceEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final expense = state.extra as MaintenanceExpense;
            return EditMaintenanceView(
              expenseId: int.parse(id),
              initialExpense: expense,
            );
          },
        ),

        // Route de création de travailleur (hors du shell - fullscreen)
        GoRoute(
          path: workersCreate,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CreateWorkerView(),
        ),

        // Route de modification de travailleur (hors du shell - fullscreen)
        GoRoute(
          path: workersEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final worker = state.extra as Worker;
            return EditWorkerView(initialWorker: worker);
          },
        ),

        // Route de création d'utilisateur (hors du shell - fullscreen)
        GoRoute(
          path: usersCreate,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const CreateUserView(),
        ),

        // Route de modification d'utilisateur (hors du shell - fullscreen)
        GoRoute(
          path: usersEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final user = state.extra as User;
            return EditUserView(
              userId: int.parse(id),
              initialUser: user,
            );
          },
        ),

        // Route de modification de bon de pesée (hors du shell - fullscreen)
        GoRoute(
          path: slipsEdit,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final slip = state.extra as WeighingSlip;
            return EditWeighingSlipView(
              slipId: int.parse(id),
              initialSlip: slip,
            );
          },
        ),

        // Shell avec sidebar et navbar fixes
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return AppShell(
              currentLocation: state.matchedLocation,
              child: child,
            );
          },
          routes: [
            // Dashboard
            GoRoute(
              path: dashboard,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatisticsDashboardContent(),
              ),
            ),

            // Utilisateurs
            GoRoute(
              path: users,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: UsersContent(),
              ),
            ),

            // Clients
            GoRoute(
              path: clients,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ClientsContent(),
              ),
            ),

            // Matériaux (caché pour les employés)
            GoRoute(
              path: materials,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: MaterialsContent(),
              ),
            ),

            // Bons de pesée
            GoRoute(
              path: slips,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WeighingSlipsContent(),
              ),
            ),

            // Crédits
            GoRoute(
              path: credits,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CreditsContent(),
              ),
            ),

            // Encaissements (paiements du jour)
            GoRoute(
              path: creditsPayments,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CreditsPaymentsContent(),
              ),
            ),

            // Bons Clients
            GoRoute(
              path: clientsBons,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ClientsBonsContent(),
              ),
            ),
           
          //  GoRoute(
          //     path: clientsCredit,
          //     pageBuilder: (context, state) => const NoTransitionPage(
          //       child: ClientCreditContent(),
          //     ),
          //   ),

           GoRoute(
            path: maintenance,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MaintenanceContent(),
            ),)
            ,

            // Travailleurs
            GoRoute(
              path: workers,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WorkersContent(),
              ),
            ),

            // Produits
            GoRoute(
              path: products,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProductListContent(),
              ),
              routes: [
                // Détail produit (sous-route)
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final productId = state.pathParameters['id']!;
                    return ProductDetailView(productId: productId);
                  },
                ),
              ],
            ),

            // Factures
            GoRoute(
              path: invoices,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: InvoicesContent(),
              ),
            ),

            // Rapports
            GoRoute(
              path: reports,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ReportsContent(),
              ),
            ),

            // Traçabilité
            GoRoute(
              path: traceability,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TraceabilityContent(),
              ),
            ),

            // Paramètres
            GoRoute(
              path: settings,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsContent(),
              ),
            ),

            // Statistiques - Tableau de bord
            GoRoute(
              path: '$statisticsPath/dashboard',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatisticsDashboardContent(),
              ),
            ),

            // Statistiques - Ventes
            GoRoute(
              path: '$statisticsPath/sales',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SalesStatsContent(),
              ),
            ),

            // Statistiques - Achats
            GoRoute(
              path: '$statisticsPath/purchases',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatisticsPurchasesContent(),
              ),
            ),

            // Statistiques - Inventaire
            GoRoute(
              path: '$statisticsPath/inventory',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatisticsInventoryContent(),
              ),
            ),

            // Statistiques - Travailleurs
            GoRoute(
              path: '$statisticsPath/workers',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatisticsWorkersContent(),
              ),
            ),

            // Statistiques - Flux de trésorerie
            GoRoute(
              path: '$statisticsPath/cashflow',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: CashflowByDayContent(),
              ),
            ),

            // Profil utilisateur
            GoRoute(
              path: profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileView(),
              ),
            ),
          ],
        ),
      ],

      // Page d'erreur
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page non trouvée: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(dashboard),
                child: const Text('Retour au dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
