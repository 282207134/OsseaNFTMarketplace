import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/market_repository.dart';

class MarketStore extends ChangeNotifier {
  final SharedPreferences? preferences;
  bool dark, connected, onboarded;
  String language;
  String walletProvider;
  final Set<String> favorites, watchlist, purchased;
  final Map<String, bool> settings;
  final List<NftItem> created = [];
  final List<CollectionItem> createdCollections = [];
  final Map<String, double> offers = {};
  final Map<String, double> listingPrices = {};
  final Set<String> listed = {};
  MarketStore({this.preferences})
    : dark = preferences?.getBool('dark') ?? false,
      connected = preferences?.getBool('connected') ?? false,
      onboarded = preferences?.getBool('onboarded') ?? false,
      language = preferences?.getString('language') ?? 'English (US)',
      walletProvider = preferences?.getString('walletProvider') ?? 'Metamask',
      favorites = (preferences?.getStringList('favorites') ?? []).toSet(),
      watchlist = (preferences?.getStringList('watchlist') ?? []).toSet(),
      purchased = (preferences?.getStringList('purchased') ?? []).toSet(),
      settings = Map<String, bool>.from(
        jsonDecode(preferences?.getString('settings') ?? '{}'),
      ) {
    for (final raw in preferences?.getStringList('created') ?? <String>[]) {
      final n = jsonDecode(raw) as Map<String, dynamic>;
      created.add(
        NftItem(
          id: n['id'],
          name: n['name'],
          collection: n['collection'],
          image: n['image'],
          price: (n['price'] as num).toDouble(),
        ),
      );
    }
    for (final raw in preferences?.getStringList('collections') ?? <String>[]) {
      final n = jsonDecode(raw) as Map<String, dynamic>;
      createdCollections.add(
        CollectionItem(n['name'], n['image'], n['avatar']),
      );
    }
    offers.addAll(
      Map<String, double>.from(
        jsonDecode(preferences?.getString('offers') ?? '{}'),
      ),
    );
    listed.addAll(preferences?.getStringList('listed') ?? []);
    listingPrices.addAll(
      Map<String, double>.from(
        jsonDecode(preferences?.getString('listingPrices') ?? '{}'),
      ),
    );
  }
  void toggleDark([bool? value]) {
    dark = value ?? !dark;
    save();
  }

  void connect(String provider) {
    walletProvider = provider;
    connected = true;
    onboarded = true;
    save();
  }

  void logout() {
    connected = false;
    save();
  }

  void finishOnboarding() {
    onboarded = true;
    save();
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    save();
  }

  void toggleWatch(String id) {
    watchlist.contains(id) ? watchlist.remove(id) : watchlist.add(id);
    save();
  }

  void setLanguage(String value) {
    language = value;
    save();
  }

  void setSetting(String key, bool value) {
    settings[key] = value;
    save();
  }

  void makeOffer(String id, double amount) {
    offers[id] = amount;
    save();
  }

  bool buy(NftItem item) {
    if (purchased.contains(item.id) || item.price > balance) return false;
    purchased.add(item.id);
    save();
    return true;
  }

  void addItem(NftItem item) {
    created.add(item);
    save();
  }

  void addCollection(String name) {
    createdCollections.add(CollectionItem(name, 'collection-0', 'avatar-0'));
    save();
  }

  void listItem(String id, [double? price]) {
    listed.add(id);
    if (price != null) {
      listingPrices[id] = price;
    }
    save();
  }

  List<NftItem> get allItems => [
    MarketRepository.featured,
    ...MarketRepository.cats,
    ...created,
  ];
  List<NftItem> get ownedItems =>
      allItems.where((n) => purchased.contains(n.id)).toList();
  double get balance =>
      324.67539 - ownedItems.fold(0.0, (total, n) => total + n.price);
  void save() {
    preferences?.setBool('dark', dark);
    preferences?.setBool('connected', connected);
    preferences?.setBool('onboarded', onboarded);
    preferences?.setString('language', language);
    preferences?.setString('walletProvider', walletProvider);
    preferences?.setStringList('favorites', favorites.toList());
    preferences?.setStringList('watchlist', watchlist.toList());
    preferences?.setStringList('purchased', purchased.toList());
    preferences?.setString('settings', jsonEncode(settings));
    preferences?.setString('offers', jsonEncode(offers));
    preferences?.setString('listingPrices', jsonEncode(listingPrices));
    preferences?.setStringList('listed', listed.toList());
    preferences?.setStringList(
      'created',
      created
          .map(
            (n) => jsonEncode({
              'id': n.id,
              'name': n.name,
              'collection': n.collection,
              'image': n.image,
              'price': n.price,
            }),
          )
          .toList(),
    );
    preferences?.setStringList(
      'collections',
      createdCollections
          .map(
            (n) => jsonEncode({
              'name': n.name,
              'image': n.image,
              'avatar': n.avatar,
            }),
          )
          .toList(),
    );
    notifyListeners();
  }
}

class StoreScope extends InheritedNotifier<MarketStore> {
  const StoreScope({
    super.key,
    required MarketStore store,
    required super.child,
  }) : super(notifier: store);
  static MarketStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
