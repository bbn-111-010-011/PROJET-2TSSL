# 01 — Structure du projet

## Vue d’ensemble

Le projet est organisé pour éviter de mélanger l’interface, les données, les appels API et la persistance.

```text
lib/
├── main.dart                         # Point d’entrée de l’application
├── core/                             # Constantes globales
├── models/                           # Objets métier
├── providers/                        # État applicatif avec ChangeNotifier
├── repositories/                     # Stockage local / persistance
├── services/                         # Appels API
├── router/                           # Navigation go_router
└── ui/                               # Interface utilisateur
```

## Rôle de chaque répertoire

| Répertoire | Rôle | Exemple |
|---|---|---|
| `core/` | Centralise les constantes. | URL API, clés SharedPreferences. |
| `models/` | Définit les objets manipulés. | `Product`, `CartItem`, `Order`, `AppUser`. |
| `services/` | Communique avec l’API. | `ProductService`, `AuthService`. |
| `repositories/` | Sauvegarde et recharge les données locales. | `LocalStorage`, `DatabaseStorage`. |
| `providers/` | Gère l’état et la logique métier. | `CartProvider`, `FavoritesProvider`. |
| `router/` | Gère les routes et redirections. | `/home`, `/cart`, `/login`. |
| `ui/screens/` | Pages complètes. | Produits, panier, profil. |
| `ui/widgets/` | Widgets réutilisables. | `ProductTile`. |

## Logique de lecture du code

Pour comprendre le projet, lire les fichiers dans cet ordre :

1. `main.dart`
2. `core/constants.dart`
3. `models/`
4. `services/`
5. `repositories/`
6. `providers/`
7. `router/app_router.dart`
8. `ui/screens/`
9. `ui/widgets/`

## Architecture en couches

```text
Écrans / Widgets
    ↓ utilisent
Providers
    ↓ appellent
Services et Repositories
    ↓ manipulent
Models
    ↓ communiquent avec
API / SharedPreferences / SQLite / Supabase
```
