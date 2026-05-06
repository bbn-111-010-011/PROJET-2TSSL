/// Repository SharedPreferences du projet.
///
/// Il sauvegarde les petites données locales : onboarding, token, utilisateur
/// et favoris.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../models/product.dart';

class LocalStorage {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError('LocalStorage not initialized. Call init() first.');
    }
    return p;
  }

  // Onboarding
  Future<void> setOnboardingSeen(bool seen) async {
    await _p.setBool(Constants.spOnboardingSeen, seen);
  }

  bool getOnboardingSeen() {
    return _p.getBool(Constants.spOnboardingSeen) ?? false;
  }

  // Auth token
  Future<void> setToken(String? token) async {
    if (token == null || token.isEmpty) {
      await _p.remove(Constants.spToken);
    } else {
      await _p.setString(Constants.spToken, token);
    }
  }

  String? getToken() {
    return _p.getString(Constants.spToken);
  }

  // User profile
  Future<void> setUser(AppUser? user) async {
    if (user == null) {
      await _p.remove(Constants.spUser);
    } else {
      await _p.setString(Constants.spUser, jsonEncode(user.toJson()));
    }
  }

  AppUser? getUser() {
    final s = _p.getString(Constants.spUser);
    if (s == null) return null;
    try {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return AppUser.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  // Favorites (global, not per-user)
  // Même principe que le TD6 : on persiste les objets complets en JSON,
  // pas uniquement les identifiants. Cela rend l'écran Favoris autonome.
  Future<void> saveFavorites(List<Product> favorites) async {
    final data = favorites.map((e) => e.toJson()).toList();
    await _p.setString(Constants.spFavorites, jsonEncode(data));
  }

  List<Product> loadFavorites() {
    final s = _p.getString(Constants.spFavorites);
    if (s == null) return const [];
    try {
      final decoded = jsonDecode(s) as List;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

}
