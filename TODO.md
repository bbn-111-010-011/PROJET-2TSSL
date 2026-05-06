# État du projet PROJET 2TSSL

## Version actuelle

Version finalisée avec la logique TD6 :

- `Provider / ChangeNotifier`
- séparation modèles / services / repositories / providers / écrans
- injection de dépendances dans `main.dart`
- navigation avec `go_router`
- favoris persistants
- panier persistant
- historique d'achats persistant
- tests unitaires et widgets

## Choix de persistance

| Fonctionnalité | Persistance |
|---|---|
| Favoris | SharedPreferences |
| Token utilisateur | SharedPreferences |
| Profil utilisateur | SharedPreferences |
| Écran d'accueil déjà vu | SharedPreferences |
| Panier | SQLite avec sqflite |
| Historique d'achats | SQLite avec sqflite |
| Produits | API Platzi + catalogue local de secours |
| Recherche/filtres | Mémoire uniquement |

## À compléter avant rendu

- Ajouter les noms/prénoms des étudiants dans le README.
- Vérifier `flutter analyze` sur la machine de rendu.
- Vérifier `flutter test` après `flutter pub get`.
- Remplacer éventuellement les images de démonstration par un catalogue local plus cohérent.
