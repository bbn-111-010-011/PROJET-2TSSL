import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../repositories/cart_storage.dart';
import 'auth_provider.dart';

class UnauthenticatedException implements Exception {
  @override
  String toString() => 'Utilisateur non authentifié';
}

/// Provider du panier.
/// Il garde l'état en mémoire et sauvegarde avec sqflite via CartStorage.
class CartProvider extends ChangeNotifier {
  final CartStorage _storage;
  final AuthProvider _auth;

  CartProvider(this._storage, this._auth) {
    _auth.addListener(_onAuthChanged);
  }

  List<CartItem> _items = [];
  bool _loading = false;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get loading => _loading;

  int get _userId => _auth.user?.id ?? -1;
  bool get _hasUser => _auth.user != null;

  Future<void> hydrate() async {
    _loading = true;
    notifyListeners();

    if (_hasUser) {
      _items = await _storage.loadCart(_userId);
    } else {
      _items = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addProduct(Product p, {int quantity = 1}) async {
    if (!_hasUser) throw UnauthenticatedException();
    final idx = _items.indexWhere((e) => e.productId == p.id);
    if (idx == -1) {
      _items = [..._items, CartItem.fromProduct(p, quantity: quantity)];
    } else {
      final existing = _items[idx];
      _items = [
        ..._items.sublist(0, idx),
        existing.copyWith(quantity: existing.quantity + quantity),
        ..._items.sublist(idx + 1),
      ];
    }
    await _persist();
  }

  Future<void> removeProduct(int productId) async {
    if (!_hasUser) throw UnauthenticatedException();
    _items = _items.where((e) => e.productId != productId).toList();
    await _persist();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (!_hasUser) throw UnauthenticatedException();
    final idx = _items.indexWhere((e) => e.productId == productId);
    if (idx == -1) return;
    if (quantity <= 0) {
      await removeProduct(productId);
      return;
    }
    final existing = _items[idx];
    _items = [
      ..._items.sublist(0, idx),
      existing.copyWith(quantity: quantity),
      ..._items.sublist(idx + 1),
    ];
    await _persist();
  }

  double get total => _items.fold(0.0, (sum, it) => sum + it.lineTotal);

  Future<void> clear() async {
    if (!_hasUser) throw UnauthenticatedException();
    _items = [];
    await _storage.clearCart(_userId);
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveCart(_userId, _items);
    notifyListeners();
  }

  void _onAuthChanged() {
    hydrate();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
