# 04 — Guide fichier par fichier

## `lib/main.dart`

Point d’entrée de l’application.

Responsabilités :

- initialiser Flutter ;
- initialiser SQLite sur desktop ;
- initialiser `SharedPreferences` ;
- créer les services ;
- créer les repositories ;
- créer les providers ;
- hydrater les données locales ;
- créer le router ;
- lancer `MyApp`.

## `lib/core/constants.dart`

Centralise :

- l’URL de l’API Platzi ;
- les clés `SharedPreferences`.

## Models

### `product.dart`

Objet article.

Contient : titre, prix, description, images, catégorie.

Utilisé dans : catalogue, détails, favoris, panier.

### `category.dart`

Objet catégorie.

Utilisé pour afficher et filtrer les produits.

### `cart_item.dart`

Objet ligne de panier.

Contient : produit, prix, quantité, image.

### `order.dart`

Objet commande.

Contient : date, liste des articles achetés, total.

### `user.dart`

Objet utilisateur connecté.

Contient : id, nom, email, avatar, rôle.

## Services

### `api_client.dart`

Client HTTP générique.

Toutes les requêtes API passent par lui.

### `auth_service.dart`

Service API pour :

- connexion ;
- profil ;
- inscription.

### `product_service.dart`

Service API pour :

- produits ;
- catégories ;
- création produit ;
- produits locaux de secours.

## Repositories

### `local_storage.dart`

Gère `SharedPreferences`.

Stocke : onboarding, token, utilisateur, favoris.

### `database_storage.dart`

Gère SQLite.

Stocke : panier et commandes.

### `auth_repository.dart`

Relie API auth et stockage local.

## Providers

### `onboarding_provider.dart`

Gère l’écran de bienvenue.

### `auth_provider.dart`

Gère connexion, inscription, déconnexion.

### `product_provider.dart`

Gère liste produits, recherche, filtres, pagination.

### `favorites_provider.dart`

Gère les favoris avec SharedPreferences.

### `cart_provider.dart`

Gère le panier avec SQLite.

### `orders_provider.dart`

Gère l’historique d’achats avec Supabase.

## Router

### `app_router.dart`

Gère toutes les routes avec `go_router`.

Ajoute aussi la navigation principale :

- navigation gauche sur desktop ;
- navigation basse sur petit écran.

## UI

### `onboarding_screen.dart`

Écran d’accueil.

### `login_screen.dart`

Formulaire de connexion.

### `register_screen.dart`

Formulaire d’inscription.

### `products_screen.dart`

Catalogue produits + recherche + filtres.

### `product_detail_screen.dart`

Détail d’un produit.

### `favorites_screen.dart`

Liste des favoris.

### `cart_screen.dart`

Panier + validation achat.

### `orders_screen.dart`

Historique des commandes.

### `new_product_screen.dart`

Formulaire de création produit.

### `profile_screen.dart`

Profil utilisateur.

### `product_tile.dart`

Carte produit réutilisable.
