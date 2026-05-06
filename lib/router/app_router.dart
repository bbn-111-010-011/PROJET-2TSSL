/// Configuration de la navigation de l'application.
///
/// Ce fichier définit les routes, les redirections d'authentification et la
/// navigation principale desktop/mobile.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../providers/onboarding_provider.dart';
import '../providers/auth_provider.dart';

import '../ui/screens/onboarding_screen.dart';
import '../ui/screens/products/products_screen.dart';
import '../ui/screens/favorites/favorites_screen.dart';
import '../ui/screens/cart/cart_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/orders/orders_screen.dart';
import '../ui/screens/products/product_detail_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import '../ui/screens/product_form/new_product_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.onboarding, this.auth) {
    onboarding.addListener(_notify);
    auth.addListener(_notify);
  }

  final OnboardingProvider onboarding;
  final AuthProvider auth;

  bool get onboardingSeen => onboarding.seen;
  bool get isAuthenticated => auth.isAuthenticated;

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.uri.path;

    if (!onboardingSeen && loc != '/onboarding') {
      return '/onboarding';
    }

    const authOnly = <String>{
      '/cart',
      '/orders',
      '/new-product',
    };
    if (!isAuthenticated && authOnly.contains(loc)) {
      return '/login';
    }

    return null;
  }

  void _notify() => notifyListeners();

  @override
  void dispose() {
    onboarding.removeListener(_notify);
    auth.removeListener(_notify);
    super.dispose();
  }
}

class AppRouter {
  AppRouter({required RouterNotifier notifier}) {
    _router = GoRouter(
      initialLocation: notifier.onboardingSeen ? '/home' : '/onboarding',
      refreshListenable: notifier,
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => _HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const ProductsScreen(),
            ),
            GoRoute(
              path: '/product/:id',
              name: 'product',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
                return ProductDetailScreen(productId: id);
              },
            ),
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
            GoRoute(
              path: '/cart',
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
            GoRoute(
              path: '/orders',
              name: 'orders',
              builder: (context, state) => const OrdersScreen(),
            ),
            GoRoute(
              path: '/new-product',
              name: 'new-product',
              builder: (context, state) => const NewProductScreen(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
      redirect: notifier.redirect,
    );
  }

  late final GoRouter _router;
  GoRouter get router => _router;
}

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.child});
  final Widget child;

  int _currentIndexForLocation(BuildContext context) {
    final loc = GoRouterState.of(context).uri.path;
    if (loc.startsWith('/favorites')) return 1;
    if (loc.startsWith('/cart')) return 2;
    if (loc.startsWith('/profile') || loc.startsWith('/orders') || loc.startsWith('/new-product')) {
      return 3;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/favorites');
        break;
      case 2:
        context.go('/cart');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  void _quitApp() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndexForLocation(context);
    final width = MediaQuery.of(context).size.width;

    if (width >= 950) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: idx,
              onDestinationSelected: (i) => _onTap(context, i),
              labelType: NavigationRailLabelType.all,
              trailing: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: IconButton(
                  tooltip: 'Quitter',
                  onPressed: _quitApp,
                  icon: const Icon(Icons.exit_to_app),
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: Text('Produits')),
                NavigationRailDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: Text('Favoris')),
                NavigationRailDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: Text('Panier')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profil')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: 'Produits'),
          NavigationDestination(icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Panier'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
