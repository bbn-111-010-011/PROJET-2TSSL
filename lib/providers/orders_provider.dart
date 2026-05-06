import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'auth_provider.dart';

/// Provider de l'historique des achats.
/// L'historique est envoyé puis relu depuis Supabase.
class OrdersProvider extends ChangeNotifier {
  final OrderService _service;
  final AuthProvider _auth;

  OrdersProvider(this._service, this._auth) {
    _auth.addListener(_onAuthChanged);
  }

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get loading => _loading;
  String? get error => _error;
  bool get isSupabaseConfigured => _service.isConfigured;

  Future<void> hydrate() => loadOrders();

  Future<void> loadOrders() async {
    final user = _auth.user;
    if (user == null) {
      _orders = [];
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _service.fetchOrders(user: user);
    } catch (e) {
      _error = 'Impossible de charger l’historique Supabase : $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> addFromCart(List<CartItem> items) async {
    final user = _auth.user;
    if (user == null || items.isEmpty) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.createOrder(user: user, items: items);
      _orders = await _service.fetchOrders(user: user);
    } catch (e) {
      _error = 'Achat non envoyé à Supabase : $e';
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String formatDate(DateTime d) => DateFormat('dd/MM/yyyy HH:mm').format(d);

  Future<void> clear() async {
    _orders = [];
    notifyListeners();
  }

  void _onAuthChanged() {
    loadOrders();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}
