import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/screen_host.dart';
import 'state/market_store.dart';

class OsseaApp extends StatelessWidget {
  final MarketStore store;
  final int? initialScreen;
  final GlobalKey<NavigatorState>? navigatorKey;
  const OsseaApp({
    super.key,
    required this.store,
    this.initialScreen,
    this.navigatorKey,
  });
  @override
  Widget build(BuildContext context) => StoreScope(
    store: store,
    child: ListenableBuilder(
      listenable: store,
      builder: (_, child) => MaterialApp(
        title: 'Ossea',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        theme: osseaTheme(false),
        darkTheme: osseaTheme(true),
        themeMode: store.dark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: '/screen/${initialScreen ?? (store.onboarded ? 7 : 2)}',
        onGenerateInitialRoutes: (route) => [
          MaterialPageRoute(
            builder: (_) =>
                ScreenHost(id: int.tryParse(route.split('/').last) ?? 7),
            settings: RouteSettings(name: route),
          ),
        ],
        onGenerateRoute: (settings) {
          final id = int.tryParse((settings.name ?? '').split('/').last) ?? 7;
          return MaterialPageRoute(
            builder: (_) =>
                ScreenHost(id: id.clamp(1, 81), argument: settings.arguments),
            settings: settings,
          );
        },
      ),
    ),
  );
}
