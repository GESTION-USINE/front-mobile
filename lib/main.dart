import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'di/injection_container.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/sidebar_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les dépendances
  await initDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getIt<UserProvider>()),
        ChangeNotifierProvider.value(value: getIt<ThemeProvider>()),
        ChangeNotifierProvider.value(value: getIt<LocaleProvider>()),
        ChangeNotifierProvider.value(value: getIt<SidebarProvider>()),
      ],
      child: const MyApp(),
    ),
  );
}
