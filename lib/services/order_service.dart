import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/user.dart';

/// Service responsable de l'historique des achats.
///
/// Les achats sont envoyés dans Supabase dans la table :
/// public.historique_achats
///
/// Colonnes Supabase utilisées :
/// - id_achat : uuid
/// - date_achat : timestamptz
/// - id_utilisateur : int4
/// - email_utilisateur : text
/// - articles : jsonb
/// - statut_achat : text
/// - montant : numeric
/// - nom_produits : text
/// - categories_produits : text
abstract class OrderService {
  bool get isConfigured;

  Future<void> createOrder({
    required AppUser user,
    required List<CartItem> items,
  });

  Future<List<Order>> fetchOrders({
    required AppUser user,
  });
}

/// Service Supabase pour enregistrer et lire l'historique des achats.
class SupabaseOrderService implements OrderService {
  SupabaseOrderService({required this.client});

  final SupabaseClient? client;

  static const String _tableName = 'historique_achats';

  @override
  bool get isConfigured => client != null;

  @override
  Future<void> createOrder({
    required AppUser user,
    required List<CartItem> items,
  }) async {
    final supabase = client;

    if (supabase == null) {
      throw Exception('Supabase non configuré');
    }

    if (items.isEmpty) {
      throw Exception('Le panier est vide');
    }

    final orderItems = items.map(OrderItem.fromCartItem).toList();

    final montantTotal = orderItems.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );

    final nomsProduits = orderItems.map((item) => item.title).join(', ');

    final categoriesProduits = orderItems
        .map((item) => item.categoryName.isEmpty ? 'Non renseignée' : item.categoryName)
        .join(', ');

    await supabase.from(_tableName).insert({
      'id_utilisateur': user.id,
      'email_utilisateur': user.email,
      'articles': orderItems.map((item) => item.toSupabaseJson()).toList(),
      'statut_achat': 'valide',
      'montant': montantTotal,
      'nom_produits': nomsProduits,
      'categories_produits': categoriesProduits,
    });
  }

  @override
  Future<List<Order>> fetchOrders({
    required AppUser user,
  }) async {
    final supabase = client;

    if (supabase == null) {
      return [];
    }

    final data = await supabase
        .from(_tableName)
        .select()
        .eq('id_utilisateur', user.id)
        .order('date_achat', ascending: false);

    return (data as List<dynamic>)
        .map(
          (row) => _orderFromSupabaseRow(
            Map<String, dynamic>.from(row as Map),
          ),
        )
        .toList();
  }

  /// Transforme une ligne Supabase de historique_achats
  /// en objet Order utilisable dans Flutter.
  Order _orderFromSupabaseRow(Map<String, dynamic> row) {
    final articlesJson = _parseArticles(row['articles']);

    return Order(
      id: row['id_achat']?.toString() ?? '',
      date: DateTime.tryParse(row['date_achat']?.toString() ?? '') ?? DateTime.now(),
      items: articlesJson.map((article) {
        return OrderItem.fromJson(Map<String, dynamic>.from(article as Map));
      }).toList(),
    );
  }

  /// Sécurise la lecture de la colonne articles.
  ///
  /// Normalement Supabase renvoie une List car articles est en jsonb.
  /// Cette méthode gère aussi le cas où la valeur arrive en String JSON.
  List<dynamic> _parseArticles(dynamic value) {
    if (value == null) {
      return [];
    }

    if (value is List) {
      return value;
    }

    if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded;
      }
    }

    return [];
  }
}

/// Service mémoire utilisé seulement en secours.
///
/// Il évite un crash si Supabase n'est pas configuré.
/// Il ne sauvegarde pas réellement dans Supabase.
class MemoryOrderService implements OrderService {
  final Map<int, List<Order>> _ordersByUser = {};

  @override
  bool get isConfigured => true;

  @override
  Future<void> createOrder({
    required AppUser user,
    required List<CartItem> items,
  }) async {
    if (items.isEmpty) return;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      items: items.map(OrderItem.fromCartItem).toList(),
    );

    _ordersByUser[user.id] = [
      order,
      ...(_ordersByUser[user.id] ?? const []),
    ];
  }

  @override
  Future<List<Order>> fetchOrders({
    required AppUser user,
  }) async {
    return List<Order>.from(_ordersByUser[user.id] ?? const []);
  }
}
