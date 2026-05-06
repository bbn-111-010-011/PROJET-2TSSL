/// Provider de gestion des favoris.
///
/// Les favoris sont sauvegardés dans SharedPreferences sous forme de JSON,
/// ce qui permet de les retrouver au prochain lancement de l'application.

import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../repositories/local_storage.dart';

/// Provider équivalent au FavorisProvider du TD6, adapté aux produits.
///
/// Logique retenue : on sauvegarde les produits favoris complets dans
/// SharedPreferences. Ainsi, l'écran Favoris reste affichable même si le
/// catalogue API n'est pas encore rechargé au lancement de l'application.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._storage) {
    _favorites = _storage.loadFavorites();
  }

  final LocalStorage _storage;
  List<Product> _favorites = [];

  List<Product> get favorites => List.unmodifiable(_favorites);
  List<int> get favoriteIds => _favorites.map((p) => p.id).toList(growable: false);

  bool isFavorite(int productId) => _favorites.any((p) => p.id == productId);

  Future<void> toggle(Product product) async {
    if (isFavorite(product.id)) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites = [..._favorites, product];
    }
    await _persist();
  }

  Future<void> remove(int productId) async {
    _favorites.removeWhere((p) => p.id == productId);
    await _persist();
  }

  Future<void> clear() async {
    _favorites = [];
    await _persist();
  }

  Future<void> hydrate() async {
    _favorites = _storage.loadFavorites();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveFavorites(_favorites);
    notifyListeners();
  }
}
