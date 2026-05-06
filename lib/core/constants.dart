/// Constantes globales du projet.
///
/// Ce fichier centralise l'URL de l'API et les clés utilisées par
/// SharedPreferences afin d'éviter les chaînes écrites en dur dans le code.

class Constants {
  // API base (Platzi Fake Store)
  static const String apiBaseUrl = 'https://api.escuelajs.co/api/v1';

  // SharedPreferences keys
  static const String spOnboardingSeen = 'onboarding_seen';
  static const String spToken = 'auth_token';
  static const String spUser = 'auth_user';
  static const String spFavorites = 'favorites';
  static const String spCart = 'cart';
  static const String spOrders = 'orders';
}
