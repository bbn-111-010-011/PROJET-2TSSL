import 'product.dart';

/// Modèle représentant une ligne du panier.
///
/// Un CartItem contient les informations nécessaires pour :
/// - afficher le panier ;
/// - sauvegarder le panier en sqflite ;
/// - envoyer l'achat dans Supabase avec le nom et la catégorie du produit.
class CartItem {
  final int productId;
  final String title;
  final double price;
  final String image;
  final String categoryName;
  final int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.categoryName,
    required this.quantity,
  });

  /// Crée une ligne panier à partir d'un produit récupéré depuis l'API.
  factory CartItem.fromProduct(Product p, {int quantity = 1}) {
    return CartItem(
      productId: p.id,
      title: p.title,
      price: p.price,
      image: p.images.isNotEmpty ? p.images.first : '',
      categoryName: p.category?.name ?? 'Non renseignée',
      quantity: quantity,
    );
  }

  /// Permet de modifier une ligne panier sans recréer l'objet à la main.
  CartItem copyWith({
    int? productId,
    String? title,
    double? price,
    String? image,
    String? categoryName,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryName: categoryName ?? this.categoryName,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Reconstruit un CartItem depuis JSON, SharedPreferences ou sqflite.
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final priceValue = json['price'] ?? json['prix'];
    final parsedPrice = priceValue is num
        ? priceValue.toDouble()
        : double.tryParse(priceValue?.toString() ?? '') ?? 0.0;

    final productValue = json['productId'] ??
        json['product_id'] ??
        json['id_produit'];

    return CartItem(
      productId: productValue is num
          ? productValue.toInt()
          : int.tryParse(productValue?.toString() ?? '') ?? 0,
      title: json['title'] as String? ??
          json['nom_produit'] as String? ??
          json['nom'] as String? ??
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

  /// Convertit la ligne panier en JSON.
  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'price': price,
        'image': image,
        'categoryName': categoryName,
        'quantity': quantity,
      };

  double get lineTotal => price * quantity;
}
