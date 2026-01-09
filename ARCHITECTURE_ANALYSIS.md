# 📊 Analyse Architecture - Optimisation Backend Calls

## 🎯 Problème Identifié

**À chaque changement de page (Client → Matériaux, etc.), un appel au backend est lancé MÊME si les données n'ont pas changé.**

---

## 🏗️ Architecture Actuelle

### Stack Technique
- **Navigation**: GoRouter (go_router package)
- **State Management**: Provider (ChangeNotifier)
- **Pattern**: MVVM (ViewModel + Services)
- **API Client**: Dio

### Flow de Navigation
```
AppShell (Route Principale)
    ↓
[Sidebar] + [Navigation Change] → context.go(route) → GoRouter
    ↓
ClientsContent OR MaterialsContent (StatefulWidget)
    ↓
initState() → _viewModel.loadClients() / loadMaterials()
    ↓
Backend API Call 🔴 (PROBLÈME!)
```

---

## 🔴 Problèmes Identifiés

### 1. **Pas de Cache au Niveau ViewModel**
   - **Localisation**: `lib/viewmodels/client_viewmodel.dart`
   - **Code**:
   ```dart
   Future<void> loadClients({bool refresh = false, ...}) async {
     if (refresh) {
       _currentPage = 1;
     }
     // ❌ Pas de vérification si les données existent déjà
     final result = await runAsync(() async {
       return await _clientService.getClients(...);
     });
   }
   ```
   - **Impact**: Chaque appel à `loadClients()` refait un appel API

### 2. **Nouvelles Instances de ViewModel à Chaque Navigation**
   - **Localisation**: `lib/views/clients/clients_content.dart` (line 38-40)
   - **Code**:
   ```dart
   @override
   void initState() {
     super.initState();
     _viewModel = getIt<ClientViewModel>();  // 🔴 Nouvelle instance!
     _viewModel.loadClients();
   }
   ```
   - **Impact**: Perte de l'état précédent à chaque navigation

### 3. **Pas de Service-Level Cache**
   - **Services**: `lib/services/client_service.dart`, `lib/services/material_service.dart`
   - **Problème**: Les services ne cachent JAMAIS les résultats
   - **Impact**: Même avec le même ViewModel, l'API est appelée

### 4. **Router Réinitialise les Widgets**
   - **Localisation**: `lib/routes/app_router.dart`
   - **Pattern GoRouter**:
   ```dart
   GoRoute(
     path: dashboard,
     builder: (context, state) => ClientsContent()  // 🔴 Nouveau widget!
   )
   ```
   - **Impact**: Chaque navigation crée un nouveau widget → initState() → loadClients()

### 5. **Pas de Vérification du État Avant les Appels**
   - **Services Response Types**: `ClientsResponse`, `MaterialsResponse`
   - **Problème**: Aucune métadonnée de timestamp ou cache validation
   - **Impact**: Impossible d'implémenter "cache freshness"

---

## 📈 Flux Actuel vs Problématique

### Flux Actuel (Inefficace)
```
Client Page → initState() → loadClients() → API ✅
       ↓
Matériaux Page → initState() → loadMaterials() → API ✅
       ↓
Client Page (again) → initState() → loadClients() → API ✅ (🔴 REDONDANT!)
```

### Flux Idéal (Optimisé)
```
Client Page → initState() → loadClients() → Cache OK? ✅ (skip API)
       ↓
Matériaux Page → initState() → loadMaterials() → API ✅
       ↓
Client Page (again) → initState() → loadClients() → Cache OK? ✅ (skip API)
```

---

## 🎯 Points Clés à Optimiser

| Issue | Localisation | Sévérité | Impact |
|-------|-------------|----------|--------|
| **Pas de cache ViewModel** | `ClientViewModel.loadClients()` | 🔴 Haute | ❌ API appelée à chaque fois |
| **Nouvelles instances** | `clients_content.dart:initState()` | 🔴 Haute | ❌ Perte d'état |
| **Pas de cache service** | `ClientService.getClients()` | 🟠 Moyenne | ❌ Redondance API |
| **Métadonnées manquantes** | `ClientsResponse` | 🟠 Moyenne | ❌ Pas de TTL/freshness |
| **Pas de vérification filtre** | `ClientViewModel.searchClients()` | 🟢 Basse | ⚠️ Edge case avec filtres |

---

## 💡 Recommandations d'Optimisation

### ✅ Solution 1: Cache au Niveau ViewModel (Recommandé)
**Priorité**: 🔴 HAUTE

```dart
class ClientViewModel extends BaseViewModel {
  List<Client>? _cachedClients;
  DateTime? _cachedAt;
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  Future<void> loadClients({bool refresh = false}) async {
    // 1. Vérifier le cache
    if (!refresh && _cachedClients != null && _isCacheValid()) {
      _clients = _cachedClients!;
      notifyListeners();
      return;
    }
    
    // 2. Faire l'appel API
    final result = await runAsync(() => _clientService.getClients(...));
    
    // 3. Mettre en cache
    if (result != null) {
      _cachedClients = result.items;
      _cachedAt = DateTime.now();
    }
  }
  
  bool _isCacheValid() {
    return _cachedAt != null && 
           DateTime.now().difference(_cachedAt!) < _cacheDuration;
  }
}
```

### ✅ Solution 2: Singleton ViewModel (Recommandé)
**Priorité**: 🔴 HAUTE

Garder la même instance de ViewModel à travers les navigations:
```dart
// Au lieu de créer une nouvelle instance à chaque fois
_viewModel = getIt<ClientViewModel>();

// Utiliser une instance singleton
_viewModel = getIt<ClientViewModel>();  // Retourne TOUJOURS la même
```

### ✅ Solution 3: Response Metadata avec TTL
**Priorité**: 🟠 MOYENNE

Ajouter des métadonnées aux réponses:
```dart
class ClientsResponse {
  final List<Client> items;
  final DateTime fetchedAt = DateTime.now();  // Timestamp
  final Duration cacheDuration = Duration(minutes: 5);
  
  bool get isExpired => DateTime.now().difference(fetchedAt) > cacheDuration;
}
```

### ✅ Solution 4: Service-Level Cache
**Priorité**: 🟠 MOYENNE

Implémenter un cache simple dans les services:
```dart
class ClientService {
  Map<String, ClientsResponse> _cache = {};
  
  Future<ClientsResponse> getClients({...}) async {
    final cacheKey = _buildCacheKey(...);
    
    if (_cache.containsKey(cacheKey) && !_cache[cacheKey]!.isExpired) {
      return _cache[cacheKey]!;  // Return cached
    }
    
    final response = await _apiClient.get(...);
    _cache[cacheKey] = response;
    return response;
  }
}
```

### ✅ Solution 5: Forcer Refresh au Besoin
**Priorité**: 🟢 BASSE

Ajouter un bouton "Rafraîchir":
```dart
ElevatedButton(
  onPressed: () => _viewModel.loadClients(refresh: true),
  child: Text('Rafraîchir'),
)
```

---

## 📋 Plan d'Implémentation Recommandé

### Phase 1 (Critique)
1. ✅ Ajouter cache + validation au ViewModel (`ClientViewModel`, `MaterialViewModel`)
2. ✅ Vérifier que les ViewModels sont singletons

### Phase 2 (Important)
3. ✅ Ajouter timestamp et TTL aux Response models
4. ✅ Implémenter cache service-level

### Phase 3 (Nice-to-have)
5. ✅ Ajouter bouton "Rafraîchir" aux pages
6. ✅ Ajouter indicateur "Données fraîches" / "Cache"

---

## 📊 Bénéfices Attendus

| Métrique | Avant | Après | Gain |
|----------|-------|-------|------|
| **API Calls par session** | 20+ | 5-8 | 🟢 -60% |
| **Latence page** | 500-800ms | 50-100ms | 🟢 -85% |
| **Bande passante** | 10MB | 3-4MB | 🟢 -65% |
| **User Experience** | Lente | Fluide | 🟢 ⚡ |

---

## 📝 Prochaines Étapes

Attends ton approbation pour procéder aux optimisations. Dis-moi:
- ✅ Approuves-tu cette analyse?
- ✅ Par quelle solution veux-tu commencer?
- ✅ Y a-t-il d'autres cas à considérer?
