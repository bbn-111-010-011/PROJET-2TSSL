# Historique Git propose pour PROJET 2TSSL

Depot distant configure : `https://github.com/bbn-111-010-011/PROJET-2TSSL.git`

## Branches creees

| Branche | Fonctionnalite | Role |
|---|---|---|
| `feature/authentification-profil` | Connexion / inscription / profil | Permet de presenter le travail lie au compte utilisateur. |
| `feature/panier-sqflite` | Panier local | Permet de presenter le panier avec SQLite local via sqflite. |
| `feature/historique-supabase` | Historique des achats | Permet de presenter l'envoi des achats valides vers Supabase. |

## Commits principaux

1. `Initialiser le projet Flutter et les dependances`
   - Ajout du squelette Flutter multiplateforme.
   - Ajout des dependances principales : Provider, GoRouter, SharedPreferences, sqflite, Supabase.

2. `Ajouter les modeles metier de l application`
   - Ajout des modeles : produit, categorie, utilisateur, panier, commande.

3. `Ajouter les services API et le stockage local`
   - Ajout du client API.
   - Ajout des services produits et authentification.
   - Ajout du stockage local SharedPreferences.

4. `Ajouter l authentification et le profil utilisateur`
   - Ajout de la connexion.
   - Ajout de la creation de compte.
   - Ajout de la page profil.

5. `Ajouter la consultation des produits avec recherche et filtres`
   - Liste des produits depuis l'API.
   - Detail produit.
   - Recherche et filtres.
   - Formulaire d'ajout produit.

6. `Ajouter les favoris avec SharedPreferences`
   - Ajout / retrait de favoris.
   - Persistance des favoris en SharedPreferences.

7. `Ajouter le panier avec sqflite et les quantites`
   - Ajout / retrait panier.
   - Modification des quantites.
   - Sauvegarde locale SQLite via sqflite.

8. `Ajouter l historique des achats avec Supabase`
   - Validation du panier.
   - Envoi vers la table `historique_achats`.
   - Colonnes en francais : `nom_produits`, `categories_produits`, `montant`, `articles`.

9. `Ajouter la navigation fluide avec GoRouter`
   - Navigation centralisee.
   - Acces aux pages produits, favoris, panier, historique et profil.

10. `Ajouter les tests et la documentation du projet`
    - Ajout du test widget.
    - Ajout du test d'integration.
    - Ajout de la documentation technique et jury.

## Commandes pour pousser sur GitHub

```bash
git remote -v
git push -u origin main
git push origin feature/authentification-profil
git push origin feature/panier-sqflite
git push origin feature/historique-supabase
```
