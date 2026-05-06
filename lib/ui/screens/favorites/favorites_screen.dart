/// Écran favoris.
///
/// Il affiche les produits favoris sauvegardés localement avec
/// SharedPreferences.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/favorites_provider.dart';
import '../../widgets/product_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>().favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoris'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('Aucun favori'))
          : LayoutBuilder(
              builder: (context, constraints) {
                final calculatedColumns = (constraints.maxWidth / 290).floor();
                final crossAxisCount = calculatedColumns.clamp(1, 5).toInt();

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: favorites.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 315,
                  ),
                  itemBuilder: (context, index) {
                    final product = favorites[index];
                    return ProductTile(
                      product: product,
                      onTap: () => context.go('/product/${product.id}'),
                    );
                  },
                );
              },
            ),
    );
  }
}
