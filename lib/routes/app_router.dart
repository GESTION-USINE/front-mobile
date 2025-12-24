import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/user_provider.dart';
import '../views/auth/login_view.dart';
import '../views/layouts/app_shell.dart';
import '../views/home/dashboard_content.dart';
import '../views/users/users_content.dart';
import '../views/product/product_list_content.dart';
import '../views/product/product_detail_view.dart';
import '../views/invoices/invoices_content.dart';
import '../views/reports/reports_content.dart';
import '../views/traceability/traceability_content.dart';
import '../views/settings/settings_content.dart';
import '../views/clients/clients_content.dart';
import '../views/clients/create_client_view.dart';

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
  static const String clients = '/clients';
  static const String clientsCreate = '/clients/create';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String invoices = '/invoices';
  static const String reports = '/reports';
  static const String traceability = '/traceability';
  static const String settings = '/settings';

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
                child: DashboardContent(),
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
