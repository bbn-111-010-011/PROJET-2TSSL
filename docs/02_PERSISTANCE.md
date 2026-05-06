# 02 — Persistance utilisée

## Principe

Le projet utilise deux formes de stockage local :

- `SharedPreferences` pour les données simples ;
- `sqflite` pour les données structurées.

Cette logique reprend l’idée du TD6 : choisir la persistance selon la nature de la donnée.

## Tableau de choix

| Fonctionnalité | Persistance | Facilité | Pourquoi ce choix ? |
|---|---|---|---|
| Écran d’accueil déjà vu | `SharedPreferences` | Très facile | Un simple booléen suffit. |
| Token de connexion | `SharedPreferences` | Très facile | Une chaîne de caractères suffit. |
| Profil utilisateur | `SharedPreferences` | Facile | Petit objet converti en JSON. |
| Favoris | `SharedPreferences` | Facile | Liste simple de produits convertie en JSON. |
| Panier | `sqflite` | Moyen | Données structurées par utilisateur avec quantités. |
| Historique achats | `Supabase` | Moyen | Commandes avec date, articles et total visibles dans le dashboard Supabase. |
| Produits | API + fallback local | Facile | Pas besoin de les stocker localement. |
| Recherche / filtres | Mémoire | Très facile | Temporaire, pas besoin de stockage. |

## SharedPreferences

`SharedPreferences` fonctionne comme un fichier clé / valeur.

Exemple :

```text
clé: auth_token
valeur: eyJhbGciOi...
```

Pour les objets complexes, on utilise du JSON.

Exemple favoris :

```text
List<Product> → List<Map> → jsonEncode() → String → SharedPreferences
```

## SQLite / sqflite

SQLite est utilisé pour les données plus structurées.

Deux tables sont créées :

```sql
cart_items
orders
```

### Table `cart_items`

```sql
CREATE TABLE cart_items (
  user_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  title TEXT NOT NULL,
  price REAL NOT NULL,
  image TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  PRIMARY KEY (user_id, product_id)
)
```

Cette table permet d’avoir un panier différent pour chaque utilisateur.

### Table `orders`

```sql
CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  user_id INTEGER NOT NULL,
  date TEXT NOT NULL,
  data TEXT NOT NULL
)
```

La colonne `data` stocke le détail complet de la commande en JSON.

## Résumé oral

> J’ai utilisé SharedPreferences pour les petites données simples comme le token, l’utilisateur, l’écran d’accueil et les favoris. Pour le panier, j’ai utilisé SQLite avec sqflite. Pour l’historique, j’ai utilisé Supabase, car ce sont des données structurées liées à un utilisateur et avec plusieurs champs comme quantité, prix, date et produits.
