# 📚 Documentation - Flutter MVVM Template

## Table des matières

1. [Introduction](#1-introduction)
2. [Architecture du projet](#2-architecture-du-projet)
3. [Structure des dossiers](#3-structure-des-dossiers)
4. [Guide détaillé de chaque couche](#4-guide-détaillé-de-chaque-couche)
5. [Flux de données](#5-flux-de-données)
6. [Scénarios pratiques](#6-scénarios-pratiques)
7. [Bonnes pratiques](#7-bonnes-pratiques)
8. [FAQ](#8-faq)

---

## 1. Introduction

### 1.1 Qu'est-ce que ce projet ?

Ce projet est un template Flutter utilisant l'architecture **MVVM** (Model-View-ViewModel) avec :
- **Provider** pour la gestion d'état
- **GetIt** pour l'injection de dépendances
- **Dio** pour les appels HTTP
- Support du **Dark Mode**
- Support de l'**internationalisation** (Français/Anglais)

### 1.2 Pourquoi MVVM ?

| Avantage | Description |
|----------|-------------|
| **Séparation des responsabilités** | Chaque couche a un rôle précis |
| **Testabilité** | Les ViewModels peuvent être testés sans UI |
| **Maintenabilité** | Code organisé et facile à modifier |
| **Réutilisabilité** | Les services et ViewModels sont indépendants |
| **Travail en équipe** | Chacun peut travailler sur une couche différente |

### 1.3 Prérequis

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Un éditeur (VS Code, Android Studio)

### 1.4 Installation

```bash
# Cloner le projet
git clone <url-du-repo>

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

---

## 2. Architecture du projet

### 2.1 Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────┐
│                            VIEW                                  │
│         (Widgets Flutter - Ce que l'utilisateur voit)           │
└─────────────────────────┬───────────────────────────────────────┘
                          │ observe
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        VIEWMODEL                                 │
│         (Logique UI - Gère l'état de l'écran)                   │
└─────────────────────────┬───────────────────────────────────────┘
                          │ appelle
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                         SERVICE                                  │
│         (Appels API - Communique avec le serveur)               │
└─────────────────────────┬───────────────────────────────────────┘
                          │ utilise
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                          MODEL                                   │
│         (Request/Response - Structure des données)              │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Rôle de chaque couche

| Couche | Responsabilité | Exemple |
|--------|----------------|---------|
| **View** | Afficher l'interface utilisateur | `LoginView`, `HomeView` |
| **ViewModel** | Gérer la logique et l'état de l'écran | `AuthViewModel`, `ProductViewModel` |
| **Service** | Faire les appels API | `AuthService`, `ProductService` |
| **Model** | Définir la structure des données | `LoginRequest`, `UserResponse` |
| **Provider** | Gérer l'état global partagé | `UserProvider`, `ThemeProvider` |

### 2.3 Différence entre ViewModel et Provider

```
┌─────────────────────────────────────────────────────────────────┐
│                        PROVIDER                                  │
│  • État GLOBAL partagé entre plusieurs écrans                   │
│  • Exemple: utilisateur connecté, thème, langue                 │
│  • Une seule instance pour toute l'app                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       VIEWMODEL                                  │
│  • État LOCAL d'un écran spécifique                             │
│  • Exemple: liste de produits, formulaire de login              │
│  • Nouvelle instance pour chaque écran                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Structure des dossiers

```
lib/
│
├── main.dart                      # Point d'entrée de l'application
├── app.dart                       # Configuration de MaterialApp
│
├── core/                          # 🔧 Utilitaires et configuration
│   ├── constants/
│   │   ├── api_endpoints.dart     # URLs de l'API
│   │   └── app_constants.dart     # Constantes de l'app
│   │
│   ├── network/
│   │   └── api_client.dart        # Client HTTP (Dio)
│   │
│   ├── exceptions/
│   │   └── app_exceptions.dart    # Exceptions personnalisées
│   │
│   ├── base/
│   │   └── base_viewmodel.dart    # ViewModel de base
│   │
│   ├── theme/
│   │   └── app_theme.dart         # Thèmes clair/sombre
│   │
│   └── localization/
│       └── app_localizations.dart # Traductions FR/EN
│
├── models/                        # 📦 Modèles de données
│   ├── request/                   # Ce qu'on ENVOIE à l'API
│   │   ├── login_request.dart
│   │   ├── signup_request.dart
│   │   └── create_product_request.dart
│   │
│   └── response/                  # Ce qu'on REÇOIT de l'API
│       ├── user_response.dart
│       ├── login_response.dart
│       └── product_response.dart
│
├── services/                      # 🌐 Appels API
│   ├── interfaces/                # Contrats (pour les tests)
│   │   ├── i_auth_service.dart
│   │   └── i_product_service.dart
│   │
│   ├── auth_service.dart          # Implémentation Auth
│   └── product_service.dart       # Implémentation Product
│
├── providers/                     # 🌍 État global
│   ├── user_provider.dart         # Utilisateur connecté
│   ├── theme_provider.dart        # Mode clair/sombre
│   └── locale_provider.dart       # Langue FR/EN
│
├── viewmodels/                    # 🧠 Logique des écrans
│   ├── auth_viewmodel.dart
│   ├── home_viewmodel.dart
│   └── product_viewmodel.dart
│
├── views/                         # 📱 Interfaces utilisateur
│   ├── auth/
│   │   ├── login_view.dart
│   │   └── signup_view.dart
│   │
│   ├── home/
│   │   └── home_view.dart
│   │
│   ├── product/
│   │   ├── product_list_view.dart
│   │   └── product_detail_view.dart
│   │
│   ├── profile/
│   │   └── profile_view.dart
│   │
│   ├── settings/
│   │   └── settings_view.dart
│   │
│   └── widgets/                   # Widgets réutilisables
│       ├── custom_button.dart
│       └── custom_text_field.dart
│
├── di/                            # 💉 Injection de dépendances
│   └── injection_container.dart
│
└── routes/                        # 🧭 Navigation
    └── app_routes.dart
```

---

## 4. Guide détaillé de chaque couche

### 4.1 Models (Modèles de données)

Les models définissent la structure des données. On distingue deux types :

#### Request (ce qu'on envoie)

```dart
// models/request/login_request.dart

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  // Convertir en JSON pour l'API
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```

#### Response (ce qu'on reçoit)

```dart
// models/response/user_response.dart

class UserResponse {
  final String id;
  final String name;
  final String email;

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
  });

  // Créer depuis le JSON de l'API
  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  // Convertir en JSON (pour sauvegarder localement)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}
```

### 4.2 Services (Appels API)

Les services font les appels HTTP et convertissent les réponses en models.

#### Interface (contrat)

```dart
// services/interfaces/i_auth_service.dart

abstract class IAuthService {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> signup(SignupRequest request);
  Future<void> logout();
}
```

#### Implémentation

```dart
// services/auth_service.dart

class AuthService implements IAuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      // 1. Faire l'appel API
      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );
      
      // 2. Convertir la réponse en model
      return LoginResponse.fromJson(response.data);
      
    } on DioException catch (e) {
      // 3. Gérer les erreurs
      throw _handleError(e);
    }
  }

  // Transformer les erreurs Dio en nos exceptions
  AppException _handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return UnauthorizedException('Email ou mot de passe incorrect');
      case 404:
        return NotFoundException();
      default:
        return ServerException('Erreur serveur');
    }
  }
}
```

### 4.3 ViewModels (Logique des écrans)

Les ViewModels gèrent l'état et la logique d'un écran.

#### BaseViewModel

Tous les ViewModels héritent de `BaseViewModel` qui fournit :

```dart
// core/base/base_viewmodel.dart

enum ViewState { idle, loading, success, error }

abstract class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Getters
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  // Méthode helper pour les actions async
  Future<T?> runAsync<T>(Future<T> Function() action) async {
    setLoading();
    try {
      final result = await action();
      setSuccess();
      return result;
    } on AppException catch (e) {
      setError(e.message);
      return null;
    }
  }
}
```

#### Exemple de ViewModel

```dart
// viewmodels/auth_viewmodel.dart

class AuthViewModel extends BaseViewModel {
  final IAuthService _authService;
  final UserProvider _userProvider;

  AuthViewModel(this._authService, this._userProvider);

  Future<bool> login(String email, String password) async {
    // 1. Validation locale
    if (email.isEmpty) {
      setError('L\'email est requis');
      return false;
    }

    // 2. Créer la requête
    final request = LoginRequest(email: email, password: password);

    // 3. Appeler le service (runAsync gère loading/error)
    final response = await runAsync(() => _authService.login(request));

    // 4. Traiter le résultat
    if (response != null) {
      await _userProvider.setUser(response.user, response.token);
      return true;
    }

    return false;
  }
}
```

### 4.4 Views (Interfaces utilisateur)

Les Views affichent l'UI et observent les ViewModels.

```dart
// views/auth/login_view.dart

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // 1. Contrôleurs pour les champs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 2. ViewModel
  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    // 3. Récupérer le ViewModel via GetIt
    _viewModel = getIt<AuthViewModel>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Fournir le ViewModel aux widgets enfants
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Consumer<AuthViewModel>(
          // 5. Reconstruire quand le ViewModel change
          builder: (context, viewModel, child) {
            return Column(
              children: [
                // Champ email
                TextField(controller: _emailController),
                
                // Champ mot de passe
                TextField(controller: _passwordController),
                
                // Afficher l'erreur si présente
                if (viewModel.hasError)
                  Text(viewModel.errorMessage!),
                
                // Bouton avec état loading
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _login,
                  child: viewModel.isLoading
                      ? CircularProgressIndicator()
                      : Text('Connexion'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _login() async {
    final success = await _viewModel.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }
}
```

### 4.5 Providers (État global)

Les Providers gèrent l'état partagé entre plusieurs écrans.

```dart
// providers/user_provider.dart

class UserProvider extends ChangeNotifier {
  UserResponse? _currentUser;
  String? _token;

  // Getters
  UserResponse? get currentUser => _currentUser;
  bool get isLoggedIn => _token != null;

  // Définir l'utilisateur après login
  Future<void> setUser(UserResponse user, String token) async {
    _currentUser = user;
    _token = token;

    // Sauvegarder en local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', user.toJsonString());

    notifyListeners(); // Notifier les écrans
  }

  // Déconnexion
  Future<void> clear() async {
    _currentUser = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    notifyListeners();
  }
}
```

### 4.6 Injection de dépendances

Le fichier `injection_container.dart` configure toutes les dépendances.

```dart
// di/injection_container.dart

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  
  // === CORE ===
  // Une seule instance de ApiClient pour toute l'app
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // === PROVIDERS ===
  // Singletons car état global
  getIt.registerLazySingleton<UserProvider>(() => UserProvider());
  getIt.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  getIt.registerLazySingleton<LocaleProvider>(() => LocaleProvider());

  // === SERVICES ===
  // Singletons car pas d'état interne
  getIt.registerLazySingleton<IAuthService>(
    () => AuthService(getIt<ApiClient>()),
  );

  // === VIEWMODELS ===
  // Factory = nouvelle instance à chaque appel
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      getIt<IAuthService>(),
      getIt<UserProvider>(),
      getIt<ApiClient>(),
    ),
  );

  // === INITIALISATION ===
  await getIt<UserProvider>().init();
  await getIt<ThemeProvider>().init();
}
```

#### Différence Singleton vs Factory

```
┌─────────────────────────────────────────────────────────────────┐
│ registerLazySingleton                                           │
│ • UNE seule instance pour toute l'app                          │
│ • Utilisé pour: ApiClient, Providers, Services                 │
│ • Exemple: getIt<UserProvider>() retourne toujours la même     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ registerFactory                                                 │
│ • NOUVELLE instance à chaque appel                             │
│ • Utilisé pour: ViewModels                                     │
│ • Exemple: chaque écran a son propre ViewModel                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.7 Routes (Navigation)

```dart
// routes/app_routes.dart

class AppRoutes {
  // Noms des routes (constantes pour éviter les fautes)
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String productDetail = '/products/detail';

  // Routes simples
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginView(),
    signup: (_) => const SignupView(),
    home: (_) => const HomeView(),
  };

  // Routes avec arguments
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case productDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailView(productId: productId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundView(),
        );
    }
  }
}
```

---

## 5. Flux de données

### 5.1 Exemple complet : Login

```
┌──────────────────────────────────────────────────────────────────┐
│ 1. L'utilisateur tape son email/password et clique "Connexion"   │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│ 2. LoginView appelle _viewModel.login(email, password)           │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│ 3. AuthViewModel:                                                │
│    - Valide les données                                          │
│    - Crée LoginRequest                                           │
│    - Appelle authService.login(request)                          │
│    - État passe à "loading"                                      │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│ 4. AuthService:                                                  │
│    - Envoie POST /auth/login avec les données                    │
│    - Reçoit la réponse JSON                                      │
│    - Convertit en LoginResponse                                  │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│ 5. AuthViewModel:                                                │
│    - Reçoit LoginResponse                                        │
│    - Appelle userProvider.setUser(user, token)                   │
│    - État passe à "success"                                      │
│    - Retourne true                                               │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│ 6. UserProvider:                                                 │
│    - Stocke l'utilisateur et le token                            │
│    - Sauvegarde en local (SharedPreferences)                     │
│    - Notifie les listeners                                       │
└──────────────────────────────────┬───────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│ 7. LoginView:                                                    │
│    - Reçoit true                                                 │
│    - Navigue vers HomeView                                       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 6. Scénarios pratiques

### 6.1 📝 Scénario : Ajouter une nouvelle page "Catégories"

#### Étape 1 : Créer les Models

```dart
// models/response/category_response.dart

class CategoryResponse {
  final String id;
  final String name;
  final String? iconUrl;

  CategoryResponse({
    required this.id,
    required this.name,
    this.iconUrl,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
    );
  }
}
```

```dart
// models/request/create_category_request.dart

class CreateCategoryRequest {
  final String name;

  CreateCategoryRequest({required this.name});

  Map<String, dynamic> toJson() => {'name': name};
}
```

#### Étape 2 : Créer l'interface du Service

```dart
// services/interfaces/i_category_service.dart

abstract class ICategoryService {
  Future<List<CategoryResponse>> getCategories();
  Future<CategoryResponse> getCategoryById(String id);
  Future<CategoryResponse> createCategory(CreateCategoryRequest request);
  Future<void> deleteCategory(String id);
}
```

#### Étape 3 : Implémenter le Service

```dart
// services/category_service.dart

class CategoryService implements ICategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  @override
  Future<List<CategoryResponse>> getCategories() async {
    try {
      final response = await _apiClient.get('/categories');
      final List data = response.data;
      return data.map((json) => CategoryResponse.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CategoryResponse> getCategoryById(String id) async {
    try {
      final response = await _apiClient.get('/categories/$id');
      return CategoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<CategoryResponse> createCategory(CreateCategoryRequest request) async {
    try {
      final response = await _apiClient.post('/categories', data: request.toJson());
      return CategoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _apiClient.delete('/categories/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppException _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException();
    }
    return ServerException('Erreur serveur', e.response?.statusCode);
  }
}
```

#### Étape 4 : Créer le ViewModel

```dart
// viewmodels/category_viewmodel.dart

class CategoryViewModel extends BaseViewModel {
  final ICategoryService _categoryService;

  CategoryViewModel(this._categoryService);

  List<CategoryResponse> _categories = [];
  List<CategoryResponse> get categories => _categories;
  bool get hasCategories => _categories.isNotEmpty;

  Future<void> loadCategories() async {
    final result = await runAsync(() => _categoryService.getCategories());
    if (result != null) {
      _categories = result;
      notifyListeners();
    }
  }

  Future<bool> createCategory(String name) async {
    final request = CreateCategoryRequest(name: name);
    final result = await runAsync(() => _categoryService.createCategory(request));
    if (result != null) {
      _categories.add(result);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(String id) async {
    final success = await runAsync(() async {
      await _categoryService.deleteCategory(id);
      return true;
    });
    if (success == true) {
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    }
    return false;
  }
}
```

#### Étape 5 : Créer la View

```dart
// views/category/category_list_view.dart

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key});

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  late final CategoryViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<CategoryViewModel>();
    _viewModel.loadCategories();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(title: const Text('Catégories')),
        body: Consumer<CategoryViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(viewModel.errorMessage!),
                    ElevatedButton(
                      onPressed: viewModel.loadCategories,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (!viewModel.hasCategories) {
              return const Center(child: Text('Aucune catégorie'));
            }

            return ListView.builder(
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final category = viewModel.categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _viewModel.deleteCategory(category.id),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nom'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _viewModel.createCategory(controller.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }
}
```

#### Étape 6 : Enregistrer dans l'injection de dépendances

```dart
// di/injection_container.dart

Future<void> initDependencies() async {
  // ... autres enregistrements ...

  // Service
  getIt.registerLazySingleton<ICategoryService>(
    () => CategoryService(getIt<ApiClient>()),
  );

  // ViewModel
  getIt.registerFactory<CategoryViewModel>(
    () => CategoryViewModel(getIt<ICategoryService>()),
  );
}
```

#### Étape 7 : Ajouter la route

```dart
// routes/app_routes.dart

class AppRoutes {
  static const String categories = '/categories';

  static Map<String, WidgetBuilder> get routes => {
    // ... autres routes ...
    categories: (_) => const CategoryListView(),
  };
}
```

#### Étape 8 : Ajouter les traductions (optionnel)

```dart
// core/localization/app_localizations.dart

static final Map<String, Map<String, String>> _localizedValues = {
  'en': {
    // ... autres traductions ...
    'categories': 'Categories',
    'add_category': 'Add Category',
    'no_categories': 'No categories',
  },
  'fr': {
    // ... autres traductions ...
    'categories': 'Catégories',
    'add_category': 'Ajouter une catégorie',
    'no_categories': 'Aucune catégorie',
  },
};
```

#### Récapitulatif des fichiers créés

```
✅ models/response/category_response.dart
✅ models/request/create_category_request.dart
✅ services/interfaces/i_category_service.dart
✅ services/category_service.dart
✅ viewmodels/category_viewmodel.dart
✅ views/category/category_list_view.dart
✅ Modification de di/injection_container.dart
✅ Modification de routes/app_routes.dart
✅ Modification de core/localization/app_localizations.dart (optionnel)
```

---

### 6.2 📝 Scénario : Ajouter un nouveau champ au modèle User

Si l'API ajoute un champ `phone` à l'utilisateur :

#### Étape 1 : Modifier le model

```dart
// models/response/user_response.dart

class UserResponse {
  final String id;
  final String name;
  final String email;
  final String? phone;  // ← Nouveau champ

  UserResponse({
    required this.id,
    required this.name,
    required this.email,
    this.phone,  // ← Ajouter ici
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,  // ← Ajouter ici
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,  // ← Ajouter ici
  };
}
```

#### Étape 2 : Utiliser dans les Views

```dart
// views/profile/profile_view.dart

ListTile(
  leading: const Icon(Icons.phone_outlined),
  title: const Text('Téléphone'),
  subtitle: Text(user?.phone ?? 'Non renseigné'),
),
```

C'est tout ! Grâce à la structure, les modifications sont minimales.

---

### 6.3 📝 Scénario : Ajouter une nouvelle langue (Arabe)

#### Étape 1 : Ajouter les traductions

```dart
// core/localization/app_localizations.dart

static const List<Locale> supportedLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('ar'),  // ← Ajouter
];

static final Map<String, Map<String, String>> _localizedValues = {
  'en': { /* ... */ },
  'fr': { /* ... */ },
  'ar': {  // ← Ajouter
    'app_name': 'تطبيق فلاتر',
    'login': 'تسجيل الدخول',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    // ... toutes les traductions
  },
};
```

#### Étape 2 : Mettre à jour le LocaleProvider

```dart
// providers/locale_provider.dart

bool get isArabic => _locale.languageCode == 'ar';

Future<void> setArabic() async {
  await setLocale(const Locale('ar'));
}
```

#### Étape 3 : Ajouter dans les paramètres

```dart
// views/settings/settings_view.dart

RadioListTile<String>(
  title: Row(
    children: [
      const Text('🇸🇦', style: TextStyle(fontSize: 24)),
      const SizedBox(width: 12),
      const Text('العربية'),
    ],
  ),
  value: 'ar',
  groupValue: localeProvider.locale.languageCode,
  onChanged: (value) {
    localeProvider.setArabic();
    Navigator.pop(ctx);
  },
),
```

---

## 7. Bonnes pratiques

### 7.1 Nommage

| Type | Convention | Exemple |
|------|------------|---------|
| Fichiers | snake_case | `user_response.dart` |
| Classes | PascalCase | `UserResponse` |
| Variables | camelCase | `currentUser` |
| Constantes | camelCase ou SCREAMING_SNAKE | `apiKey` ou `API_KEY` |
| Privé | préfixe `_` | `_isLoading` |

### 7.2 Organisation du code

```dart
class MyViewModel extends BaseViewModel {
  // 1. Dépendances injectées
  final IMyService _service;
  final MyProvider _provider;

  // 2. État privé
  List<Item> _items = [];
  Item? _selectedItem;

  // 3. Getters publics
  List<Item> get items => _items;
  Item? get selectedItem => _selectedItem;
  bool get hasItems => _items.isNotEmpty;

  // 4. Constructeur
  MyViewModel(this._service, this._provider);

  // 5. Méthodes publiques
  Future<void> loadItems() async { /* ... */ }
  Future<bool> createItem(Item item) async { /* ... */ }

  // 6. Méthodes privées
  void _sortItems() { /* ... */ }
}
```

### 7.3 Gestion des erreurs

```dart
// ✅ Bon : Utiliser runAsync qui gère les erreurs
Future<void> loadData() async {
  final result = await runAsync(() => _service.getData());
  if (result != null) {
    _data = result;
    notifyListeners();
  }
}

// ❌ Mauvais : Gérer manuellement sans structure
Future<void> loadData() async {
  try {
    setLoading();
    _data = await _service.getData();
    setSuccess();
  } catch (e) {
    setError(e.toString());
  }
}
```

### 7.4 Éviter les erreurs courantes

```dart
// ❌ Mauvais : Créer le service directement
class MyViewModel {
  final service = MyService(ApiClient()); // Non testable !
}

// ✅ Bon : Injecter le service
class MyViewModel {
  final IMyService _service;
  MyViewModel(this._service);
}
```

```dart
// ❌ Mauvais : Oublier de notifier
void addItem(Item item) {
  _items.add(item);
  // Oubli de notifyListeners() !
}

// ✅ Bon : Toujours notifier après modification
void addItem(Item item) {
  _items.add(item);
  notifyListeners();
}
```

```dart
// ❌ Mauvais : Logique métier dans la View
onPressed: () async {
  if (email.isEmpty) { /* ... */ }
  if (!email.contains('@')) { /* ... */ }
  final response = await service.login(email, password);
  // ...
}

// ✅ Bon : Logique métier dans le ViewModel
onPressed: () async {
  final success = await viewModel.login(email, password);
  if (success) Navigator.push(...);
}
```

---

## 8. FAQ

### Q: Quand créer un Provider vs un ViewModel ?

**Provider** : Pour l'état partagé entre plusieurs écrans
- Utilisateur connecté
- Thème
- Langue
- Panier d'achat

**ViewModel** : Pour l'état d'un écran spécifique
- Liste de produits
- Formulaire
- Détail d'un élément

### Q: Pourquoi utiliser des interfaces pour les Services ?

1. **Tests** : Permet de créer facilement des mocks
2. **Flexibilité** : Changer d'implémentation sans modifier les ViewModels
3. **Documentation** : L'interface documente ce que fait le service

### Q: Comment ajouter un nouveau endpoint API ?

1. Ajouter l'URL dans `api_endpoints.dart`
2. Créer les models Request/Response
3. Ajouter la méthode dans l'interface du Service
4. Implémenter dans le Service

### Q: Comment tester un ViewModel ?

```dart
// test/viewmodels/auth_viewmodel_test.dart

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

void main() {
  test('login success', () async {
    final mockService = MockAuthService();
    final mockUserProvider = MockUserProvider();
    final viewModel = AuthViewModel(mockService, mockUserProvider);

    final result = await viewModel.login('test@test.com', 'password');

    expect(result, true);
    expect(viewModel.hasError, false);
  });
}
```

### Q: Comment débugger un problème ?

1. Vérifier la console pour les erreurs
2. Ajouter des `print()` dans le ViewModel
3. Utiliser le DevTools Flutter
4. Vérifier l'état avec `viewModel.state`

---

## 📞 Support

Pour toute question, contacter l'équipe de développement.

---

*Documentation mise à jour le : [DATE]*
*Version : 1.0.0*
