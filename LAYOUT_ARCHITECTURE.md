# Architecture de Navigation et Layout

## Vue d'ensemble

Le système utilise un **MainLayout** avec sidebar et navbar fixes, où seul le contenu central change selon les routes.

## Structure

```
┌─────────────────────────────────────────────┐
│           AppNavBar (fixe)                  │
│  Info utilisateur + Déconnexion             │
├──────────┬──────────────────────────────────┤
│          │                                  │
│ Sidebar  │      Contenu dynamique          │
│ (fixe)   │      (change selon route)       │
│          │                                  │
│  Menu    │      Dashboard / Users /         │
│  selon   │      Products / etc...          │
│  rôle    │                                  │
│          │                                  │
└──────────┴──────────────────────────────────┘
```

## Composants principaux

### 1. MainLayout (`views/layouts/main_layout.dart`)
- Conteneur principal qui assemble sidebar + navbar + contenu
- Vérifie l'authentification utilisateur
- Gère la navigation entre les routes

### 2. AppSidebar (`views/widgets/app_sidebar.dart`)
- Menu de navigation avec gradient bleu marine
- Filtre les éléments selon le rôle utilisateur
- Highlight de l'élément actif
- Icône de l'application en haut

### 3. AppNavBar (`views/widgets/app_navbar.dart`)
- Badge du rôle utilisateur
- Avatar + nom d'utilisateur
- Menu déroulant : Profil / Paramètres / Déconnexion
- Indicateur d'accès distant

### 4. MenuConfig (`core/constants/menu_config.dart`)
- Configuration centralisée des menus
- Permissions par rôle
- Méthodes de filtrage

## Permissions par rôle

Les éléments de menu sont filtrés selon le rôle de l'utilisateur :

| Menu          | Rôles autorisés                                  |
|---------------|--------------------------------------------------|
| Dashboard     | Tous                                             |
| Produits      | super_admin, admin, gestionnaire                 |
| Utilisateurs  | super_admin, admin                               |
| Factures      | super_admin, admin, gestionnaire, comptable      |
| Rapports      | super_admin, admin, gestionnaire                 |
| Traçabilité   | super_admin, admin                               |
| Paramètres    | Tous                                             |

## Ajouter une nouvelle vue

1. **Créer la vue** dans `views/[category]/[name]_view.dart` :
```dart
class MyNewView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/my-route',
      child: _buildContent(context),
    );
  }
  
  Widget _buildContent(BuildContext context) {
    // Votre contenu ici
  }
}
```

2. **Ajouter la route** dans `routes/app_routes.dart` :
```dart
static const String myRoute = '/my-route';

static Map<String, WidgetBuilder> get routes => {
  myRoute: (_) => const MyNewView(),
  // ...
};
```

3. **Ajouter au menu** dans `core/constants/menu_config.dart` :
```dart
const MenuItem(
  id: 'my-item',
  title: 'Mon élément',
  icon: Icons.my_icon,
  route: '/my-route',
  allowedRoles: ['super_admin', 'admin'], // ou [] pour tous
),
```

## Styles et couleurs

Toutes les vues utilisent les mêmes styles industriels :
- **Couleurs** : `AppColors.industrialPrimary`, `AppColors.industrialBackground`
- **Textes** : `AppTheme.headingLarge`, `AppTheme.subtitleMedium`
- **Boutons** : `AppTheme.industrialPrimaryButton`
- **Cards** : Fond blanc avec `borderRadius` et `shadow`

## Navigation

La navigation se fait via :
- **Sidebar** : Clics sur les éléments de menu
- **Code** : `Navigator.pushReplacementNamed(context, route)`
- **Après login** : Redirection automatique vers `/dashboard`

## Protection des routes

Le `MainLayout` vérifie automatiquement si l'utilisateur est connecté. Si non :
- Redirection vers `/login`
- Affichage d'un loader pendant la vérification

## Notes importantes

1. **Toutes les vues principales** doivent utiliser `MainLayout`
2. **Ne pas utiliser `Scaffold`** dans les vues utilisant `MainLayout` (déjà inclus)
3. **Respecter la structure** des permissions pour la sécurité
4. **Utiliser les styles globaux** pour la cohérence visuelle
