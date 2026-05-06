import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient;

import 'core/app_config.dart';
import 'core/sqlite_setup.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'repositories/local_storage.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cart_storage.dart';
import 'services/order_service.dart';

import 'providers/onboarding_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/orders_provider.dart';

import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupSqfliteFactory();

  // SharedPreferences : token, profil, onboarding et favoris.
  final storage = LocalStorage();
  await storage.init();

  // sqflite : panier.
  // createCartStorage() renvoie SqfliteCartStorage sur Windows / mobile,
  // et MemoryCartStorage sur le web pour éviter les écrans blancs.
  CartStorage cartStorage = createCartStorage();
  try {
    await cartStorage.init();
  } catch (e) {
    debugPrint('SQLite indisponible, passage en stockage mémoire : $e');
    cartStorage = MemoryCartStorage();
    await cartStorage.init();
  }

  // Supabase : historique des achats.
  // En cas de mauvaise configuration, l'app démarre quand même et affiche
  // une erreur lisible sur l'écran Historique.
  SupabaseClient? supabaseClient;
  if (AppConfig.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        anonKey: AppConfig.supabaseAnonKey,
      );
      supabaseClient = Supabase.instance.client;
    } catch (e) {
      debugPrint('Supabase non initialisé : $e');
    }
  }

  // ApiClient that reads token from storage for auth requests
  final apiClient = ApiClient(
    tokenProvider: () async => storage.getToken(),
  );

  // Services
  final authService = AuthService(apiClient);
  final productService = ProductService(apiClient);

  // Repositories
  final authRepo = AuthRepository(storage: storage, service: authService);

  // Providers (created here and injected below)
  final onboardingSeen = storage.getOnboardingSeen();
  final onboardingProvider = OnboardingProvider(storage, initiallySeen: onboardingSeen);

  final authProvider = AuthProvider(authRepo, apiClient);
  await authProvider.hydrate();

  final productProvider = ProductProvider(productService);
  // Preload categories asynchronously (non-blocking)
  productProvider.loadCategories();
  // Initial load products
  productProvider.refresh();

  final favoritesProvider = FavoritesProvider(storage);
  await favoritesProvider.hydrate();

  final cartProvider = CartProvider(cartStorage, authProvider);
  await cartProvider.hydrate();

  final orderService = SupabaseOrderService(client: supabaseClient);
  final ordersProvider = OrdersProvider(orderService, authProvider);
  await ordersProvider.hydrate();

  // Router setup with live guards
  final notifier = RouterNotifier(onboardingProvider, authProvider);
  final router = AppRouter(
    notifier: notifier,
  ).router;

  runApp(MyApp(
    router: router,
    storage: storage,
    onboardingProvider: onboardingProvider,
    authProvider: authProvider,
    productProvider: productProvider,
    favoritesProvider: favoritesProvider,
    cartProvider: cartProvider,
    ordersProvider: ordersProvider,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.router,
    required this.storage,
    required this.onboardingProvider,
    required this.authProvider,
    required this.productProvider,
    required this.favoritesProvider,
    required this.cartProvider,
    required this.ordersProvider,
  });

  final GoRouter router;
  final LocalStorage storage;

  final OnboardingProvider onboardingProvider;
  final AuthProvider authProvider;
  final ProductProvider productProvider;
  final FavoritesProvider favoritesProvider;
  final CartProvider cartProvider;
  final OrdersProvider ordersProvider;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OnboardingProvider>.value(value: onboardingProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<ProductProvider>.value(value: productProvider),
        ChangeNotifierProvider<FavoritesProvider>.value(value: favoritesProvider),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        ChangeNotifierProvider<OrdersProvider>.value(value: ordersProvider),
      ],
      child: MaterialApp.router(
        title: 'PROJET 2TSSL',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
