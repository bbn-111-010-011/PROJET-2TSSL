# Guide simple des fonctionnalités du projet

## Technologies utilisées

| Fonctionnalité | Technologie |
|---|---|
| Compte utilisateur / connexion | API Platzi Fake Store |
| Profil connecté | SharedPreferences |
| Produits | API Platzi Fake Store |
| Recherche / filtres | API Platzi Fake Store |
| Favoris | SharedPreferences |
| Panier | sqflite |
| Historique achats | Supabase |
| Navigation | GoRouter |

## Flux principal

```text
Lancement application
→ Chargement des produits depuis l'API
→ Consultation du détail produit
→ Ajout aux favoris ou au panier
→ Validation du panier
→ Envoi de la commande dans Supabase
→ Consultation de l'historique depuis Supabase
```

## Navigation

Les pages principales sont accessibles avec la navigation fluide :

```text
Produits → Favoris → Panier → Profil
```

Dans le profil, l'utilisateur peut accéder à :

```text
Historique des achats
Ajouter un article
Déconnexion
```

## Explication rapide pour le jury

Le projet est structuré en couches :

```text
UI / Screens
→ Providers
→ Services / Repositories
→ Models
→ API / SharedPreferences / sqflite / Supabase
```

Cette structure permet de séparer l'affichage, la logique métier et la persistance.
