import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';
import 'cart_storage_interface.dart';

/// Crée le stockage panier adapté à la cible IO : SQLite avec sqflite.
CartStorage createCartStorage() => SqfliteCartStorage();

/// Persistance réelle du panier avec sqflite.
///
/// Table : cart_items.
/// Une ligne = un produit dans le panier d'un utilisateur.
class SqfliteCartStorage implements CartStorage {
  SqfliteCartStorage({this.databasePath});

  final String? databasePath;
  Database? _database;

  @override
  Future<void> init() async {
    _database ??= await openDatabase(
      databasePath ?? '${await getDatabasesPath()}/projet_2tssl_cart.db',
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cart_items (
            user_id INTEGER NOT NULL,
            product_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            price REAL NOT NULL,
            image TEXT NOT NULL,
            category_name TEXT NOT NULL DEFAULT 'Non renseignée',
            quantity INTEGER NOT NULL,
            PRIMARY KEY (user_id, product_id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE cart_items ADD COLUMN category_name TEXT NOT NULL DEFAULT 'Non renseignée'",
          );
        }
      },
    );
  }

  Future<Database> get _db async {
    if (_database == null) {
      await init();
    }
    return _database!;
  }

  @override
  Future<List<CartItem>> loadCart(int userId) async {
    final db = await _db;

    final rows = await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'title ASC',
    );

    return rows.map((row) {
      return CartItem(
        productId: row['product_id'] as int,
        title: row['title'] as String,
        price: (row['price'] as num).toDouble(),
        image: row['image'] as String? ?? '',
        categoryName: row['category_name'] as String? ?? 'Non renseignée',
        quantity: row['quantity'] as int,
      );
    }).toList();
  }

  @override
  Future<void> saveCart(int userId, List<CartItem> items) async {
    final db = await _db;

    await db.transaction((txn) async {
      await txn.delete(
        'cart_items',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      for (final item in items) {
        await txn.insert(
          'cart_items',
          {
            'user_id': userId,
            'product_id': item.productId,
            'title': item.title,
            'price': item.price,
            'image': item.image,
            'category_name': item.categoryName,
            'quantity': item.quantity,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<void> clearCart(int userId) async {
    final db = await _db;

    await db.delete(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
