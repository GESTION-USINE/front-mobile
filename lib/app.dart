import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'routes/app_router.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  bool _routerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Créer le router avec le UserProvider pour la redirection automatique
    if (_routerInitialized) return;
    final userProvider = context.read<UserProvider>();
    _router = AppRouter.createRouter(userProvider);
    _routerInitialized = true;
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final userProvider = context.watch<UserProvider>();

    // Attendre l'initialisation
    if (!userProvider.isInitialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Flutter MVVM',
      debugShowCheckedModeBanner: false,

      // Router
      routerConfig: _router,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // Localization
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
