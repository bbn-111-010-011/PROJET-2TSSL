import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_projet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('L application démarre sans erreur bloquante', (tester) async {
    await app.main();
    await tester.pump(const Duration(seconds: 2));

    // Objectif du test d'intégration : vérifier que le projet démarre
    // et qu'aucune exception Flutter ne bloque le premier affichage.
    expect(tester.takeException(), isNull);
  });
}
