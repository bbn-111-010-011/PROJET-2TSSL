/// Widget carte produit réutilisable.
///
/// Il affiche l'image, le titre, le prix, la catégorie et les boutons favoris
/// et panier.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  void _toggleFavorite(BuildContext context) {
    context.read<FavoritesProvider>().toggle(product);
  }

  Future<void> _addToCart(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connectez-vous pour ajouter au panier')),
        );
        context.go('/login');
      }
      return;
    }

    try {
      await context.read<CartProvider>().addProduct(product);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajouté au panier')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<FavoritesProvider, bool>(
      (p) => p.isFavorite(product.id),
    );

    final title = product.title.trim().isEmpty ? 'Article sans titre' : product.title.trim();
    final categoryName = product.category?.name.trim();
    final img = product.images.where((e) => e.trim().isNotEmpty).isNotEmpty
        ? product.images.firstWhere((e) => e.trim().isNotEmpty)
        : null;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 145,
              child: img == null
                  ? const _ProductImagePlaceholder()
                  : CachedNetworkImage(
                      imageUrl: img,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const _ProductImagePlaceholder(),
                      errorWidget: (_, __, ___) => const _ProductImagePlaceholder(),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} €',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (categoryName != null && categoryName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        IconButton(
                          tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _toggleFavorite(context),
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : null,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _addToCart(context),
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text('Ajouter'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, size: 42),
      ),
    );
  }
}
