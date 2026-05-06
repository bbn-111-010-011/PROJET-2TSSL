# 03 — Flux fonctionnels

## Consultation des produits

```text
ProductsScreen
    ↓ appelle
ProductProvider.refresh()
    ↓ appelle
ProductService.fetchProducts()
    ↓ appelle
ApiClient.get('/products')
    ↓ transforme
Product.fromJson()
    ↓ affiche
ProductTile
```

Si l’API échoue :

```text
ProductService.getMockProducts()
```

est utilisé pour afficher 30 produits locaux.

## Favoris

```text
Clic sur cœur
    ↓
FavoritesProvider.toggle(product)
    ↓
Ajout ou suppression dans _favorites
    ↓
LocalStorage.saveFavorites()
    ↓
SharedPreferences
    ↓
notifyListeners()
```

## Panier

```text
Clic sur Ajouter
    ↓
Vérification AuthProvider.isAuthenticated
    ↓
CartProvider.addProduct(product)
    ↓
Transformation Product → CartItem
    ↓
DatabaseStorage.saveCart(userId, items)
    ↓
SQLite
```

## Validation du panier

```text
CartScreen
    ↓
OrdersProvider.addFromCart(cart.items)
    ↓
Création d’une commande Order
    ↓
SupabaseOrderService.createOrder(user, items)
    ↓
CartProvider.clear()
    ↓
Panier vidé
```

## Authentification

```text
LoginScreen
    ↓
AuthProvider.login(email, password)
    ↓
AuthRepository.login()
    ↓
AuthService.login()
    ↓
API /auth/login
    ↓
Token reçu
    ↓
API /auth/profile
    ↓
LocalStorage.setToken() + LocalStorage.setUser()
    ↓
Utilisateur connecté
```

## Navigation protégée

Certaines routes nécessitent une connexion :

```text
/cart
/orders
/new-product
```

Si l’utilisateur n’est pas connecté, `RouterNotifier.redirect()` le renvoie vers :

```text
/login
```
