import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ossea/app.dart';
import 'package:ossea/state/market_store.dart';

/// Long-form captures render the production widgets with their entire scroll
/// content visible; device viewport captures live in integration_test/.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('export full scroll content in both themes', (tester) async {
    final font = FontLoader('Urbanist')
      ..addFont(rootBundle.load('assets/fonts/Urbanist.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.devicePixelRatio = 1;
    for (final dark in [false, true]) {
      for (final id in [
        3,
        6,
        21,
        32,
        34,
        36,
        37,
        38,
        39,
        49,
        50,
        52,
        53,
        56,
        58,
        59,
        60,
        61,
        62,
        69,
        70,
      ]) {
        var height = 926.0;
        tester.view.physicalSize = Size(428, height);
        final key = GlobalKey();
        final store = MarketStore()..dark = dark;
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: OsseaApp(
              key: ValueKey('$dark-$id'),
              store: store,
              initialScreen: id,
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (var pass = 0; pass < 5; pass++) {
          final scrollable = find
              .descendant(
                of: find.byType(ListView).first,
                matching: find.byType(Scrollable),
              )
              .first;
          final extent = tester
              .state<ScrollableState>(scrollable)
              .position
              .maxScrollExtent;
          if (extent < 1) break;
          height = (height + extent + 2).clamp(926, 10000);
          tester.view.physicalSize = Size(428, height);
          await tester.pumpAndSettle();
        }
        final list = tester.renderObject<RenderSliver>(
          find.byType(SliverList).first,
        );
        final scroll = tester
            .state<ScrollableState>(
              find
                  .descendant(
                    of: find.byType(ListView).first,
                    matching: find.byType(Scrollable),
                  )
                  .first,
            )
            .position;
        final fitted =
            height -
            scroll.viewportDimension +
            list.geometry!.scrollExtent +
            38;
        if (fitted < height - 4) {
          tester.view.physicalSize = Size(428, fitted.clamp(926, 10000));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull, reason: 'long $id');
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'docs/screenshots/long/${dark ? 'dark' : 'light'}-${id.toString().padLeft(2, '0')}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  }, timeout: const Timeout(Duration(minutes: 10)));
}
