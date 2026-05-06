/// Modèle représentant un produit du marketplace.
///
/// Il sert à convertir les données JSON de l'API Platzi en objet Dart,
/// puis à reconvertir l'objet en JSON pour les favoris ou autres usages locaux.

import 'category.dart';

class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final List<String> images;
  final Category? category;
  final DateTime? creationAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.images,
    this.category,
    this.creationAt,
    this.updatedAt,
  });

  static String _cleanImageUrl(String value) {
    // L'API Platzi retourne parfois des URLs sous forme de chaîne
    // ["https://..."] ; on nettoie pour éviter des images cassées.
    return value
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .trim();
  }

  static String _cleanText(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final imgs = (json['images'] as List?)
            ?.map((e) => _cleanImageUrl(e?.toString() ?? ''))
            .where((e) => e.isNotEmpty && e.startsWith('http'))
            .toList() ??
        const <String>[];

    final priceNum = json['price'];
    final parsedPrice = priceNum is num
        ? priceNum.toDouble()
        : double.tryParse(priceNum?.toString() ?? '') ?? 0.0;

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: _cleanText(json['title'], 'Article sans titre'),
      price: parsedPrice,
      description: _cleanText(json['description'], 'Aucune description disponible.'),
      images: imgs,
      category: json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      creationAt: json['creationAt'] != null
          ? DateTime.tryParse(json['creationAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'images': images,
        'category': category?.toJson(),
        'creationAt': creationAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  Product copyWith({
    int? id,
    String? title,
    double? price,
    String? description,
    List<String>? images,
    Category? category,
    DateTime? creationAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      creationAt: creationAt ?? this.creationAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Product && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
