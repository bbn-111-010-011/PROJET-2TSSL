/// Écran catalogue produits.
///
/// Il affiche la liste des articles, la recherche, les filtres et l'accès aux
/// détails produits.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/product_provider.dart';
import '../../../ui/widgets/product_tile.dart';
import '../../../models/product.dart';
import '../../../models/category.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = context.read<ProductProvider>();
    if (p.products.isEmpty) {
      // First load already triggered in main, but safe to ensure
      p.refresh();
    }
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final p = context.read<ProductProvider>();
    if (!p.hasMore || p.loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      p.loadMore();
    }
  }

  Future<void> _refresh() async {
    await context.read<ProductProvider>().refresh();
  }

  void _openFilters() async {
    final provider = context.read<ProductProvider>();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final categories = context.watch<ProductProvider>().categories;
        int? selectedCat = provider.categoryId;
        final priceMinCtrl =
            TextEditingController(text: provider.priceMin?.toString() ?? '');
        final priceMaxCtrl =
            TextEditingController(text: provider.priceMax?.toString() ?? '');

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: selectedCat,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<int?>>[
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Toutes'),
                  ),
                  ...categories.map<DropdownMenuItem<int?>>(
                    (Category c) => DropdownMenuItem<int?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (int? v) {
                  selectedCat = v;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceMinCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix min',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceMaxCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prix max',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        provider.clearFilters();
                        Navigator.of(ctx).pop();
                        provider.refresh();
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final min = int.tryParse(priceMinCtrl.text.trim());
                        final max = int.tryParse(priceMaxCtrl.text.trim());
                        provider.applyFilters(
                          categoryId: selectedCat,
                          priceMin: min,
                          priceMax: max,
                          search: provider.search,
                        );
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _onSearchSubmitted(String value) {
    context.read<ProductProvider>().applyFilters(search: value.trim());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Product p) {
    context.go('/product/${p.id}');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: () => context.read<ProductProvider>().refresh(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Favoris',
            onPressed: () => context.go('/favorites'),
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            tooltip: 'Panier',
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
          IconButton(
            tooltip: 'Profil',
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Filtres',
            onPressed: _openFilters,
            icon: const Icon(Icons.tune),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'quit') SystemNavigator.pop();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'quit', child: Text('Quitter')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: _onSearchSubmitted,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Rechercher un article...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: provider.search.isNotEmpty
                    ? IconButton(
                        tooltip: 'Effacer',
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().applyFilters(search: '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (provider.error != null && products.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: MaterialBanner(
                    content: const Text(
                      'API indisponible : catalogue local de secours affiché.',
                    ),
                    leading: const Icon(Icons.wifi_off),
                    actions: [
                      TextButton(
                        onPressed: () => context.read<ProductProvider>().refresh(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            if (provider.loading && products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.error != null && products.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 40),
                        const SizedBox(height: 12),
                        const Text(
                          'Impossible de charger les articles.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.read<ProductProvider>().refresh(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (products.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Aucun article trouvé')),
              )
            else
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final crossAxisCount = width >= 1150
                      ? 4
                      : width >= 820
                          ? 3
                          : width >= 520
                              ? 2
                              : 1;

                  return SliverPadding(
                    padding: const EdgeInsets.all(12),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final p = products[index];
                          return ProductTile(
                            product: p,
                            onTap: () => _openDetail(p),
                          );
                        },
                        childCount: products.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 330,
                      ),
                    ),
                  );
                },
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: provider.loading && products.isNotEmpty
                      ? const CircularProgressIndicator()
                      : (!provider.hasMore
                          ? const Text('Fin des résultats')
                          : const SizedBox.shrink()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
