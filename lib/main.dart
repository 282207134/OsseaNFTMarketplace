import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'state/market_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    OsseaApp(
      store: MarketStore(preferences: await SharedPreferences.getInstance()),
    ),
  );
}
