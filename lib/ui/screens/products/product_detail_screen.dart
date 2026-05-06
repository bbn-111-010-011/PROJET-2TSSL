/// Écran détail produit.
///
/// Il affiche les informations complètes d'un produit et propose les actions
/// favoris et ajout au panier.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../providers/product_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});
  final int productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await context.read<ProductProvider>().fetchProductById(widget.productId);
    if (!mounted) return;
    setState(() {
      _product = p;
      _loading = false;
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _toggleFavorite() {
    if (_product == null) return;
    context.read<FavoritesProvider>().toggle(_product!);
  }

  Future<void> _addToCart() async {
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
    if (_product == null) return;
    try {
      await context.read<CartProvider>().addProduct(_product!);
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

  Widget _image(Product p, {required bool wide}) {
    final height = wide ? 320.0 : 230.0;
    if (p.images.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 56)),
      );
    }

    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: p.images.length,
        itemBuilder: (_, i) {
          final img = p.images[i];
          return CachedNetworkImage(
            imageUrl: img,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
            errorWidget: (_, __, ___) => const ColoredBox(
              color: Color(0xFFE0E0E0),
              child: Icon(Icons.broken_image),
            ),
          );
        },
      ),
    );
  }

  Widget _details(Product p, bool isFav) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text('${p.price.toStringAsFixed(2)} €'),
                avatar: const Icon(Icons.sell, size: 18),
              ),
              if (p.category != null)
                Chip(
                  label: Text(p.category!.name),
                  avatar: const Icon(Icons.category, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            p.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Ajouter au panier'),
              ),
              OutlinedButton.icon(
                onPressed: _toggleFavorite,
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
                label: Text(isFav ? 'Retirer des favoris' : 'Ajouter aux favoris'),
              ),
              TextButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.store),
                label: const Text('Retour aux produits'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Retour',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final p = _product;
    if (p == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Retour',
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text('Article introuvable'),
        ),
        body: Center(
          child: FilledButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.store),
            label: const Text('Retour aux produits'),
          ),
        ),
      );
    }

    final isFav = context.select<FavoritesProvider, bool>((fp) => fp.isFavorite(p.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Produits',
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.store),
          ),
          IconButton(
            tooltip: isFav ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _toggleFavorite,
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
          ),
          IconButton(
            tooltip: 'Panier',
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_cart),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  context.go('/profile');
                  break;
                case 'quit':
                  SystemNavigator.pop();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'profile', child: Text('Profil')),
              PopupMenuItem(value: 'quit', child: Text('Quitter')),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 850;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _image(p, wide: true)),
                              Expanded(child: _details(p, isFav)),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _image(p, wide: false),
                              _details(p, isFav),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Produits'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Ajouter au panier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
