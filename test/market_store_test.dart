import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ossea/data/market_repository.dart';
import 'package:ossea/state/market_store.dart';

void main() {
  test('purchase is idempotent and reduces the demo balance once', () {
    final s = MarketStore();
    expect(s.buy(MarketRepository.featured), isTrue);
    expect(s.buy(MarketRepository.featured), isFalse);
    expect(s.balance, closeTo(198.97789, .00001));
  });
  test('marketplace activity and preferences survive reload', () async {
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    final s = MarketStore(preferences: p);
    s.connect('Metamask');
    s.toggleDark();
    s.toggleFavorite('9167');
    s.toggleWatch('Dose of Art');
    s.setLanguage('Mandarin');
    s.setSetting('Sound', false);
    s.makeOffer('9167', 12.5);
    s.buy(MarketRepository.featured);
    s.addItem(MarketRepository.cats.first);
    s.addCollection('Test Collection');
    s.listItem('cat-0');
    final loaded = MarketStore(preferences: p);
    expect(loaded.connected, isTrue);
    expect(loaded.dark, isTrue);
    expect(loaded.language, 'Mandarin');
    expect(loaded.favorites, contains('9167'));
    expect(loaded.watchlist, contains('Dose of Art'));
    expect(loaded.offers['9167'], 12.5);
    expect(loaded.purchased, contains('9167'));
    expect(loaded.created.single.name, MarketRepository.cats.first.name);
    expect(loaded.createdCollections.single.name, 'Test Collection');
    expect(loaded.listed, contains('cat-0'));
    expect(loaded.settings['Sound'], isFalse);
  });
}
