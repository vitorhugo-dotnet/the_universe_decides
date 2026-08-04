import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:theuniversedecides/main.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';

void main() {
  testWidgets('quick coin route renders the compact autostart screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: UniverseDecidesApp(initialRoute: UniverseRoutes.quickCoin),
      ),
    );
    await tester.pump();

    final coinScreen = tester.widget<CoinFlipScreen>(
      find.byType(CoinFlipScreen),
    );
    expect(coinScreen.quickMode, isTrue);
    expect(coinScreen.autoStart, isTrue);
    expect(coinScreen.autoClose, isTrue);
  });

  test('quick coin screen guards automatic launch and close scheduling', () {
    final source = File('lib/screens/coin_flip_screen.dart').readAsStringSync();

    expect(source, contains('bool _autoStartQueued = false;'));
    expect(source, contains('if (_autoStartQueued)'));
    expect(source, contains('_autoStartQueued = true;'));
    expect(source, contains('bool _autoCloseQueued = false;'));
    expect(source, contains('if (!widget.autoClose || _autoCloseQueued)'));
    expect(source, contains('_autoCloseQueued = true;'));
    expect(source, contains('SystemNavigator.pop()'));
    expect(source, contains('onTap: widget.quickMode'));
  });
}
