import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ossea/app.dart';
import 'package:ossea/navigation/screen_catalog.dart';
import 'package:ossea/state/market_store.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture every Pixso screen in both themes', (tester) async {
    final navigator = GlobalKey<NavigatorState>();
    final store = MarketStore()..connect('Metamask');
    await tester.pumpWidget(
      OsseaApp(store: store, navigatorKey: navigator, initialScreen: 7),
    );
    await tester.pumpAndSettle();
    await binding.convertFlutterSurfaceToImage();
    await tester.pump();
    for (final dark in [false, true]) {
      store.toggleDark(dark);
      await tester.pumpAndSettle();
      for (final screen in screenCatalog) {
        navigator.currentState!.pushNamedAndRemoveUntil(
          '/screen/${screen.id}',
          (r) => false,
        );
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: screen.name);
        await binding.takeScreenshot(
          '${dark ? 'dark' : 'light'}/${screen.id.toString().padLeft(2, '0')}',
        );
      }
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}
