/// Service API des produits.
///
/// Il récupère les produits et catégories depuis l'API Platzi, crée des
/// produits et fournit un catalogue local de secours si l'API échoue.

import '../models/product.dart';
import '../models/category.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient api;
  ProductService(this.api);

  Future<List<Product>> fetchProducts({
    int offset = 0,
    int limit = 30,
    int? categoryId,
    int? priceMin,
    int? priceMax,
    String? title,
  }) async {
    final query = <String, dynamic>{
      'offset': offset,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      if (priceMin != null) 'price_min': priceMin,
      if (priceMax != null) 'price_max': priceMax,
      if (title != null && title.isNotEmpty) 'title': title,
    };

    final data = await api.get('/products', query: query);
    if (data is List) {
      final products = data
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .where((p) => p.id != 0 && p.title.trim().isNotEmpty)
          .toList();

      if (products.isEmpty) {
        throw Exception('Aucun article valide retourné par l\'API.');
      }

      // Sur certains réseaux, l'API peut répondre avec très peu d'articles.
      // Pour le projet de fin d'année, on garantit un catalogue exploitable
      // d'environ 30 articles au premier chargement, sans casser la logique API.
      final noFilter = categoryId == null &&
          priceMin == null &&
          priceMax == null &&
          (title == null || title.isEmpty);
      if (offset == 0 && noFilter && products.length < limit) {
        final usedIds = products.map((p) => p.id).toSet();
        final complement = getMockProducts()
            .where((p) => !usedIds.contains(p.id))
            .take(limit - products.length);
        products.addAll(complement);
      }

      return products;
    }

    throw Exception('Réponse API produits invalide.');
  }

  Future<Product> fetchProduct(int id) async {
    final data = await api.get('/products/$id');
    return Product.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<Category>> fetchCategories() async {
    final data = await api.get('/categories');
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Category.fromJson)
          .toList();
    }
    return [];
  }

  /// Données de secours comme dans le TD6.
  /// Elles évitent un écran vide quand l'API Platzi est indisponible,
  /// bloquée par le réseau du lycée ou non accessible sur Windows.
  List<Product> getMockProducts() {
    final categories = <Category>[
      Category(id: 100, name: 'Informatique', image: ''),
      Category(id: 101, name: 'Accessoires', image: ''),
      Category(id: 102, name: 'Mode', image: ''),
      Category(id: 103, name: 'Maison', image: ''),
    ];

    return [
      Product(
        id: 10001,
        title: 'Sac à dos étudiant',
        price: 29.99,
        description: 'Sac pratique pour les cours, ordinateur et documents.',
        images: const ['https://picsum.photos/seed/2tssl-10001/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10002,
        title: 'Casque audio Bluetooth',
        price: 49.90,
        description: 'Casque sans fil idéal pour travailler ou écouter de la musique.',
        images: const ['https://picsum.photos/seed/2tssl-10002/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10003,
        title: 'Montre connectée',
        price: 79.00,
        description: 'Montre de démonstration avec suivi quotidien.',
        images: const ['https://picsum.photos/seed/2tssl-10003/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10004,
        title: 'Clavier mécanique',
        price: 65.50,
        description: 'Clavier confortable pour développement et bureautique.',
        images: const ['https://picsum.photos/seed/2tssl-10004/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10005,
        title: 'Souris ergonomique',
        price: 24.99,
        description: 'Souris légère adaptée aux longues sessions.',
        images: const ['https://picsum.photos/seed/2tssl-10005/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10006,
        title: 'Lampe de bureau LED',
        price: 34.90,
        description: 'Lampe réglable pour un poste de travail propre.',
        images: const ['https://picsum.photos/seed/2tssl-10006/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10007,
        title: 'Support ordinateur portable',
        price: 19.90,
        description: 'Support inclinable pour améliorer la posture.',
        images: const ['https://picsum.photos/seed/2tssl-10007/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10008,
        title: 'Chargeur USB-C rapide',
        price: 22.50,
        description: 'Chargeur compact pour téléphone et accessoires.',
        images: const ['https://picsum.photos/seed/2tssl-10008/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10009,
        title: 'Câble USB-C renforcé',
        price: 8.99,
        description: 'Câble tressé résistant pour usage quotidien.',
        images: const ['https://picsum.photos/seed/2tssl-10009/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10010,
        title: 'Batterie externe 10000 mAh',
        price: 31.90,
        description: 'Batterie de secours pour déplacements.',
        images: const ['https://picsum.photos/seed/2tssl-10010/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10011,
        title: 'T-shirt coton noir',
        price: 14.99,
        description: 'T-shirt simple pour tous les jours.',
        images: const ['https://picsum.photos/seed/2tssl-10011/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10012,
        title: 'Sweat à capuche',
        price: 39.99,
        description: 'Sweat confortable pour mi-saison.',
        images: const ['https://picsum.photos/seed/2tssl-10012/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10013,
        title: 'Veste légère',
        price: 59.90,
        description: 'Veste urbaine de démonstration.',
        images: const ['https://picsum.photos/seed/2tssl-10013/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10014,
        title: 'Jean coupe droite',
        price: 44.50,
        description: 'Jean classique adapté au quotidien.',
        images: const ['https://picsum.photos/seed/2tssl-10014/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10015,
        title: 'Baskets blanches',
        price: 69.00,
        description: 'Chaussures de ville simples et propres.',
        images: const ['https://picsum.photos/seed/2tssl-10015/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10016,
        title: 'Lunettes de soleil',
        price: 18.90,
        description: 'Accessoire mode de démonstration.',
        images: const ['https://picsum.photos/seed/2tssl-10016/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10017,
        title: 'Sac bandoulière',
        price: 27.90,
        description: 'Petit sac pratique pour sorties.',
        images: const ['https://picsum.photos/seed/2tssl-10017/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10018,
        title: 'Gourde inox',
        price: 15.90,
        description: 'Gourde réutilisable pour école ou sport.',
        images: const ['https://picsum.photos/seed/2tssl-10018/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10019,
        title: 'Carnet de notes',
        price: 6.50,
        description: 'Carnet papier pour organiser ses idées.',
        images: const ['https://picsum.photos/seed/2tssl-10019/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10020,
        title: 'Stylo premium',
        price: 4.90,
        description: 'Stylo confortable pour prise de notes.',
        images: const ['https://picsum.photos/seed/2tssl-10020/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10021,
        title: 'Tapis de souris XXL',
        price: 17.99,
        description: 'Grand tapis pour clavier et souris.',
        images: const ['https://picsum.photos/seed/2tssl-10021/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10022,
        title: 'Webcam Full HD',
        price: 45.90,
        description: 'Webcam pour visioconférences et cours.',
        images: const ['https://picsum.photos/seed/2tssl-10022/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10023,
        title: 'Micro USB compact',
        price: 54.90,
        description: 'Micro simple pour appels et enregistrements.',
        images: const ['https://picsum.photos/seed/2tssl-10023/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10024,
        title: 'Hub USB-C 6 ports',
        price: 36.90,
        description: 'Hub pratique pour ordinateur portable.',
        images: const ['https://picsum.photos/seed/2tssl-10024/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10025,
        title: 'Disque SSD externe',
        price: 89.90,
        description: 'Stockage externe rapide pour sauvegardes.',
        images: const ['https://picsum.photos/seed/2tssl-10025/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10026,
        title: 'Écouteurs filaires',
        price: 12.90,
        description: 'Écouteurs simples de secours.',
        images: const ['https://picsum.photos/seed/2tssl-10026/600/400'],
        category: categories[1],
      ),
      Product(
        id: 10027,
        title: 'Enceinte portable',
        price: 42.00,
        description: 'Petite enceinte Bluetooth transportable.',
        images: const ['https://picsum.photos/seed/2tssl-10027/600/400'],
        category: categories[2],
      ),
      Product(
        id: 10028,
        title: 'Porte-cartes',
        price: 11.90,
        description: 'Accessoire compact pour cartes et papiers.',
        images: const ['https://picsum.photos/seed/2tssl-10028/600/400'],
        category: categories[3],
      ),
      Product(
        id: 10029,
        title: 'Organiseur de bureau',
        price: 21.50,
        description: 'Rangement pour stylos, câbles et notes.',
        images: const ['https://picsum.photos/seed/2tssl-10029/600/400'],
        category: categories[0],
      ),
      Product(
        id: 10030,
        title: 'Kit nettoyage écran',
        price: 9.90,
        description: 'Kit pour nettoyer ordinateur, téléphone et tablette.',
        images: const ['https://picsum.photos/seed/2tssl-10030/600/400'],
        category: categories[1],
      ),
    ];
  }


  Future<Product> createProduct({
    required String title,
    required String description,
    required double price,
    required int categoryId,
    required List<String> images,
  }) async {
    final body = {
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'images': images,
    };
    final data = await api.post('/products', body: body, auth: true);
    return Product.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
