import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles the dice renderer and every script it loads', () async {
    // index.html loads three/cannon/teal from libs/ before dice.js and
    // bridge.js. A Flutter `assets/dice/` directory entry is NOT recursive,
    // so libs/ must be declared explicitly or the WebView 404s the engine
    // and the roll times out.
    const assets = [
      'assets/dice/index.html',
      'assets/dice/bridge.js',
      'assets/dice/dice.js',
      'assets/dice/libs/three.min.js',
      'assets/dice/libs/cannon.min.js',
      'assets/dice/libs/teal.js',
    ];

    for (final asset in assets) {
      final contents = await rootBundle.loadString(asset);
      expect(contents, isNotEmpty, reason: '$asset should be bundled');
    }
  });
}
