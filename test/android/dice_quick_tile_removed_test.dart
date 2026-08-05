import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DiceQuickTileService and its shared base class are gone', () {
    expect(
      File(
        'android/app/src/main/java/com/hugo/theuniversedecides/DiceQuickTileService.java',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        'android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java',
      ).existsSync(),
      isFalse,
    );
    expect(
      File(
        'android/app/src/main/res/drawable/ic_quick_tile_dice.xml',
      ).existsSync(),
      isFalse,
    );
  });

  test('manifest and native resources drop every dice quick tile reference', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final strings = File(
      'android/app/src/main/res/values/strings.xml',
    ).readAsStringSync();
    final contract = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickAccessContract.java',
    ).readAsStringSync();
    final mainActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/MainActivity.java',
    ).readAsStringSync();

    expect(manifest, isNot(contains('DiceQuickTileService')));
    expect(manifest, isNot(contains('quick_tile_dice_label')));
    expect(manifest, isNot(contains('ic_quick_tile_dice')));
    expect(strings, isNot(contains('quick_tile_dice_label')));
    expect(contract, isNot(contains('ACTION_DICE')));
    expect(contract, contains('ACTION_COIN'));
    expect(mainActivity, isNot(contains('DiceQuickTileService')));
    expect(mainActivity, isNot(contains('ACTION_DICE')));
  });

  test('no localized strings.xml variant keeps a stale dice translation', () {
    // Android lint's ExtraTranslation check fails the release build if a
    // localized strings.xml defines a key the default values/strings.xml no
    // longer has - this caught quick_tile_dice_label surviving in
    // values-pt-rBR after the default definition was removed.
    final resFiles = Directory(
      'android/app/src/main/res',
    ).listSync(recursive: true).whereType<File>().where(
      (file) => file.path.endsWith('strings.xml'),
    );

    for (final file in resFiles) {
      expect(
        file.readAsStringSync(),
        isNot(contains('quick_tile_dice_label')),
        reason: '${file.path} should no longer define quick_tile_dice_label',
      );
    }
  });

  test('coin quick tile service still declares its Quick Settings entry', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:name=".CoinQuickTileService"'));
    expect(manifest, contains('quick_tile_coin_label'));
  });

  test('Dart quick access API no longer exposes a dice action', () {
    final quickAccessService = File(
      'lib/services/quick_access_service.dart',
    ).readAsStringSync();
    final mainScreen = File('lib/screens/main_screen.dart').readAsStringSync();
    final aboutMeScreen = File(
      'lib/screens/about_me_screen.dart',
    ).readAsStringSync();
    final diceRollScreen = File(
      'lib/screens/dice_roll_screen.dart',
    ).readAsStringSync();

    expect(quickAccessService, isNot(contains('dice')));
    expect(quickAccessService, isNot(contains('Dice')));
    expect(mainScreen, isNot(contains('QuickAccessAction.dice')));
    expect(aboutMeScreen, isNot(contains('QuickAccessAction.dice')));
    expect(aboutMeScreen, isNot(contains('aboutAddDiceButton')));
    expect(diceRollScreen, isNot(contains('diceQuickAccessTriggerProvider')));
  });

  test('the regular in-app dice screen and nav tab still exist', () {
    expect(File('lib/screens/dice_roll_screen.dart').existsSync(), isTrue);
    final mainScreen = File('lib/screens/main_screen.dart').readAsStringSync();
    expect(mainScreen, contains('DiceRollScreen()'));
    expect(mainScreen, contains("id: 'dice'"));
  });

  test('dice quick-tile ARB strings are removed from every supported locale', () {
    const locales = ['de', 'en', 'es', 'fr', 'hi', 'it', 'pt', 'tr', 'uk'];
    const removedKeys = [
      'aboutAddDiceButton',
      'quickTileDiceAdded',
      'quickTileDiceAlreadyAdded',
      'quickTileDiceCancelled',
      'quickTileDiceUnsupported',
    ];

    for (final locale in locales) {
      final arb = File('lib/l10n/app_$locale.arb').readAsStringSync();
      for (final key in removedKeys) {
        expect(
          arb,
          isNot(contains('"$key"')),
          reason: 'lib/l10n/app_$locale.arb should no longer define $key',
        );
      }
      expect(
        arb,
        contains('"aboutAddCoinButton"'),
        reason: 'lib/l10n/app_$locale.arb must keep the coin shortcut string',
      );
    }
  });
}
