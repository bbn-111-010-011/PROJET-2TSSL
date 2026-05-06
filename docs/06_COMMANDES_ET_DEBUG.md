# 06 — Commandes et debug

## Installer les dépendances

```bash
flutter pub get
```

## Nettoyer le projet

```bash
flutter clean
```

## Lancer sur Windows

```bash
flutter run -d windows
```

## Voir les appareils disponibles

```bash
flutter devices
```

## Analyser le code

```bash
flutter analyze
```

## Lancer les tests

```bash
flutter test
```

## Problème Visual Studio Windows

Si Flutter affiche :

```text
Generator Visual Studio 16 2019 could not find any instance of Visual Studio
```

Ce n’est pas une erreur du code. Il faut installer Visual Studio avec le composant C++ desktop.

## Problème écran blanc Chrome / Edge

La version avec `sqflite` est prévue pour Windows desktop.

Chrome / Edge utilisent Flutter Web, qui ne supporte pas directement cette configuration SQLite desktop.

Utiliser :

```bash
flutter run -d windows
```

## Problème images qui ne correspondent pas

L’API utilisée est une API fake. Certaines images peuvent ne pas correspondre aux titres.

Le catalogue local de secours utilise aussi des images génériques `picsum.photos`.
