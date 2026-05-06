import 'cart_storage_interface.dart';

/// Crée le stockage panier adapté à la cible web : mémoire de secours.
/// Le vrai sqflite est conservé sur Windows / Android / iOS.
CartStorage createCartStorage() => MemoryCartStorage();
