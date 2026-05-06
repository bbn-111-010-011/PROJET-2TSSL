/// Modèle représentant une catégorie de produits.
///
/// Utilisé pour afficher la catégorie d'un article et pour filtrer ou créer
/// des produits via l'API.

class Category {
  final int id;
  final String name;
  final String image;

  Category({
    required this.id,
    required this.name,
    required this.image,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image': image,
      };
}
