# Corrections appliquées

Cette version corrige les erreurs liées à Supabase, au panier et à la catégorie des produits.

## 1. Supabase

L'application n'utilise plus l'ancienne table `orders`.
Elle utilise maintenant :

```text
public.historique_achats
```

avec les colonnes en français :

```text
id_achat
date_achat
id_utilisateur
email_utilisateur
articles
statut_achat
montant
nom_produits
categories_produits
```

## 2. Nom et catégorie des produits dans Supabase

Quand un panier est validé, Flutter envoie maintenant :

```text
nom_produits           → noms visibles directement dans Supabase
categories_produits    → catégories visibles directement dans Supabase
articles               → détail complet en JSONB
```

Chaque article contient aussi :

```text
id_produit
nom_produit
categorie
prix
quantite
image
total_ligne
```

## 3. CartItem corrigé

Le modèle `CartItem` contient maintenant :

```text
productId
title
price
image
categoryName
quantity
```

Cela corrige l'erreur :

```text
The getter 'categoryName' isn't defined for the type 'CartItem'
```

## 4. sqflite corrigé

La table locale `cart_items` contient maintenant la colonne :

```text
category_name
```

La base locale passe en version 2 et ajoute automatiquement la colonne si une ancienne base existe.

## 5. Fichier SQL Supabase

Le fichier à utiliser pour Supabase est :

```text
SUPABASE_SQL_HISTORIQUE_FR.md
```
