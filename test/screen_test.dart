import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ossea/app.dart';
import 'package:ossea/navigation/screen_catalog.dart';
import 'package:ossea/state/market_store.dart';

void main() {
  testWidgets(
    'created NFT identity and listing price survive the full listing flow',
    (tester) async {
      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MarketStore()..connect('Metamask');
      await tester.pumpWidget(OsseaApp(store: store, initialScreen: 50));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create').last);
      await tester.pumpAndSettle();
      expect(store.created, hasLength(1));
      final created = store.created.single;
      await tester.tap(find.text('Sell'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Complete Listing').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Listing'));
      await tester.pumpAndSettle();
      expect(find.text(created.name), findsOneWidget);
      expect(store.listingPrices[created.id], .075);
      expect(tester.takeException(), isNull);
    },
  );
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final loader = FontLoader('Urbanist')
      ..addFont(rootBundle.load('assets/fonts/Urbanist.ttf'));
    await loader.load();
  });
  for (final dark in [false, true]) {
    testWidgets(
      'all 81 ${dark ? 'dark' : 'light'} screens render without exceptions',
      (tester) async {
        tester.view.physicalSize = const Size(428, 926);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        for (final screen in screenCatalog) {
          final store = MarketStore()..dark = dark;
          await tester.pumpWidget(
            OsseaApp(
              key: ValueKey('${dark}_${screen.id}'),
              store: store,
              initialScreen: screen.id,
            ),
          );
          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.id}: ${screen.name}',
          );
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  }
  testWidgets('compact phone core pages render', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final id in [
      2,
      4,
      7,
      15,
      24,
      40,
      41,
      46,
      49,
      63,
      66,
      67,
      74,
      78,
      80,
    ]) {
      await tester.pumpWidget(
        OsseaApp(key: ValueKey(id), store: MarketStore(), initialScreen: id),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'compact $id');
    }
  });
  testWidgets('search responds to text and handles empty results', (
    tester,
  ) async {
    await tester.pumpWidget(OsseaApp(store: MarketStore(), initialScreen: 15));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'zzzz');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text('Not Found'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Zombie');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.text('3D Zombieya'), findsOneWidget);
  });
  testWidgets('offer validation and complete demo signature flow', (
    tester,
  ) async {
    final store = MarketStore()..connect('Metamask');
    await tester.pumpWidget(OsseaApp(store: store, initialScreen: 41));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('offer-amount')), '-1');
    await tester.tap(find.text('Make Offer'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter an amount between'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('offer-amount')), '12.5');
    await tester.tap(find.text('Make Offer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign'));
    await tester.pumpAndSettle();
    expect(store.offers['9167'], 12.5);
    expect(find.text('Congratulations!'), findsOneWidget);
  });
  testWidgets('purchase completes and appears in local portfolio', (
    tester,
  ) async {
    final store = MarketStore()..connect('Metamask');
    await tester.pumpWidget(OsseaApp(store: store, initialScreen: 46));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete Purchase').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign'));
    await tester.pumpAndSettle();
    expect(store.purchased, contains('9167'));
    expect(find.text('Congratulations!'), findsOneWidget);
  });
}
