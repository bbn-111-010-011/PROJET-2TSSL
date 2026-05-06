import '../models/cart_item.dart';

/// Contrat utilisé par CartProvider.
/// Le provider ne connaît pas la technologie utilisée : SQLite en desktop/mobile
/// ou mémoire de secours sur une cible non compatible.
abstract class CartStorage {
  Future<void> init();
  Future<List<CartItem>> loadCart(int userId);
  Future<void> saveCart(int userId, List<CartItem> items);
  Future<void> clearCart(int userId);
}

/// Stockage de secours utilisé lorsque SQLite n'est pas disponible.
/// Il évite l'écran blanc sur une cible web pendant les démonstrations.
class MemoryCartStorage implements CartStorage {
  final Map<int, List<CartItem>> _itemsByUser = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<CartItem>> loadCart(int userId) async {
    return List<CartItem>.from(_itemsByUser[userId] ?? const []);
  }

  @override
  Future<void> saveCart(int userId, List<CartItem> items) async {
    _itemsByUser[userId] = List<CartItem>.from(items);
  }

  @override
  Future<void> clearCart(int userId) async {
    _itemsByUser.remove(userId);
  }
}
