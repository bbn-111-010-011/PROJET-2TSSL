/// Repository SQLite du projet.
///
/// Il crée et manipule les tables locales utilisées pour le panier et
/// l'historique des achats.

import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../models/cart_item.dart';
import '../models/order.dart';

/// Persistance SQLite locale du projet.
///
/// Même logique que le TD6 : les données structurées et liées à un utilisateur
/// sont stockées en base locale. Ici, SQLite est utilisé pour le panier et
/// l'historique des commandes.
class DatabaseStorage {
  DatabaseStorage({this.databasePath});

  final String? databasePath;
  Database? _db;

  Future<void> init() async {
    _db ??= await _openDatabase();
  }

  Future<Database> get _database async {
    if (_db == null) {
      await init();
    }
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final path = databasePath ?? '${await getDatabasesPath()}/projet_2tssl.db';
    return openDatabase(
      path,
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

        await db.execute('''
          CREATE TABLE orders (
            id TEXT PRIMARY KEY,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            data TEXT NOT NULL
          )
        ''');

        await db.execute('CREATE INDEX idx_orders_user_date ON orders(user_id, date DESC)');
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

  // Panier : données structurées, modifiables, liées à un utilisateur.
  Future<List<CartItem>> loadCart(int userId) async {
    final db = await _database;
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

  Future<void> saveCart(int userId, List<CartItem> items) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
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

  // Historique : liste de commandes avec date, total et détails.
  Future<List<Order>> loadOrders(int userId) async {
    final db = await _database;
    final rows = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return rows.map((row) {
      final decoded = jsonDecode(row['data'] as String) as Map<String, dynamic>;
      return Order.fromJson(decoded);
    }).toList();
  }

  Future<void> saveOrders(int userId, List<Order> orders) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('orders', where: 'user_id = ?', whereArgs: [userId]);
      for (final order in orders) {
        await txn.insert(
          'orders',
          {
            'id': order.id,
            'user_id': userId,
            'date': order.date.toIso8601String(),
            'data': jsonEncode(order.toJson()),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
