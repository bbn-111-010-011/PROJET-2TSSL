# 05 — Explication du code par couche

## 1. Modèles

Les modèles sont des classes simples.

Ils ne doivent pas :

- afficher l’interface ;
- appeler l’API ;
- sauvegarder directement dans la base.

Ils doivent seulement représenter les données.

Exemple :

```dart
factory Product.fromJson(Map<String, dynamic> json)
```

Cette méthode sert à transformer une réponse API en objet Dart.

```dart
Map<String, dynamic> toJson()
```

Cette méthode sert à transformer l’objet Dart en JSON pour la sauvegarde locale.

## 2. Services

Les services sont responsables des appels externes.

Exemple :

```dart
final data = await api.get('/products', query: query);
```

Le service demande les produits à l’API.

Il transforme ensuite la réponse avec :

```dart
.map(Product.fromJson)
```

## 3. Repositories

Les repositories isolent le stockage.

Exemple `LocalStorage` :

```dart
await _p.setString(Constants.spFavorites, jsonEncode(data));
```

Ici, les favoris sont convertis en JSON puis sauvegardés en `String`.

Exemple `DatabaseStorage` :

```dart
await txn.insert('cart_items', {...});
```

Ici, le panier est sauvegardé dans SQLite, et l’historique d’achat est envoyé dans Supabase.

## 4. Providers

Les providers font le lien entre l’interface et les données.

Exemple :

```dart
Future<void> toggle(Product product) async {
  if (isFavorite(product.id)) {
    _favorites.removeWhere((p) => p.id == product.id);
  } else {
    _favorites = [..._favorites, product];
  }
  await _persist();
}
```

Cette méthode :

1. vérifie si le produit est déjà favori ;
2. l’ajoute ou le retire ;
3. sauvegarde la liste ;
4. met à jour l’interface.

La mise à jour est déclenchée par :

```dart
notifyListeners();
```

## 5. UI

Les écrans ne doivent pas contenir trop de logique métier.

Ils doivent principalement :

- lire les providers ;
- afficher les données ;
- appeler les méthodes providers lors des actions utilisateur.

Exemple :

```dart
context.read<CartProvider>().addProduct(product);
```

Le widget demande au provider d’ajouter le produit au panier.

## 6. Navigation

Le router centralise les routes.

Exemple :

```dart
GoRoute(
  path: '/cart',
  builder: (context, state) => const CartScreen(),
)
```

La navigation se fait ensuite avec :

```dart
context.go('/cart');
```
