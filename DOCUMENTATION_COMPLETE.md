# Documentation complète — PROJET 2TSSL

## 1. Objectif du projet

Le projet **PROJET 2TSSL** est une application Flutter de type marketplace / vente d’articles entre particuliers. Elle reprend la logique du **TD6** : séparation claire des responsabilités, utilisation de `Provider / ChangeNotifier`, services dédiés, modèles Dart, persistance locale et navigation structurée.

L’application permet principalement de :

- consulter une liste de produits ;
- consulter le détail d’un produit ;
- ajouter / retirer des produits favoris ;
- ajouter / retirer des produits du panier ;
- modifier les quantités du panier ;
- valider un panier ;
- consulter un historique d’achats ;
- créer un compte et se connecter ;
- proposer un nouvel article ;
- rechercher et filtrer les produits ;
- naviguer entre les pages avec une navigation fluide.

---

## 2. Logique générale de l’architecture

Le projet suit une architecture en couches proche du TD6 :

```text
UI / Screens / Widgets
        ↓
Providers / ChangeNotifier
        ↓
Repositories / Services
        ↓
Models
        ↓
API externe / SharedPreferences / SQLite / Supabase
```

Chaque couche a un rôle précis :

| Couche | Rôle |
|---|---|
| `ui/screens` | Affiche les pages de l’application. |
| `ui/widgets` | Contient les composants réutilisables. |
| `providers` | Stocke l’état de l’application et déclenche les mises à jour UI. |
| `services` | Communique avec l’API Platzi. |
| `repositories` | Gère la persistance locale et sert d’intermédiaire entre providers et stockage. |
| `models` | Définit les objets utilisés dans l’application : produit, panier, commande, utilisateur. |
| `router` | Gère la navigation avec `go_router`. |
| `core` | Contient les constantes globales. |

---

## 3. Arborescence du projet

```text
lib/
├── main.dart
├── core/
│   └── constants.dart
├── models/
│   ├── product.dart
│   ├── category.dart
│   ├── cart_item.dart
│   ├── order.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── favorites_provider.dart
│   ├── cart_provider.dart
│   ├── orders_provider.dart
│   └── onboarding_provider.dart
├── repositories/
│   ├── local_storage.dart
│   ├── database_storage.dart
│   └── auth_repository.dart
├── services/
│   ├── api_client.dart
│   ├── auth_service.dart
│   └── product_service.dart
├── router/
│   └── app_router.dart
└── ui/
    ├── screens/
    │   ├── onboarding_screen.dart
    │   ├── auth/
    │   │   ├── login_screen.dart
    │   │   └── register_screen.dart
    │   ├── products/
    │   │   ├── products_screen.dart
    │   │   └── product_detail_screen.dart
    │   ├── favorites/
    │   │   └── favorites_screen.dart
    │   ├── cart/
    │   │   └── cart_screen.dart
    │   ├── orders/
    │   │   └── orders_screen.dart
    │   ├── product_form/
    │   │   └── new_product_screen.dart
    │   └── profile/
    │       └── profile_screen.dart
    └── widgets/
        └── product_tile.dart
```

---

## 4. Choix de persistance

Le projet utilise deux types de persistance locale :

1. **SharedPreferences** pour les données simples.
2. **SQLite / sqflite** pour les données structurées.

| Fonctionnalité | Technologie utilisée | Justification |
|---|---|---|
| Écran d’accueil déjà vu | `SharedPreferences` | C’est un simple booléen `true / false`. |
| Token de connexion | `SharedPreferences` | C’est une simple chaîne de caractères. |
| Profil utilisateur connecté | `SharedPreferences` | Petit objet JSON simple à sauvegarder. |
| Favoris | `SharedPreferences` | Liste simple de produits, sauvegardée en JSON. |
| Panier | `sqflite` | Données structurées : utilisateur, produit, quantité, prix. |
| Historique achats | `Supabase` | Commandes envoyées dans la table distante `orders`. |
| Produits | API Platzi + catalogue local de secours | Les produits ne sont pas sauvegardés en local. |
| Recherche / filtres | Mémoire uniquement | Données temporaires pendant l’utilisation. |
| Navigation | Mémoire uniquement | La page courante n’est pas persistée. |

---

## 5. Fonctionnement global au démarrage

Le fichier `main.dart` initialise l’application dans cet ordre :

1. Initialisation Flutter avec `WidgetsFlutterBinding.ensureInitialized()`.
2. Initialisation SQLite desktop avec `sqflite_common_ffi` si l’application tourne sur Windows, macOS ou Linux.
3. Initialisation de `LocalStorage` pour `SharedPreferences`.
4. Initialisation de `CartStorage` pour le panier SQLite et de `SupabaseOrderService` pour l’historique distant.
5. Création du client API `ApiClient`.
6. Création des services : `AuthService`, `ProductService`.
7. Création du repository `AuthRepository`.
8. Création et hydratation des providers.
9. Création du router `GoRouter`.
10. Lancement de `MyApp`.

Le terme **hydratation** signifie : recharger l’état sauvegardé localement au démarrage de l’application.

Exemple :

```dart
final favoritesProvider = FavoritesProvider(storage);
await favoritesProvider.hydrate();
```

Cela permet de récupérer les favoris sauvegardés précédemment.

---

## 6. Documentation par dossier

### 6.1 `lib/core`

Ce dossier contient les constantes utilisées dans plusieurs fichiers.

#### `constants.dart`

Rôle : centraliser les clés de stockage et l’URL de base de l’API.

Principaux éléments :

```dart
static const String apiBaseUrl = 'https://api.escuelajs.co/api/v1';
```

Cette constante définit l’API utilisée pour récupérer les produits, catégories, utilisateurs et authentification.

```dart
static const String spToken = 'auth_token';
static const String spUser = 'auth_user';
static const String spFavorites = 'favorites';
```

Ces constantes évitent d’écrire les clés `SharedPreferences` en dur dans tout le projet.

---

### 6.2 `lib/models`

Ce dossier contient les classes qui représentent les données manipulées dans l’application.

Un modèle sert à :

- structurer les données ;
- convertir du JSON API vers un objet Dart ;
- convertir un objet Dart vers du JSON pour le sauvegarder.

#### `product.dart`

Modèle principal de l’application.

Il représente un article affiché dans le marketplace.

Champs principaux :

| Champ | Type | Rôle |
|---|---|---|
| `id` | `int` | Identifiant unique du produit. |
| `title` | `String` | Nom du produit. |
| `price` | `double` | Prix du produit. |
| `description` | `String` | Description du produit. |
| `images` | `List<String>` | Liste des URLs d’images. |
| `category` | `Category?` | Catégorie du produit. |
| `creationAt` | `DateTime?` | Date de création API. |
| `updatedAt` | `DateTime?` | Date de modification API. |

Méthodes importantes :

- `Product.fromJson()` : transforme une réponse API en objet `Product`.
- `toJson()` : transforme un produit en JSON pour le stockage local.
- `copyWith()` : crée une copie modifiée d’un produit.
- `operator ==` : deux produits sont égaux s’ils ont le même `id`.

Point important :

```dart
static String _cleanImageUrl(String value)
```

Cette méthode nettoie les URLs d’images car l’API Platzi peut renvoyer certaines images dans un format incorrect comme :

```text
["https://image...jpg"]
```

Le nettoyage évite des images cassées dans l’interface.

#### `category.dart`

Représente une catégorie de produit.

Champs :

| Champ | Type | Rôle |
|---|---|---|
| `id` | `int` | Identifiant de la catégorie. |
| `name` | `String` | Nom de la catégorie. |
| `image` | `String` | Image de catégorie. |

Utilisation :

- affichage de la catégorie sur une carte produit ;
- filtrage par catégorie ;
- création d’un nouveau produit.

#### `cart_item.dart`

Représente une ligne du panier.

Un `CartItem` n’est pas exactement un `Product`. Il contient seulement les informations nécessaires au panier.

Champs :

| Champ | Type | Rôle |
|---|---|---|
| `productId` | `int` | Identifiant du produit. |
| `title` | `String` | Nom du produit au moment de l’ajout. |
| `price` | `double` | Prix au moment de l’ajout. |
| `image` | `String` | Image principale. |
| `quantity` | `int` | Quantité dans le panier. |

Méthodes importantes :

- `CartItem.fromProduct()` : transforme un produit en ligne de panier.
- `copyWith()` : permet de changer la quantité sans modifier directement l’objet.
- `fromJson()` et `toJson()` : conversion pour la persistance.
- `lineTotal` : calcule `prix × quantité`.

#### `order.dart`

Contient deux classes :

1. `OrderItem`
2. `Order`

`OrderItem` représente un produit acheté dans une commande.

`Order` représente une commande complète.

Champs de `Order` :

| Champ | Type | Rôle |
|---|---|---|
| `id` | `String` | Identifiant local de la commande. |
| `date` | `DateTime` | Date de validation. |
| `items` | `List<OrderItem>` | Produits achetés. |

Méthodes importantes :

- `total` : calcule le total de la commande.
- `Order.fromJson()` : reconstruit une commande depuis JSON. `Order.fromSupabase()` reconstruit une commande depuis Supabase.
- `toJson()` : prépare la commande pour stockage.

#### `user.dart`

Représente l’utilisateur connecté.

Champs :

| Champ | Type | Rôle |
|---|---|---|
| `id` | `int` | Identifiant utilisateur API. |
| `name` | `String` | Nom de l’utilisateur. |
| `email` | `String` | Email de connexion. |
| `avatar` | `String` | URL d’avatar. |
| `role` | `String` | Rôle utilisateur. |
| `creationAt` | `DateTime?` | Date de création du compte. |
| `updatedAt` | `DateTime?` | Date de mise à jour. |

Utilisation :

- affichage du profil ;
- association du panier à un utilisateur ;
- association de l’historique d’achats à un utilisateur.

---

### 6.3 `lib/services`

Les services communiquent avec l’extérieur, principalement l’API Platzi.

Ils ne gèrent pas directement l’interface graphique.

#### `api_client.dart`

C’est le client HTTP centralisé.

Rôle :

- construire les URLs API ;
- ajouter les headers JSON ;
- ajouter le token si une route nécessite l’authentification ;
- envoyer les requêtes GET, POST, PUT, DELETE ;
- décoder les réponses JSON ;
- gérer les erreurs API.

Méthodes principales :

| Méthode | Rôle |
|---|---|
| `get()` | Lire des données depuis l’API. |
| `post()` | Envoyer des données à l’API. |
| `put()` | Modifier une donnée API. |
| `delete()` | Supprimer une donnée API. |
| `_decodeJson()` | Convertir la réponse HTTP en JSON Dart. |
| `_jsonHeaders()` | Préparer les headers HTTP. |
| `_cleanQuery()` | Nettoyer les paramètres de recherche. |

La classe `ApiException` permet de représenter proprement une erreur HTTP.

#### `auth_service.dart`

Gère les appels API liés à l’authentification.

Méthodes :

| Méthode | Endpoint | Rôle |
|---|---|---|
| `login()` | `POST /auth/login` | Connexion utilisateur et récupération du token. |
| `getProfile()` | `GET /auth/profile` | Récupération du profil connecté. |
| `register()` | `POST /users` | Création d’un compte utilisateur. |

Ce service ne sauvegarde rien. Il appelle seulement l’API.

#### `product_service.dart`

Gère les produits et les catégories.

Méthodes :

| Méthode | Rôle |
|---|---|
| `fetchProducts()` | Récupère les produits avec pagination et filtres. |
| `fetchProduct()` | Récupère un produit précis par son `id`. |
| `fetchCategories()` | Récupère les catégories. |
| `createProduct()` | Propose / crée un nouveau produit via l’API. |
| `getMockProducts()` | Fournit 30 produits locaux si l’API ne répond pas. |

Point important :

```dart
getMockProducts()
```

Cette méthode joue le même rôle que le fallback mock du TD6 : éviter d’avoir un écran vide si l’API ne fonctionne pas.

---

### 6.4 `lib/repositories`

Les repositories servent d’intermédiaires entre les providers et les sources de données.

#### `local_storage.dart`

Gère `SharedPreferences`.

Données stockées :

| Donnée | Clé | Type sauvegardé |
|---|---|---|
| Onboarding vu | `onboarding_seen` | `bool` |
| Token | `auth_token` | `String` |
| Utilisateur | `auth_user` | `String JSON` |
| Favoris | `favorites` | `String JSON` |

Méthodes :

| Méthode | Rôle |
|---|---|
| `init()` | Initialise `SharedPreferences`. |
| `setOnboardingSeen()` | Sauvegarde si l’écran d’accueil a été vu. |
| `getOnboardingSeen()` | Récupère l’état de l’écran d’accueil. |
| `setToken()` | Sauvegarde ou supprime le token. |
| `getToken()` | Récupère le token. |
| `setUser()` | Sauvegarde ou supprime l’utilisateur. |
| `getUser()` | Récupère l’utilisateur. |
| `saveFavorites()` | Sauvegarde les favoris en JSON. |
| `loadFavorites()` | Recharge les favoris depuis JSON. |

#### `database_storage.dart`

Gère le panier SQLite avec `sqflite`.

Tables créées :

```sql
cart_items
orders
```

Table `cart_items` :

| Colonne | Type | Rôle |
|---|---|---|
| `user_id` | `INTEGER` | Utilisateur propriétaire du panier. |
| `product_id` | `INTEGER` | Produit ajouté. |
| `title` | `TEXT` | Nom du produit. |
| `price` | `REAL` | Prix. |
| `image` | `TEXT` | Image principale. |
| `quantity` | `INTEGER` | Quantité. |

Clé primaire :

```sql
PRIMARY KEY (user_id, product_id)
```

Cela empêche le même utilisateur d’avoir deux lignes séparées pour le même produit.

Table `orders` :

| Colonne | Type | Rôle |
|---|---|---|
| `id` | `TEXT` | Identifiant commande. |
| `user_id` | `INTEGER` | Utilisateur propriétaire. |
| `date` | `TEXT` | Date ISO. |
| `data` | `TEXT` | Commande complète en JSON. |

Méthodes :

| Méthode | Rôle |
|---|---|
| `init()` | Initialise la base SQLite. |
| `_openDatabase()` | Ouvre ou crée la base locale. |
| `loadCart()` | Charge le panier d’un utilisateur. |
| `saveCart()` | Sauvegarde le panier d’un utilisateur. |
| `loadOrders()` | Charge les commandes d’un utilisateur. |
| `saveOrders()` | Sauvegarde les commandes. |
| `close()` | Ferme la base. |

#### `auth_repository.dart`

Fait le lien entre :

- `AuthService` pour l’API ;
- `LocalStorage` pour la sauvegarde locale.

Méthodes :

| Méthode | Rôle |
|---|---|
| `isAuthenticated` | Vérifie si un token est présent. |
| `login()` | Connexion API puis sauvegarde token + profil. |
| `registerAndLogin()` | Création du compte puis connexion. |
| `clearAuth()` | Supprime token et utilisateur local. |
| `saveToken()` | Sauvegarde le token. |
| `saveUser()` | Sauvegarde l’utilisateur. |

---

### 6.5 `lib/providers`

Les providers contiennent l’état de l’application.

Ils héritent de `ChangeNotifier` et appellent `notifyListeners()` quand l’interface doit se mettre à jour.

#### `onboarding_provider.dart`

Gère l’écran d’accueil.

État principal :

```dart
bool _seen;
```

Si `_seen` vaut `true`, l’écran d’accueil n’est plus affiché.

Méthode :

```dart
setSeen(bool value)
```

Cette méthode sauvegarde la valeur dans `SharedPreferences` puis met à jour l’interface.

#### `auth_provider.dart`

Gère l’état de connexion.

États principaux :

| État | Rôle |
|---|---|
| `_user` | Utilisateur connecté. |
| `_token` | Token API. |
| `_loading` | Indique si une action est en cours. |
| `_error` | Message d’erreur éventuel. |

Méthodes :

| Méthode | Rôle |
|---|---|
| `hydrate()` | Recharge token + utilisateur depuis le stockage local. |
| `login()` | Connecte l’utilisateur. |
| `register()` | Crée un compte puis connecte. |
| `logout()` | Déconnecte l’utilisateur. |
| `tokenProvider()` | Fournit le token à `ApiClient`. |

#### `product_provider.dart`

Gère la liste de produits.

États principaux :

| État | Rôle |
|---|---|
| `_products` | Liste des produits affichés. |
| `_categories` | Liste des catégories. |
| `_loading` | Chargement en cours. |
| `_error` | Erreur API éventuelle. |
| `_categoryId` | Filtre catégorie. |
| `_priceMin` / `_priceMax` | Filtres de prix. |
| `_search` | Texte de recherche. |
| `_offset` / `_limit` | Pagination. |
| `_hasMore` | Indique s’il reste des produits à charger. |

Méthodes :

| Méthode | Rôle |
|---|---|
| `loadCategories()` | Charge les catégories. |
| `refresh()` | Recharge la liste depuis le début. |
| `loadMore()` | Charge une page supplémentaire de produits. |
| `applyFilters()` | Applique recherche, catégorie et prix. |
| `setSearch()` | Met à jour le texte de recherche. |
| `clearFilters()` | Réinitialise les filtres. |
| `fetchProductById()` | Récupère un produit depuis la liste locale ou l’API. |
| `createProduct()` | Crée un produit via l’API. |

#### `favorites_provider.dart`

Gère les favoris.

Persistance : `SharedPreferences` via `LocalStorage`.

État :

```dart
List<Product> _favorites;
```

Méthodes :

| Méthode | Rôle |
|---|---|
| `hydrate()` | Recharge les favoris depuis `SharedPreferences`. |
| `toggle()` | Ajoute ou retire un produit des favoris. |
| `remove()` | Retire un favori précis. |
| `clear()` | Vide tous les favoris. |
| `isFavorite()` | Vérifie si un produit est favori. |
| `_persist()` | Sauvegarde les favoris. |

#### `cart_provider.dart`

Gère le panier.

Persistance du panier : SQLite via `CartStorage`.

Le panier est lié à l’utilisateur connecté.

Méthodes :

| Méthode | Rôle |
|---|---|
| `hydrate()` | Recharge le panier de l’utilisateur connecté. |
| `addProduct()` | Ajoute un produit ou augmente sa quantité. |
| `removeProduct()` | Supprime un produit du panier. |
| `updateQuantity()` | Modifie la quantité. |
| `clear()` | Vide le panier. |
| `total` | Calcule le total du panier. |
| `_persist()` | Sauvegarde le panier dans SQLite. |

Si l’utilisateur n’est pas connecté, certaines méthodes lancent :

```dart
UnauthenticatedException
```

Cela respecte le cahier des charges : l’ajout au panier nécessite une connexion.

#### `orders_provider.dart`

Gère l’historique d’achats.

Persistance du panier : SQLite via `CartStorage`.

Méthodes :

| Méthode | Rôle |
|---|---|
| `hydrate()` | Recharge les commandes de l’utilisateur. |
| `addFromCart()` | Crée une commande à partir du panier. |
| `formatDate()` | Formate une date pour l’affichage. |
| `clear()` | Supprime l’historique local. |
| `_persist()` | Sauvegarde les commandes dans SQLite. |

---

### 6.6 `lib/router`

#### `app_router.dart`

Ce fichier gère toute la navigation.

Il utilise `go_router`.

Routes principales :

| Route | Page |
|---|---|
| `/onboarding` | Écran d’accueil. |
| `/home` | Liste des produits. |
| `/product/:id` | Détail produit. |
| `/favorites` | Favoris. |
| `/cart` | Panier. |
| `/orders` | Historique achats. |
| `/new-product` | Proposition d’article. |
| `/profile` | Profil. |
| `/login` | Connexion. |
| `/register` | Création compte. |

La classe `RouterNotifier` écoute :

- `OnboardingProvider` ;
- `AuthProvider`.

Elle sert à rediriger automatiquement :

- vers `/onboarding` si l’écran d’accueil n’a pas encore été validé ;
- vers `/login` si une page protégée nécessite une connexion.

La classe `_HomeShell` ajoute la navigation principale :

- `NavigationRail` sur grand écran Windows ;
- `NavigationBar` en bas sur petit écran ;
- bouton quitter sur la navigation desktop.

---

### 6.7 `lib/ui/screens`

Ce dossier contient toutes les pages visibles par l’utilisateur.

#### `onboarding_screen.dart`

Page d’accueil au premier lancement.

Fonctions :

- présenter l’application ;
- proposer de ne plus afficher l’écran ;
- enregistrer le choix dans `SharedPreferences` ;
- rediriger vers `/home`.

#### `auth/login_screen.dart`

Page de connexion.

Fonctions :

- saisir email et mot de passe ;
- appeler `AuthProvider.login()` ;
- afficher les erreurs ;
- rediriger vers `/home` après connexion.

#### `auth/register_screen.dart`

Page de création de compte.

Fonctions :

- saisir nom, email, mot de passe ;
- appeler `AuthProvider.register()` ;
- connecter automatiquement après création ;
- rediriger vers `/home`.

#### `products/products_screen.dart`

Page catalogue.

Fonctions :

- afficher les produits ;
- barre de recherche ;
- filtres catégorie / prix ;
- pagination ;
- bouton favoris ;
- bouton panier ;
- bouton profil ;
- bouton quitter ;
- accès au détail produit.

Cette page consomme `ProductProvider`.

#### `products/product_detail_screen.dart`

Page détail produit.

Fonctions :

- afficher image, titre, prix, catégorie et description ;
- ajouter / retirer des favoris ;
- ajouter au panier ;
- revenir aux pages principales ;
- éviter le blocage utilisateur grâce aux boutons de navigation.

Cette page utilise :

- `ProductProvider` pour récupérer le produit ;
- `FavoritesProvider` pour les favoris ;
- `CartProvider` pour le panier ;
- `AuthProvider` pour vérifier la connexion.

#### `favorites/favorites_screen.dart`

Page favoris.

Fonctions :

- afficher les produits favoris ;
- retirer un favori ;
- ouvrir le détail du produit.

Cette page consomme `FavoritesProvider`.

#### `cart/cart_screen.dart`

Page panier.

Fonctions :

- afficher les articles du panier ;
- augmenter ou diminuer la quantité ;
- supprimer un article ;
- afficher le total ;
- valider l’achat ;
- créer une commande dans l’historique ;
- vider le panier après validation.

Cette page utilise :

- `CartProvider` ;
- `OrdersProvider`.

#### `orders/orders_screen.dart`

Page historique des achats.

Fonctions :

- afficher les commandes passées ;
- afficher la date, le total et les articles ;
- vider l’historique local si nécessaire.

Cette page consomme `OrdersProvider`.

#### `product_form/new_product_screen.dart`

Page de proposition d’article.

Fonctions :

- saisir titre, description, prix, catégorie et image ;
- valider les champs ;
- envoyer le produit à l’API ;
- afficher un message de réussite ou d’erreur.

Cette page utilise `ProductProvider.createProduct()`.

#### `profile/profile_screen.dart`

Page profil.

Fonctions si connecté :

- afficher avatar, nom et email ;
- aller vers historique d’achats ;
- aller vers proposition d’article ;
- se déconnecter.

Fonctions si non connecté :

- bouton se connecter ;
- bouton créer un compte.

---

### 6.8 `lib/ui/widgets`

#### `product_tile.dart`

Widget réutilisable pour afficher une carte produit.

Fonctions :

- afficher image ;
- afficher titre ;
- afficher prix ;
- afficher catégorie ;
- bouton favori ;
- bouton ajouter au panier ;
- redirection vers login si l’utilisateur n’est pas connecté.

Ce widget est utilisé dans :

- la page produits ;
- la page favoris.

---

## 7. Flux fonctionnels importants

### 7.1 Flux favoris

```text
Utilisateur clique sur cœur
        ↓
ProductTile appelle FavoritesProvider.toggle(product)
        ↓
Le provider ajoute ou retire le produit dans _favorites
        ↓
LocalStorage.saveFavorites() sauvegarde la liste en JSON
        ↓
notifyListeners() met l’interface à jour
```

Persistance utilisée : `SharedPreferences`.

---

### 7.2 Flux panier

```text
Utilisateur clique sur Ajouter au panier
        ↓
ProductTile vérifie AuthProvider.isAuthenticated
        ↓
Si connecté : CartProvider.addProduct(product)
        ↓
Le produit devient un CartItem
        ↓
DatabaseStorage.saveCart(userId, items)
        ↓
SQLite sauvegarde le panier
        ↓
notifyListeners() met l’interface à jour
```

Persistance utilisée : `sqflite` pour le panier, `Supabase` pour l’historique.

---

### 7.3 Flux validation achat

```text
Utilisateur clique sur Valider le panier
        ↓
CartScreen appelle OrdersProvider.addFromCart(cart.items)
        ↓
Création d’une Order avec date + articles
        ↓
SupabaseOrderService.createOrder(user, items)
        ↓
CartProvider.clear()
        ↓
Le panier est vidé
```

Persistance utilisée : `sqflite` pour le panier, `Supabase` pour l’historique.

---

### 7.4 Flux authentification

```text
Utilisateur saisit email + mot de passe
        ↓
LoginScreen appelle AuthProvider.login()
        ↓
AuthRepository appelle AuthService.login()
        ↓
AuthService appelle API /auth/login
        ↓
Token reçu
        ↓
AuthService récupère /auth/profile
        ↓
AuthRepository sauvegarde token + user dans SharedPreferences
        ↓
AuthProvider notifie l’interface
```

Persistance utilisée : `SharedPreferences`.

---

### 7.5 Flux produits

```text
ProductsScreen demande les produits
        ↓
ProductProvider.refresh()
        ↓
ProductService.fetchProducts()
        ↓
ApiClient GET /products
        ↓
Product.fromJson() transforme le JSON en objets Dart
        ↓
Si l’API échoue : ProductService.getMockProducts()
        ↓
ProductsScreen affiche les ProductTile
```

Source des données : API Platzi + catalogue local de secours.

---

## 8. Packages principaux

| Package | Utilisation |
|---|---|
| `provider` | Gestion d’état avec `ChangeNotifier`. |
| `go_router` | Navigation et redirections. |
| `http` | Requêtes vers l’API. |
| `shared_preferences` | Stockage clé / valeur local. |
| `sqflite` | Base SQLite locale. |
| `sqflite_common_ffi` | SQLite sur Windows/macOS/Linux. |
| `cached_network_image` | Chargement optimisé des images réseau. |
| `intl` | Formatage des dates. |

---

## 9. Points importants à expliquer à l’oral

### Pourquoi `SharedPreferences` ?

Parce que c’est simple pour des petites données : booléen, token, utilisateur JSON, favoris JSON.

### Pourquoi `sqflite` ?

Parce que le panier et les commandes sont plus structurés : plusieurs champs, quantité, prix, utilisateur, historique.

### Pourquoi des providers ?

Pour séparer l’état de l’interface. Les écrans ne gèrent pas directement les données : ils appellent les providers.

### Pourquoi des services ?

Pour isoler les appels API. Si l’API change, on modifie les services, pas toutes les pages.

### Pourquoi des repositories ?

Pour isoler la persistance locale. Les providers n’ont pas besoin de connaître les détails de `SharedPreferences` ou SQLite.

### Pourquoi un catalogue local de secours ?

Pour éviter un écran vide si l’API Platzi ne répond pas ou si le réseau bloque l’accès.

---

## 10. Commandes utiles

Installer les dépendances :

```bash
flutter pub get
```

Nettoyer le projet :

```bash
flutter clean
```

Lancer sur Windows :

```bash
flutter run -d windows
```

Analyser le code :

```bash
flutter analyze
```

Lancer les tests :

```bash
flutter test
```

---

## 11. Attention Chrome / Edge

La version avec `sqflite` est prévue pour Windows desktop.

Sur Chrome ou Edge, `sqflite` desktop et `dart:io` ne fonctionnent pas directement. Il faut donc lancer :

```bash
flutter run -d windows
```

et non :

```bash
flutter run -d chrome
```

Pour une version web, le projet utilise un stockage mémoire de secours pour éviter l’écran blanc. Options possibles :

- `SharedPreferences` uniquement ;
- IndexedDB ;
- Firebase ;
- Supabase.

---

## 12. Résumé final

Le projet est organisé comme une vraie application Flutter structurée :

```text
UI → Providers → Services / Repositories → Models → API / Stockage local
```

La logique du TD6 est reprise :

- `Provider / ChangeNotifier` pour l’état ;
- `SharedPreferences` pour les données simples ;
- `sqflite` pour le panier structuré ;
- injection des dépendances dans `main.dart` ;
- séparation claire des fichiers ;
- navigation propre avec `go_router` ;
- fallback local pour éviter les écrans vides.
