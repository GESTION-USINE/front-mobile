# Flutter MVVM Template

Un template Flutter avec architecture MVVM, support du dark mode et internationalisation (français/anglais).

## 📁 Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── app.dart                     # Configuration MaterialApp
│
├── core/                        # Utilitaires et configuration
│   ├── constants/               # Constantes (API, app)
│   ├── network/                 # Client API (Dio)
│   ├── exceptions/              # Exceptions personnalisées
│   ├── base/                    # Classes de base (BaseViewModel)
│   ├── theme/                   # Thèmes (clair/sombre)
│   └── localization/            # Traductions (FR/EN)
│
├── models/                      # Modèles de données
│   ├── request/                 # DTOs pour les requêtes API
│   └── response/                # DTOs pour les réponses API
│
├── services/                    # Services (appels API)
│   ├── interfaces/              # Interfaces des services
│   ├── auth_service.dart
│   └── product_service.dart
│
├── providers/                   # État global partagé
│   ├── user_provider.dart       # Utilisateur connecté
│   ├── theme_provider.dart      # Gestion du thème
│   └── locale_provider.dart     # Gestion de la langue
│
├── viewmodels/                  # ViewModels (logique UI)
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   └── product_viewmodel.dart
│
├── views/                       # Interfaces utilisateur
│   ├── auth/
│   ├── home/
│   ├── product/
│   ├── profile/
│   ├── settings/
│   └── widgets/                 # Widgets réutilisables
│
├── di/                          # Injection de dépendances
│   └── injection_container.dart
│
└── routes/                      # Navigation
    └── app_routes.dart
```

## 🚀 Installation

1. Cloner le projet
2. Installer les dépendances :
```bash
flutter pub get
```

3. Lancer l'application :
```bash
flutter run
```

## ⚙️ Configuration

### API
Modifier l'URL de base dans `lib/core/constants/api_endpoints.dart` :
```dart
static const String baseUrl = 'https://votre-api.com/api';
```

### Ajouter une nouvelle langue
1. Ajouter les traductions dans `lib/core/localization/app_localizations.dart`
2. Ajouter le `Locale` dans `supportedLocales`

### Modifier le thème
Personnaliser les couleurs dans `lib/core/theme/app_theme.dart`

## 📱 Fonctionnalités

- ✅ Architecture MVVM
- ✅ Dark Mode (clair/sombre/système)
- ✅ Internationalisation (FR/EN)
- ✅ Injection de dépendances (GetIt)
- ✅ Gestion d'état (Provider)
- ✅ Client HTTP (Dio)
- ✅ Persistance locale (SharedPreferences)
- ✅ Gestion d'erreurs centralisée
- ✅ BaseViewModel avec états (loading/success/error)

## 🏗️ Architecture

```
View ──observe──► ViewModel ──appelle──► Service ──utilise──► ApiClient
         │              │
         │              └── utilise Models (Request/Response)
         │
         └── observe ──► Providers (état global)
```

### Flux de données

1. **View** : Affiche l'UI et observe le ViewModel
2. **ViewModel** : Gère la logique UI, appelle les Services
3. **Service** : Fait les appels API, utilise les Models
4. **Provider** : Gère l'état global partagé (user, theme, locale)

## 📝 Conventions

### Nommage
- Services : `auth_service.dart`, `product_service.dart`
- ViewModels : `auth_viewmodel.dart`, `product_viewmodel.dart`
- Views : `login_view.dart`, `home_view.dart`
- Models Request : `login_request.dart`
- Models Response : `user_response.dart`

### Création d'une nouvelle fonctionnalité

1. Créer les models dans `models/request/` et `models/response/`
2. Créer l'interface du service dans `services/interfaces/`
3. Implémenter le service dans `services/`
4. Créer le ViewModel dans `viewmodels/`
5. Créer la View dans `views/`
6. Enregistrer dans `di/injection_container.dart`
7. Ajouter la route dans `routes/app_routes.dart`

## 🧪 Tests

Pour tester facilement grâce aux interfaces :

```dart
class MockAuthService implements IAuthService {
  @override
  Future<LoginResponse> login(LoginRequest request) async {
    return LoginResponse(
      token: 'fake_token',
      user: UserResponse(id: '1', name: 'Test', email: 'test@test.com'),
    );
  }
  // ...
}
```

## 📄 License

MIT
