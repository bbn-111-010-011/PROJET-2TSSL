import 'cart_item.dart';

class OrderItem {
  final int productId;
  final String title;
  final double price;
  final String image;
  final String categoryName;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.categoryName,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? json['prix'];
    final parsedPrice = priceValue is num
        ? priceValue.toDouble()
        : double.tryParse(priceValue?.toString() ?? '') ?? 0.0;

    final productValue = json['productId'] ??
        json['product_id'] ??
        json['id_produit'];

    return OrderItem(
      productId: productValue is num
          ? productValue.toInt()
          : int.tryParse(productValue?.toString() ?? '') ?? 0,
      title: json['title'] as String? ??
          json['nom_produit'] as String? ??
          '',
      price: parsedPrice,
      image: json['image'] as String? ?? json['image_url'] as String? ?? '',
      categoryName: json['categoryName'] as String? ??
          json['category_name'] as String? ??
          json['categorie'] as String? ??
          'Non renseignée',
      quantity: (json['quantity'] as num?)?.toInt() ??
          (json['quantite'] as num?)?.toInt() ??
          1,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'price': price,
        'image': image,
        'categoryName': categoryName,
        'quantity': quantity,
      };

  /// JSON envoyé dans Supabase avec des noms d'attributs en français.
  Map<String, dynamic> toSupabaseJson() => {
        'id_produit': productId,
        'nom_produit': title,
        'categorie': categoryName,
        'prix': price,
        'quantite': quantity,
        'image': image,
        'total_ligne': lineTotal,
      };

  double get lineTotal => price * quantity;

  factory OrderItem.fromCartItem(CartItem c) => OrderItem(
        productId: c.productId,
        title: c.title,
        price: c.price,
        image: c.image,
        categoryName: c.categoryName,
        quantity: c.quantity,
      );
}

class Order {
  final String id;
  final DateTime date;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.items,
  });

  double get total => items.fold(0.0, (sum, it) => sum + it.lineTotal);

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List?) ??
        (json['articles'] as List?) ??
        const [];

    return Order(
      id: json['id']?.toString() ?? json['id_achat']?.toString() ?? '',
      date: DateTime.tryParse(
            json['date']?.toString() ?? json['date_achat']?.toString() ?? '',
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      items: itemsJson
          .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  /// Lecture d'une ligne Supabase de la table public.historique_achats.
  factory Order.fromSupabase(Map<String, dynamic> json) {
    final itemsJson = (json['articles'] as List?) ?? const [];

    return Order(
      id: json['id_achat']?.toString() ?? '',
      date: DateTime.tryParse(json['date_achat']?.toString() ?? '') ?? DateTime.now(),
      items: itemsJson
          .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };
}
