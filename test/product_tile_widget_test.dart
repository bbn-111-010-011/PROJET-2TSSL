import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_projet/models/product.dart';
import 'package:flutter_projet/providers/auth_provider.dart';
import 'package:flutter_projet/providers/cart_provider.dart';
import 'package:flutter_projet/providers/favorites_provider.dart';
import 'package:flutter_projet/repositories/auth_repository.dart';
import 'package:flutter_projet/repositories/cart_storage.dart';
import 'package:flutter_projet/repositories/local_storage.dart';
import 'package:flutter_projet/services/api_client.dart';
import 'package:flutter_projet/services/auth_service.dart';
import 'package:flutter_projet/ui/widgets/product_tile.dart';

void main() {
  testWidgets('ProductTile affiche le produit, le prix et les actions principales', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final storage = LocalStorage();
    await storage.init();

    final api = ApiClient(tokenProvider: () async => null);
    final auth = AuthProvider(
      AuthRepository(storage: storage, service: AuthService(api)),
      api,
    );
    final favorites = FavoritesProvider(storage);
    final cartStorage = MemoryCartStorage();
    await cartStorage.init();
    final cart = CartProvider(cartStorage, auth);

    final product = Product(
      id: 1,
      title: 'Sac de test',
      description: 'Produit utilisé pour le test widget.',
      price: 25.0,
      images: const [],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<FavoritesProvider>.value(value: favorites),
          ChangeNotifierProvider<CartProvider>.value(value: cart),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 360,
              width: 260,
              child: ProductTile(product: product),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sac de test'), findsOneWidget);
    expect(find.text('25.00 €'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
  });
}
