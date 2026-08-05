# Quick Coin Lock-Screen & Silent Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let the Quick Settings coin tile launch `QuickCoinActivity` above the lock screen without unlocking, remove the dice Quick Settings tile (keeping the normal in-app dice screen), fix a regression that dropped `debugPaintBaselinesEnabled = false`, and make `QuickCoinActivity` completely silent without touching normal-mode sound behavior.

**Architecture:** This is a Flutter app (`lib/`) with a thin native Android layer (`android/app/src/main/java/com/hugo/theuniversedecides/`). `QuickCoinActivity` is a second `FlutterActivity` (transparent, `singleTop`, routed to `/quick-coin`) launched by `CoinQuickTileService` (a `TileService`). `CoinQuickTileService` currently extends a shared abstract `QuickActionTileService`, which `DiceQuickTileService` also extends; since the dice tile is being deleted, the shared class collapses into `CoinQuickTileService` directly. The `/quick-coin` Flutter route renders `CoinFlipScreen(quickMode: true, ...)`, which must skip the app's decision-sound service in quick mode. All Android- and manifest-level regressions are already covered by plain Dart `test()`/`testWidgets()` functions that read source/manifest files as strings (see `test/android/play_games_configuration_test.dart`) — this repo has no instrumented Android test harness, so all new Android coverage follows that same string-assertion pattern.

**Tech Stack:** Flutter 3.44 (Dart), Riverpod (`flutter_riverpod`), Android `TileService`/`FlutterActivity` (Java), `flutter gen-l10n` for ARB-based localization.

## Global Constraints

- Increment only `MAJOR.MINOR.PATCH` in `pubspec.yaml`'s `version:` line; never touch the `+<buildNumber>` suffix. This change adds features and fixes, so bump `MINOR` and reset `PATCH` to 0: `2.5.2+100147` → `2.6.0+100147`.
- `CHANGELOG.xml` must be fully replaced (never appended to) with only this change's release notes, covering exactly these locale tags in this order: `en-US`, `pt-BR`, `es-ES`, `de`, `fr-FR`, `hi`, `it`, `tr`, `uk`. Each block under 500 Unicode characters, bullets starting with `-`.
- Do not request `SYSTEM_ALERT_WINDOW` / "draw over other apps", do not call `unlockAndRun()`, do not add any new runtime permission, do not enable `turnScreenOn`.
- Do not remove `MainActivity`, the regular in-app dice screen (`DiceRollScreen`), or any intentional `TextDecoration.underline` usage (e.g. the "Privacy Policy" link in `about_me_screen.dart`).
- Run `flutter analyze` and `flutter test` before considering any task done; both must be clean/passing.
- Suggested branch: `feat/quick-coin-lockscreen-silent` — this session already has branch `claude/quick-coin-lockscreen-silent-obzgrj` checked out and up to date with `origin/master`; commit there instead of creating a second branch.

---

## Task 1: Restore `debugPaintBaselinesEnabled = false` and lock it in with a regression test

The yellow lines under text are Flutter's debug baseline paint overlay. Commit `2983949` originally added `import 'package:flutter/rendering.dart';` + `debugPaintBaselinesEnabled = false;` to `lib/main.dart` to fix this exact symptom, but commit `4cce8b7` ("Keep Quick Settings coin flip out of recent apps") silently dropped both lines while refactoring `main()`, and no test caught the regression. Nothing in the current tree sets any debug paint flag to `true` — the fix is simply restoring the explicit `false` assignment and adding a test that would catch this class of regression in the future.

**Files:**
- Modify: `lib/main.dart:1-18` (add import + explicit flag reset)
- Test: `test/debug_paint_regression_test.dart` (new)

**Interfaces:**
- Produces: no new public API; this only affects Flutter's internal debug rendering flags read via `package:flutter/rendering.dart`.

- [ ] **Step 1: Write the failing test**

Create `test/debug_paint_regression_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main.dart explicitly disables debug paint baselines on startup', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains("import 'package:flutter/rendering.dart';"));
    expect(mainSource, contains('debugPaintBaselinesEnabled = false;'));

    final ensureIndex = mainSource.indexOf(
      'WidgetsFlutterBinding.ensureInitialized();',
    );
    final baselineIndex = mainSource.indexOf(
      'debugPaintBaselinesEnabled = false;',
    );
    expect(ensureIndex, greaterThanOrEqualTo(0));
    expect(
      baselineIndex,
      greaterThan(ensureIndex),
      reason:
          'debugPaintBaselinesEnabled must be reset right after '
          'WidgetsFlutterBinding.ensureInitialized() so QuickCoinActivity '
          "never inherits a stale debug-paint flag from a previous run.",
    );
  });

  test('no application source enables a Flutter debug paint flag', () {
    const debugPaintFlags = [
      'debugPaintSizeEnabled',
      'debugPaintBaselinesEnabled',
      'debugPaintPointersEnabled',
      'debugPaintLayerBordersEnabled',
      'debugRepaintRainbowEnabled',
    ];

    final dartFiles = Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>().where(
      (file) => file.path.endsWith('.dart'),
    );

    for (final file in dartFiles) {
      final source = file.readAsStringSync();
      for (final flag in debugPaintFlags) {
        expect(
          source,
          isNot(contains('$flag = true')),
          reason: '${file.path} must not enable $flag',
        );
      }
    }
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/debug_paint_regression_test.dart`
Expected: FAIL on the first test — `mainSource` does not contain `debugPaintBaselinesEnabled = false;` yet.

- [ ] **Step 3: Restore the fix in `lib/main.dart`**

In `lib/main.dart`, change:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/main_screen.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/theme/system_ui_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Explicitly declare edge-to-edge instead of relying on the implicit
  // per-SDK default (see lib/theme/system_ui_overlay.dart for details).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: UniverseDecidesApp()));
}
```

to:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/screens/main_screen.dart';
import 'package:theuniversedecides/theme/app_colors.dart';
import 'package:theuniversedecides/theme/system_ui_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintBaselinesEnabled = false;
  // Explicitly declare edge-to-edge instead of relying on the implicit
  // per-SDK default (see lib/theme/system_ui_overlay.dart for details).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const ProviderScope(child: UniverseDecidesApp()));
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/debug_paint_regression_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart test/debug_paint_regression_test.dart
git commit -m "fix: restore debugPaintBaselinesEnabled=false dropped in recent-apps commit"
```

---

## Task 2: Make quick-mode coin flips silent without touching normal-mode sound

`lib/screens/coin_flip_screen.dart` currently calls `ref.read(soundEffectsProvider.notifier).playDecision()` unconditionally in two places: `_fireImpact()` (the animated impact path, `coin_flip_screen.dart:242`) and `_launchReduced()` (the reduced-motion path, `coin_flip_screen.dart:318`). Both must skip the sound call when `widget.quickMode` is true. `playDecision()` already uses `AudioContextConfigFocus.mixWithOthers` (see `lib/services/sound_effects_service.dart`), so normal-mode sound already never ducks/interrupts other media — only the call needs to be gated, nothing about the sound service itself changes.

**Files:**
- Modify: `lib/screens/coin_flip_screen.dart:239-243` (`_fireImpact`), `lib/screens/coin_flip_screen.dart:308-321` (`_launchReduced`)
- Test: `test/coin_flip_screen_quick_mode_sound_test.dart` (new)

**Interfaces:**
- Produces: `_CoinFlipScreenState._playDecisionSoundIfAllowed()` — no return value, no parameters, callable from both `_fireImpact()` and `_launchReduced()`.
- Consumes: `soundEffectsProvider` (`NotifierProvider<SoundEffectsNotifier, bool>` from `lib/services/sound_effects_service.dart`), `widget.quickMode` (`bool`, already defined on `CoinFlipScreen`).

- [ ] **Step 1: Write the failing tests**

Create `test/coin_flip_screen_quick_mode_sound_test.dart`:

```dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:theuniversedecides/l10n/generated/app_localizations.dart';
import 'package:theuniversedecides/screens/coin_flip_screen.dart';
import 'package:theuniversedecides/services/random_org_service.dart';
import 'package:theuniversedecides/services/sound_effects_service.dart';

void main() {
  Widget buildApp(Widget home) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );
  }

  void enableReducedMotion(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  testWidgets(
    'quick mode with the normal animated impact does not play the decision sound',
    (tester) async {
      final sound = _RecordingSoundEffectsNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomOrgServiceProvider.overrideWith(
              (ref) => _FakeRandomOrgService([0]),
            ),
            soundEffectsProvider.overrideWith(() => sound),
          ],
          child: buildApp(
            const CoinFlipScreen(
              quickMode: true,
              autoStart: true,
              autoClose: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(sound.playDecisionCallCount, 0);
    },
  );

  testWidgets(
    'reduced-motion quick mode does not play the decision sound',
    (tester) async {
      final sound = _RecordingSoundEffectsNotifier();
      enableReducedMotion(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomOrgServiceProvider.overrideWith(
              (ref) => _FakeRandomOrgService([1]),
            ),
            soundEffectsProvider.overrideWith(() => sound),
          ],
          child: buildApp(
            const CoinFlipScreen(
              quickMode: true,
              autoStart: true,
              autoClose: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(sound.playDecisionCallCount, 0);
    },
  );

  testWidgets(
    'normal mode with the animated impact still plays the decision sound',
    (tester) async {
      final sound = _RecordingSoundEffectsNotifier();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomOrgServiceProvider.overrideWith(
              (ref) => _FakeRandomOrgService([0]),
            ),
            soundEffectsProvider.overrideWith(() => sound),
          ],
          child: buildApp(const CoinFlipScreen()),
        ),
      );
      await tester.tap(find.text('Flip a coin'));
      await tester.pumpAndSettle();

      expect(sound.playDecisionCallCount, 1);
    },
  );

  testWidgets(
    'reduced-motion normal mode still plays the decision sound',
    (tester) async {
      final sound = _RecordingSoundEffectsNotifier();
      enableReducedMotion(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            randomOrgServiceProvider.overrideWith(
              (ref) => _FakeRandomOrgService([1]),
            ),
            soundEffectsProvider.overrideWith(() => sound),
          ],
          child: buildApp(const CoinFlipScreen()),
        ),
      );
      await tester.tap(find.text('Flip a coin'));
      await tester.pumpAndSettle();

      expect(sound.playDecisionCallCount, 1);
    },
  );
}

class _RecordingSoundEffectsNotifier extends SoundEffectsNotifier {
  int playDecisionCallCount = 0;

  @override
  bool build() => true;

  @override
  Future<void> playDecision() async {
    playDecisionCallCount++;
  }
}

class _FakeRandomOrgService extends RandomOrgService {
  _FakeRandomOrgService(this._result)
    : super(client: MockClient((_) async => http.Response('', 200)));

  final int _result;

  @override
  Future<List<int>> fetchIntegers({
    required int count,
    required int min,
    required int max,
  }) async => [_result];

  @override
  void dispose() {}
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/coin_flip_screen_quick_mode_sound_test.dart`
Expected: FAIL — the two quick-mode tests fail because `playDecision()` is currently called unconditionally (`playDecisionCallCount` is `1`, not `0`).

- [ ] **Step 3: Add `_playDecisionSoundIfAllowed()` and use it from both call sites**

In `lib/screens/coin_flip_screen.dart`, add this method to `_CoinFlipScreenState` (place it near `_fireImpact`, e.g. directly above it):

```dart
  void _playDecisionSoundIfAllowed() {
    if (widget.quickMode) {
      return;
    }

    unawaited(ref.read(soundEffectsProvider.notifier).playDecision());
  }
```

Then change `_fireImpact()` from:

```dart
  void _fireImpact() {
    _impact.forward(from: 0);
    HapticFeedback.mediumImpact();
    unawaited(ref.read(soundEffectsProvider.notifier).playDecision());
  }
```

to:

```dart
  void _fireImpact() {
    _impact.forward(from: 0);
    HapticFeedback.mediumImpact();
    _playDecisionSoundIfAllowed();
  }
```

And change `_launchReduced()` from:

```dart
    HapticFeedback.selectionClick();
    unawaited(ref.read(soundEffectsProvider.notifier).playDecision());
    _recordHistory(result);
```

to:

```dart
    HapticFeedback.selectionClick();
    _playDecisionSoundIfAllowed();
    _recordHistory(result);
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/coin_flip_screen_quick_mode_sound_test.dart`
Expected: PASS (all 4 tests)

- [ ] **Step 5: Commit**

```bash
git add lib/screens/coin_flip_screen.dart test/coin_flip_screen_quick_mode_sound_test.dart
git commit -m "fix: silence the decision sound in quick coin mode"
```

---

## Task 3: Let QuickCoinActivity show above the lock screen, and simplify CoinQuickTileService

`QuickCoinActivity` must display over the keyguard without unlocking. The default `flutter.minSdkVersion` in this project is `24` (`android/app/build.gradle.kts:35` → `FlutterExtension.kt` in the Flutter SDK), but `Activity.setShowWhenLocked(boolean)` only exists from API 27, and the `android:showWhenLocked` manifest attribute only exists from API 34. To cover the full supported range, add the manifest attribute (declarative, used from API 34) **and** call the matching code API in `onCreate` with a fallback to the pre-27 window flag. No `SYSTEM_ALERT_WINDOW`/overlay permission, no `unlockAndRun()`, no `turnScreenOn`.

Since `DiceQuickTileService` is removed in Task 4, the shared abstract `QuickActionTileService` it and `CoinQuickTileService` both extend stops earning its keep — fold its logic straight into `CoinQuickTileService` and delete `QuickActionTileService.java`. This task focuses on the lock-screen behavior; Task 4 removes the dice references from the surrounding files (`QuickAccessContract`, `MainActivity`) so this task's diff of `CoinQuickTileService` stays isolated to the lock-screen change plus the class-merge.

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml:29-38` (`.QuickCoinActivity` declaration)
- Modify: `android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java`
- Modify: `android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java` (absorbs `QuickActionTileService`'s `onClick()`)
- Delete: `android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java`
- Modify: `test/android/play_games_configuration_test.dart:56-81` (the `coin quick tile opens...` test currently reads `QuickActionTileService.java`, which is about to disappear)
- Test: `test/android/coin_quick_tile_lockscreen_test.dart` (new)

**Interfaces:**
- Consumes: `QuickAccessContract.EXTRA_ACTION`, `QuickAccessContract.ACTION_COIN` (both already defined in `QuickAccessContract.java`, untouched by this task).
- Produces: `CoinQuickTileService` is a concrete `android.service.quicksettings.TileService` subclass (no longer extends an abstract intermediate class) with its own `onClick()`.

- [ ] **Step 1: Write the failing tests**

Create `test/android/coin_quick_tile_lockscreen_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QuickCoinActivity is configured to show above the lock screen', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();

    expect(manifest, contains('android:name=".QuickCoinActivity"'));
    expect(manifest, contains('android:showWhenLocked="true"'));
    expect(quickActivity, contains('setShowWhenLocked(true)'));
    expect(
      quickActivity,
      contains('WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED'),
    );
  });

  test('locked-device launch requests no new permission and no unlock', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();

    expect(manifest, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(manifest, isNot(contains('TYPE_APPLICATION_OVERLAY')));
    expect(tileService, isNot(contains('unlockAndRun')));
    expect(tileService, isNot(contains('turnScreenOn')));
    expect(quickActivity, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(
      'uses-permission'.allMatches(manifest).length,
      1,
      reason: 'Only the existing INTERNET permission should be declared.',
    );
  });

  test('CoinQuickTileService launches QuickCoinActivity directly', () {
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java',
    ).readAsStringSync();

    expect(tileService, contains('extends TileService'));
    expect(tileService, contains('new Intent(this, QuickCoinActivity.class)'));
    expect(tileService, contains('startActivityAndCollapse'));
    expect(
      File(
        'android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java',
      ).existsSync(),
      isFalse,
    );
  });

  test('QuickCoinActivity keeps its transparency and lifecycle behavior', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final activityBlock = manifest.substring(
      manifest.indexOf('<activity\n            android:name=".QuickCoinActivity"'),
      manifest.indexOf('/>', manifest.indexOf('.QuickCoinActivity')) + 2,
    );

    expect(activityBlock, contains('android:excludeFromRecents="true"'));
    expect(activityBlock, contains('android:noHistory="true"'));
    expect(activityBlock, contains('android:theme="@style/QuickCoinTheme"'));
    expect(activityBlock, contains('android:launchMode="singleTop"'));
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/android/coin_quick_tile_lockscreen_test.dart`
Expected: FAIL — `android:showWhenLocked="true"` and `setShowWhenLocked(true)` are not present yet.

- [ ] **Step 3: Add `android:showWhenLocked="true"` to the manifest**

In `android/app/src/main/AndroidManifest.xml`, change the `.QuickCoinActivity` declaration from:

```xml
        <activity
            android:name=".QuickCoinActivity"
            android:exported="false"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:excludeFromRecents="true"
            android:noHistory="true"
            android:theme="@style/QuickCoinTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true" />
```

to:

```xml
        <activity
            android:name=".QuickCoinActivity"
            android:exported="false"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:excludeFromRecents="true"
            android:noHistory="true"
            android:showWhenLocked="true"
            android:theme="@style/QuickCoinTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true" />
```

- [ ] **Step 4: Call the matching code API from `QuickCoinActivity`**

Replace the full contents of `android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java` with:

```java
package com.hugo.theuniversedecides;

import android.os.Build;
import android.os.Bundle;
import android.view.WindowManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode;
import io.flutter.embedding.android.RenderMode;

public class QuickCoinActivity extends FlutterActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Coin flips are safe to run while the device is locked, so this
        // activity is presented above the keyguard instead of unlocking it.
        // android:showWhenLocked in the manifest already covers API 34+;
        // these calls cover the full flutter.minSdkVersion range without
        // SYSTEM_ALERT_WINDOW or any new runtime permission.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
        } else {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);
        }
    }

    @NonNull
    @Override
    public String getInitialRoute() {
        return "/quick-coin";
    }

    @NonNull
    @Override
    public BackgroundMode getBackgroundMode() {
        return BackgroundMode.transparent;
    }

    @NonNull
    @Override
    public RenderMode getRenderMode() {
        return RenderMode.texture;
    }
}
```

- [ ] **Step 5: Fold `QuickActionTileService` into `CoinQuickTileService` and delete the abstract class**

Replace the full contents of `android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java` with:

```java
package com.hugo.theuniversedecides;

import android.app.PendingIntent;
import android.content.Intent;
import android.os.Build;
import android.service.quicksettings.TileService;

public class CoinQuickTileService extends TileService {
    @Override
    public void onClick() {
        super.onClick();

        Intent intent = new Intent(this, QuickCoinActivity.class)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP)
                .putExtra(QuickAccessContract.EXTRA_ACTION, QuickAccessContract.ACTION_COIN);

        // QuickCoinActivity requests showWhenLocked, so the system presents
        // it above the keyguard without an unlock prompt when the device is
        // locked. The same startActivityAndCollapse call also preserves the
        // existing collapsed Quick Settings behavior when unlocked.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            PendingIntent pendingIntent = PendingIntent.getActivity(
                    this,
                    QuickAccessContract.ACTION_COIN.hashCode(),
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
            );
            startActivityAndCollapse(pendingIntent);
            return;
        }

        startActivityAndCollapse(intent);
    }
}
```

Delete `android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java`:

```bash
git rm android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java
```

- [ ] **Step 6: Update the pre-existing test that referenced `QuickActionTileService.java`**

In `test/android/play_games_configuration_test.dart`, the `'coin quick tile opens the translucent quick coin activity'` test currently does:

```dart
  test('coin quick tile opens the translucent quick coin activity', () {
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickActionTileService.java',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(tileService, contains('getLaunchActivityClass()'));
    expect(tileService, contains('new Intent(this, getLaunchActivityClass())'));
    expect(
      quickActivity,
      contains('QuickCoinActivity extends FlutterActivity'),
    );
    expect(quickActivity, contains('getInitialRoute()'));
    expect(quickActivity, contains('/quick-coin'));
    expect(quickActivity, contains('BackgroundMode.transparent'));
    expect(quickActivity, contains('RenderMode.texture'));
    expect(manifest, contains('android:name=".QuickCoinActivity"'));
    expect(manifest, contains('android:theme="@style/QuickCoinTheme"'));
    expect(manifest, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(manifest, isNot(contains('TYPE_APPLICATION_OVERLAY')));
  });
```

Replace it with:

```dart
  test('coin quick tile opens the translucent quick coin activity', () {
    final tileService = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java',
    ).readAsStringSync();
    final quickActivity = File(
      'android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java',
    ).readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(tileService, contains('extends TileService'));
    expect(tileService, contains('new Intent(this, QuickCoinActivity.class)'));
    expect(
      quickActivity,
      contains('QuickCoinActivity extends FlutterActivity'),
    );
    expect(quickActivity, contains('getInitialRoute()'));
    expect(quickActivity, contains('/quick-coin'));
    expect(quickActivity, contains('BackgroundMode.transparent'));
    expect(quickActivity, contains('RenderMode.texture'));
    expect(manifest, contains('android:name=".QuickCoinActivity"'));
    expect(manifest, contains('android:theme="@style/QuickCoinTheme"'));
    expect(manifest, isNot(contains('SYSTEM_ALERT_WINDOW')));
    expect(manifest, isNot(contains('TYPE_APPLICATION_OVERLAY')));
  });
```

- [ ] **Step 7: Run tests to verify they pass**

Run: `flutter test test/android/coin_quick_tile_lockscreen_test.dart test/android/play_games_configuration_test.dart`
Expected: PASS. (`play_games_configuration_test.dart`'s other tests are untouched and should keep passing; if any still reference dice resources they will be fixed in Task 4.)

- [ ] **Step 8: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml \
  android/app/src/main/java/com/hugo/theuniversedecides/QuickCoinActivity.java \
  android/app/src/main/java/com/hugo/theuniversedecides/CoinQuickTileService.java \
  test/android/coin_quick_tile_lockscreen_test.dart \
  test/android/play_games_configuration_test.dart
git commit -m "feat: show quick coin above the lock screen without unlocking"
```

---

## Task 4: Remove the dice Quick Settings tile end-to-end (native + Flutter), keep the in-app dice screen

Remove every dice-specific piece of the Quick Settings integration while leaving `DiceRollScreen` and the bottom-nav dice tab fully intact. This spans: the native `DiceQuickTileService` + its manifest entry + drawable/string resources, `MainActivity`'s dice branches, `QuickAccessContract.ACTION_DICE`, the Dart `QuickAccessAction.dice` enum value and `diceQuickAccessTriggerProvider`, the "Add d20" button in `about_me_screen.dart`, the dice `quickTile*`/`aboutAddDiceButton` ARB strings in all 9 locales, and the now-invalid tests in `test/widget_test.dart`.

**Files:**
- Delete: `android/app/src/main/java/com/hugo/theuniversedecides/DiceQuickTileService.java`
- Delete: `android/app/src/main/res/drawable-v21/ic_quick_tile_dice.xml` (or wherever `ic_quick_tile_dice.xml` resolves — see Step 1)
- Modify: `android/app/src/main/AndroidManifest.xml` (remove `.DiceQuickTileService` `<service>`)
- Modify: `android/app/src/main/res/values/strings.xml` (remove `quick_tile_dice_label`)
- Modify: `android/app/src/main/java/com/hugo/theuniversedecides/QuickAccessContract.java` (remove `ACTION_DICE`)
- Modify: `android/app/src/main/java/com/hugo/theuniversedecides/MainActivity.java` (remove dice branches, simplify tile-request methods)
- Modify: `lib/services/quick_access_service.dart` (remove `QuickAccessAction.dice`, `diceQuickAccessTriggerProvider`)
- Modify: `lib/screens/main_screen.dart:93-98` (remove `case QuickAccessAction.dice:`)
- Modify: `lib/screens/dice_roll_screen.dart:150-157` (remove the dice quick-access trigger listener)
- Modify: `lib/screens/about_me_screen.dart:40-70,129-147` (remove dice tile request + button)
- Modify: `lib/l10n/app_de.arb`, `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_hi.arb`, `app_it.arb`, `app_pt.arb`, `app_tr.arb`, `app_uk.arb` (remove `aboutAddDiceButton`, `quickTileDiceAdded`, `quickTileDiceAlreadyAdded`, `quickTileDiceCancelled`, `quickTileDiceUnsupported`)
- Modify: `test/widget_test.dart:279-280,287-326` (drop dice-tile assertions and the dice-quick-action test)
- Test: `test/android/dice_quick_tile_removed_test.dart` (new)

**Interfaces:**
- Produces: `QuickAccessAction` enum with a single member `coin` (`tabIndex => 0`, `value => 'coin'`); `fromValue` returns `null` for anything other than `'coin'`.
- Consumes (unaffected): `coinQuickAccessTriggerProvider`, `quickAccessServiceProvider`, `QuickAccessTileRequestResult` — all untouched.

- [ ] **Step 1: Confirm the exact drawable path, then write the failing test**

Run: `find android/app/src/main/res -iname "ic_quick_tile_dice.xml"` to get the exact path (it's a `drawable/ic_quick_tile_dice.xml`, not a `-v21` variant, per the earlier repo scan — use whatever this command prints).

Create `test/android/dice_quick_tile_removed_test.dart`:

```dart
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
      File('android/app/src/main/res/drawable/ic_quick_tile_dice.xml')
          .existsSync(),
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/android/dice_quick_tile_removed_test.dart`
Expected: FAIL — every file still contains the dice references.

- [ ] **Step 3: Delete the native dice files**

```bash
git rm android/app/src/main/java/com/hugo/theuniversedecides/DiceQuickTileService.java
git rm android/app/src/main/res/drawable/ic_quick_tile_dice.xml
```

(If the `find` from Step 1 showed a different path for the drawable, use that path instead.)

- [ ] **Step 4: Remove the dice `<service>` from the manifest**

In `android/app/src/main/AndroidManifest.xml`, delete this block (immediately after the `.CoinQuickTileService` `<service>`):

```xml
        <service
            android:name=".DiceQuickTileService"
            android:exported="true"
            android:icon="@drawable/ic_quick_tile_dice"
            android:label="@string/quick_tile_dice_label"
            android:permission="android.permission.BIND_QUICK_SETTINGS_TILE">
            <intent-filter>
                <action android:name="android.service.quicksettings.action.QS_TILE"/>
            </intent-filter>
        </service>
```

- [ ] **Step 5: Remove the dice label string**

In `android/app/src/main/res/values/strings.xml`, remove the line:

```xml
    <string name="quick_tile_dice_label">d20 Dice</string>
```

leaving:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">The Universe Decides</string>
    <string name="quick_tile_coin_label">Coin</string>
</resources>
```

- [ ] **Step 6: Remove `ACTION_DICE` from `QuickAccessContract`**

Replace `android/app/src/main/java/com/hugo/theuniversedecides/QuickAccessContract.java` with:

```java
package com.hugo.theuniversedecides;

final class QuickAccessContract {
    static final String METHOD_CHANNEL = "theuniversedecides/quick_access";
    static final String EVENT_CHANNEL = "theuniversedecides/quick_access/events";
    static final String EXTRA_ACTION = "quick_action";
    static final String ARG_ACTION = "action";
    static final String ACTION_COIN = "coin";

    private QuickAccessContract() {}
}
```

- [ ] **Step 7: Simplify `MainActivity` to the single remaining coin action**

In `android/app/src/main/java/com/hugo/theuniversedecides/MainActivity.java`, replace the block from `private void requestQuickAccessTile(...)` through the end of `getTileIconResId(...)` — currently:

```java
    private void requestQuickAccessTile(MethodCall call, MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success("unsupported");
            return;
        }

        Object arguments = call.arguments;
        if (!(arguments instanceof Map<?, ?> argumentMap)) {
            result.error("invalid_arguments", "Expected a map with the tile action.", null);
            return;
        }

        Object actionValue = argumentMap.get(QuickAccessContract.ARG_ACTION);
        if (!(actionValue instanceof String action)) {
            result.error("invalid_action", "Expected a valid quick access action.", null);
            return;
        }

        ComponentName componentName = getTileComponentName(action);
        int labelResId = getTileLabelResId(action);
        int iconResId = getTileIconResId(action);
        if (componentName == null || labelResId == 0 || iconResId == 0) {
            result.error("invalid_action", "Unsupported quick access action.", null);
            return;
        }

        StatusBarManager statusBarManager = getSystemService(StatusBarManager.class);
        if (statusBarManager == null) {
            result.success("unsupported");
            return;
        }

        statusBarManager.requestAddTileService(
                componentName,
                getString(labelResId),
                Icon.createWithResource(this, iconResId),
                getMainExecutor(),
                addTileResult -> result.success(mapTileResult(addTileResult))
        );
    }

    private ComponentName getTileComponentName(String action) {
        if (QuickAccessContract.ACTION_COIN.equals(action)) {
            return new ComponentName(this, CoinQuickTileService.class);
        }
        if (QuickAccessContract.ACTION_DICE.equals(action)) {
            return new ComponentName(this, DiceQuickTileService.class);
        }
        return null;
    }

    private int getTileLabelResId(String action) {
        if (QuickAccessContract.ACTION_COIN.equals(action)) {
            return R.string.quick_tile_coin_label;
        }
        if (QuickAccessContract.ACTION_DICE.equals(action)) {
            return R.string.quick_tile_dice_label;
        }
        return 0;
    }

    private int getTileIconResId(String action) {
        if (QuickAccessContract.ACTION_COIN.equals(action)) {
            return R.drawable.ic_quick_tile_coin;
        }
        if (QuickAccessContract.ACTION_DICE.equals(action)) {
            return R.drawable.ic_quick_tile_dice;
        }
        return 0;
    }
```

with:

```java
    private void requestQuickAccessTile(MethodCall call, MethodChannel.Result result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) {
            result.success("unsupported");
            return;
        }

        Object arguments = call.arguments;
        if (!(arguments instanceof Map<?, ?> argumentMap)) {
            result.error("invalid_arguments", "Expected a map with the tile action.", null);
            return;
        }

        Object actionValue = argumentMap.get(QuickAccessContract.ARG_ACTION);
        if (!QuickAccessContract.ACTION_COIN.equals(actionValue)) {
            result.error("invalid_action", "Unsupported quick access action.", null);
            return;
        }

        StatusBarManager statusBarManager = getSystemService(StatusBarManager.class);
        if (statusBarManager == null) {
            result.success("unsupported");
            return;
        }

        statusBarManager.requestAddTileService(
                new ComponentName(this, CoinQuickTileService.class),
                getString(R.string.quick_tile_coin_label),
                Icon.createWithResource(this, R.drawable.ic_quick_tile_coin),
                getMainExecutor(),
                addTileResult -> result.success(mapTileResult(addTileResult))
        );
    }
```

Then update `extractQuickAccessAction` from:

```java
    private String extractQuickAccessAction(Intent intent) {
        if (intent == null) {
            return null;
        }

        String action = intent.getStringExtra(QuickAccessContract.EXTRA_ACTION);
        if (QuickAccessContract.ACTION_COIN.equals(action) || QuickAccessContract.ACTION_DICE.equals(action)) {
            return action;
        }
        return null;
    }
```

to:

```java
    private String extractQuickAccessAction(Intent intent) {
        if (intent == null) {
            return null;
        }

        String action = intent.getStringExtra(QuickAccessContract.EXTRA_ACTION);
        if (QuickAccessContract.ACTION_COIN.equals(action)) {
            return action;
        }
        return null;
    }
```

- [ ] **Step 8: Remove `QuickAccessAction.dice` and `diceQuickAccessTriggerProvider` from Dart**

In `lib/services/quick_access_service.dart`, replace:

```dart
enum QuickAccessAction {
  coin,
  dice;

  int get tabIndex => switch (this) {
    QuickAccessAction.coin => 0,
    QuickAccessAction.dice => 1,
  };

  String get value => switch (this) {
    QuickAccessAction.coin => 'coin',
    QuickAccessAction.dice => 'dice',
  };

  static QuickAccessAction? fromValue(String? value) {
    return switch (value) {
      'coin' => QuickAccessAction.coin,
      'dice' => QuickAccessAction.dice,
      _ => null,
    };
  }
}
```

with:

```dart
enum QuickAccessAction {
  coin;

  int get tabIndex => switch (this) {
    QuickAccessAction.coin => 0,
  };

  String get value => switch (this) {
    QuickAccessAction.coin => 'coin',
  };

  static QuickAccessAction? fromValue(String? value) {
    return switch (value) {
      'coin' => QuickAccessAction.coin,
      _ => null,
    };
  }
}
```

And replace:

```dart
final coinQuickAccessTriggerProvider =
    NotifierProvider<QuickAccessTriggerNotifier, int>(
      QuickAccessTriggerNotifier.new,
    );
final diceQuickAccessTriggerProvider =
    NotifierProvider<QuickAccessTriggerNotifier, int>(
      QuickAccessTriggerNotifier.new,
    );
```

with:

```dart
final coinQuickAccessTriggerProvider =
    NotifierProvider<QuickAccessTriggerNotifier, int>(
      QuickAccessTriggerNotifier.new,
    );
```

- [ ] **Step 9: Drop the dice branch from `main_screen.dart`**

In `lib/screens/main_screen.dart`, change:

```dart
      switch (action) {
        case QuickAccessAction.coin:
          ref.read(coinQuickAccessTriggerProvider.notifier).trigger();
        case QuickAccessAction.dice:
          ref.read(diceQuickAccessTriggerProvider.notifier).trigger();
      }
```

to:

```dart
      switch (action) {
        case QuickAccessAction.coin:
          ref.read(coinQuickAccessTriggerProvider.notifier).trigger();
      }
```

- [ ] **Step 10: Remove the dice quick-access listener from `dice_roll_screen.dart`**

In `lib/screens/dice_roll_screen.dart`, delete this block from `build()`:

```dart
    ref.listen<int>(diceQuickAccessTriggerProvider, (previous, next) {
      if (previous == next) {
        return;
      }
      controller.setDiceCount(1);
      controller.setSelectedSides(20);
      _startRoll();
    });
```

Remove the now-unused `import 'package:theuniversedecides/services/quick_access_service.dart';` from this file only if nothing else in it references the `quick_access_service.dart` package after this deletion — check with `grep -n "quick_access_service\|QuickAccess" lib/screens/dice_roll_screen.dart` after making the change; if the import line is the only remaining reference, delete it.

- [ ] **Step 11: Remove the dice shortcut button from `about_me_screen.dart`**

In `lib/screens/about_me_screen.dart`, change the `_requestTile` switch from:

```dart
    final message = switch ((action, result)) {
      (QuickAccessAction.coin, QuickAccessTileRequestResult.added) =>
        l10n.quickTileCoinAdded,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.alreadyAdded) =>
        l10n.quickTileCoinAlreadyAdded,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.cancelled) =>
        l10n.quickTileCoinCancelled,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.unsupported) =>
        l10n.quickTileCoinUnsupported,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.added) =>
        l10n.quickTileDiceAdded,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.alreadyAdded) =>
        l10n.quickTileDiceAlreadyAdded,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.cancelled) =>
        l10n.quickTileDiceCancelled,
      (QuickAccessAction.dice, QuickAccessTileRequestResult.unsupported) =>
        l10n.quickTileDiceUnsupported,
    };
```

to:

```dart
    final message = switch ((action, result)) {
      (QuickAccessAction.coin, QuickAccessTileRequestResult.added) =>
        l10n.quickTileCoinAdded,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.alreadyAdded) =>
        l10n.quickTileCoinAlreadyAdded,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.cancelled) =>
        l10n.quickTileCoinCancelled,
      (QuickAccessAction.coin, QuickAccessTileRequestResult.unsupported) =>
        l10n.quickTileCoinUnsupported,
    };
```

Then change the shortcuts `Row` from:

```dart
          Row(
            children: [
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.monetization_on,
                  label: l10n.aboutAddCoinButton,
                  onTap: () => _requestTile(QuickAccessAction.coin),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ShortcutButton(
                  icon: Icons.casino,
                  label: l10n.aboutAddDiceButton,
                  onTap: () => _requestTile(QuickAccessAction.dice),
                ),
              ),
            ],
          ),
```

to:

```dart
          SizedBox(
            width: double.infinity,
            child: _ShortcutButton(
              icon: Icons.monetization_on,
              label: l10n.aboutAddCoinButton,
              onTap: () => _requestTile(QuickAccessAction.coin),
            ),
          ),
```

- [ ] **Step 12: Remove the dice ARB keys from all 9 locale files**

In each of `lib/l10n/app_de.arb`, `app_en.arb`, `app_es.arb`, `app_fr.arb`, `app_hi.arb`, `app_it.arb`, `app_pt.arb`, `app_tr.arb`, `app_uk.arb`, delete these two lines (the exact translated values differ per locale, but the keys and their position are identical in every file — `aboutAddDiceButton` sits right after `aboutAddCoinButton`, and the four `quickTileDice*` lines sit right after the four `quickTileCoin*` lines):

```
  "aboutAddDiceButton": "...",
```

and

```
  "quickTileDiceAdded": "...",
  "quickTileDiceAlreadyAdded": "...",
  "quickTileDiceCancelled": "...",
  "quickTileDiceUnsupported": "...",
```

- [ ] **Step 13: Regenerate the localization Dart sources**

Run: `flutter gen-l10n`

This rewrites `lib/l10n/generated/app_localizations*.dart` to drop the now-undefined `aboutAddDiceButton`/`quickTileDice*` getters. These generated files are checked into git — they must be staged alongside the ARB changes.

- [ ] **Step 14: Update `test/widget_test.dart`**

In the `'about tab loads profile and main screen has no top bar'` test, remove these two lines:

```dart
    expect(find.text('Add d20'), findsOneWidget);
```

and

```dart
    expect(find.byIcon(Icons.casino), findsOneWidget);
```

(Keep `expect(find.text('Add coin'), findsOneWidget);` and `expect(find.byIcon(Icons.monetization_on), findsOneWidget);` — the coin shortcut is unchanged.)

Delete the entire `'quick dice action opens dice and rolls d20 by default'` test block (from `testWidgets(` through its closing `);`), currently:

```dart
  testWidgets('quick dice action opens dice and rolls d20 by default', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final randomService = _FakeRandomOrgService([
      [17],
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          randomOrgServiceProvider.overrideWith((ref) => randomService),
          githubProfileServiceProvider.overrideWith(
            (ref) => _FakeGitHubProfileService(
              const GitHubProfile(
                login: 'vitorhugo-dotnet',
                avatarUrl: '',
                name: 'Vitor Hugo',
              ),
            ),
          ),
          quickAccessServiceProvider.overrideWith(
            (ref) =>
                _FakeQuickAccessService(initialAction: QuickAccessAction.dice),
          ),
        ],
        child: const UniverseDecidesApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Total: 17'), findsOneWidget);
    expect(randomService.requests, [(1, 1, 20)]);
  });
```

- [ ] **Step 15: Run the analyzer and full test suite**

Run: `flutter analyze`
Expected: no errors (this will surface any remaining stray reference to `QuickAccessAction.dice`, `diceQuickAccessTriggerProvider`, or an unused import).

Run: `flutter test`
Expected: PASS across the whole suite, including `test/android/dice_quick_tile_removed_test.dart`, `test/widget_test.dart`, and `test/dice_roll_screen_test.dart`/`test/controllers/dice_roll_controller_test.dart` (the regular dice feature's own tests, which this task must not break).

- [ ] **Step 16: Commit**

```bash
git add android/app/src/main/AndroidManifest.xml \
  android/app/src/main/res/values/strings.xml \
  android/app/src/main/java/com/hugo/theuniversedecides/QuickAccessContract.java \
  android/app/src/main/java/com/hugo/theuniversedecides/MainActivity.java \
  lib/services/quick_access_service.dart \
  lib/screens/main_screen.dart \
  lib/screens/dice_roll_screen.dart \
  lib/screens/about_me_screen.dart \
  lib/l10n/app_de.arb lib/l10n/app_en.arb lib/l10n/app_es.arb lib/l10n/app_fr.arb \
  lib/l10n/app_hi.arb lib/l10n/app_it.arb lib/l10n/app_pt.arb lib/l10n/app_tr.arb \
  lib/l10n/app_uk.arb lib/l10n/generated/ \
  test/android/dice_quick_tile_removed_test.dart test/widget_test.dart
git add -u android/app/src/main/java/com/hugo/theuniversedecides/DiceQuickTileService.java \
  android/app/src/main/res/drawable/ic_quick_tile_dice.xml
git commit -m "feat: remove the dice Quick Settings tile, keep the in-app dice screen"
```

---

## Task 5: Version bump and changelog

**Files:**
- Modify: `pubspec.yaml` (version line only)
- Modify: `CHANGELOG.xml` (full replace)

**Interfaces:** None — metadata-only change.

- [ ] **Step 1: Bump the semantic version (MINOR)**

In `pubspec.yaml`, change:

```yaml
version: 2.5.2+100147
```

to:

```yaml
version: 2.6.0+100147
```

(Build number `100147` is preserved exactly, per `AGENTS.md` — CI owns it.)

- [ ] **Step 2: Replace `CHANGELOG.xml` with only this change's release notes**

Replace the full contents of `CHANGELOG.xml` with:

```xml
<en-US>
- Flip a coin from Quick Settings even while your phone is locked — no unlock needed.
- Removed the dice shortcut from Quick Settings; the in-app dice screen is unchanged.
- Fixed stray debug lines that could appear under some text.
- The quick coin popup is now fully silent and never interrupts music, calls, or other audio.
</en-US>

<pt-BR>
- Jogue a moeda pelo painel de Configurações Rápidas mesmo com o telefone bloqueado — sem precisar desbloquear.
- Removido o atalho do dado do painel de Configurações Rápidas; a tela de dado no app continua igual.
- Corrigidas linhas de depuração que apareciam sob alguns textos.
- O pop-up rápido da moeda agora é totalmente silencioso e nunca interrompe música, ligações ou outro áudio.
</pt-BR>

<es-ES>
- Lanza la moneda desde el panel de Ajustes rápidos incluso con el teléfono bloqueado, sin necesidad de desbloquear.
- Se eliminó el acceso directo de dados del panel de Ajustes rápidos; la pantalla de dados de la app sigue igual.
- Se corrigieron líneas de depuración que aparecían bajo algunos textos.
- La ventana rápida de la moneda ahora es totalmente silenciosa y nunca interrumpe música, llamadas u otro audio.
</es-ES>

<de>
- Münze jetzt auch bei gesperrtem Smartphone direkt über die Schnelleinstellungen werfen – kein Entsperren nötig.
- Die Würfel-Kachel wurde aus den Schnelleinstellungen entfernt; der Würfelbildschirm in der App bleibt unverändert.
- Fehlerhafte Debug-Linien unter manchen Texten wurden behoben.
- Das Schnellmünz-Fenster ist jetzt komplett lautlos und unterbricht nie Musik, Anrufe oder anderes Audio.
</de>

<fr-FR>
- Lance la pièce depuis les Réglages rapides même téléphone verrouillé, sans déverrouillage.
- Le raccourci des dés a été retiré des Réglages rapides ; l'écran des dés dans l'appli reste inchangé.
- Correction de lignes de débogage qui apparaissaient sous certains textes.
- La fenêtre rapide de la pièce est désormais totalement silencieuse et n'interrompt jamais musique, appels ou autre audio.
</fr-FR>

<hi>
- अब फ़ोन लॉक होने पर भी क्विक सेटिंग्स पैनल से सिक्का उछालें — अनलॉक करने की ज़रूरत नहीं।
- क्विक सेटिंग्स पैनल से डाइस शॉर्टकट हटाया गया; ऐप के अंदर डाइस स्क्रीन पहले जैसी है।
- कुछ टेक्स्ट के नीचे दिखने वाली डिबग लाइनें ठीक की गईं।
- क्विक कॉइन पॉपअप अब पूरी तरह साइलेंट है और संगीत, कॉल या अन्य ऑडियो में कभी बाधा नहीं डालता।
</hi>

<it>
- Lancia la moneta dal pannello Impostazioni rapide anche a telefono bloccato, senza sbloccare.
- Rimossa la scorciatoia dei dadi dal pannello Impostazioni rapide; la schermata dei dadi nell'app resta invariata.
- Corrette le righe di debug che comparivano sotto alcuni testi.
- Il popup rapido della moneta ora è completamente silenzioso e non interrompe mai musica, chiamate o altri audio.
</it>

<tr>
- Telefon kilitliyken bile Hızlı Ayarlar panelinden yazı tura at — kilidi açmana gerek yok.
- Hızlı Ayarlar panelinden zar kısayolu kaldırıldı; uygulama içindeki zar ekranı aynı kaldı.
- Bazı metinlerin altında görünen hata ayıklama çizgileri düzeltildi.
- Hızlı yazı tura penceresi artık tamamen sessiz ve müziği, aramaları veya diğer sesleri asla kesmiyor.
</tr>

<uk>
- Кидайте монету з панелі швидких налаштувань навіть коли телефон заблокований — розблокування не потрібне.
- Прибрано ярлик кубика з панелі швидких налаштувань; екран кубика в застосунку не змінився.
- Виправлено налагоджувальні лінії, що з'являлися під деяким текстом.
- Швидке вікно монети тепер повністю беззвучне і ніколи не перериває музику, дзвінки чи інше аудіо.
</uk>
```

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml CHANGELOG.xml
git commit -m "chore(release): bump version and changelog for quick coin lockscreen/silent work"
```

---

## Task 6: Full verification, push, and PR

**Files:** none (verification + git/GitHub operations only)

- [ ] **Step 1: Run the full verification suite**

Run, in order, and confirm each is clean before proceeding:

```bash
flutter analyze
flutter test
```

If either reports a problem introduced by this branch, fix it and re-run before continuing (do not skip ahead with a red suite).

- [ ] **Step 2: Manual sanity check of key file states**

Run:

```bash
git status
git diff --stat origin/master
```

Confirm: `DiceQuickTileService.java`, `QuickActionTileService.java`, and `ic_quick_tile_dice.xml` show as deleted; `pubspec.yaml` shows only the version line changed; `CHANGELOG.xml` contains exactly the 9 locale blocks from Task 5.

- [ ] **Step 3: Push the branch**

```bash
git push -u origin claude/quick-coin-lockscreen-silent-obzgrj
```

(Retry up to 4 times with exponential backoff — 2s, 4s, 8s, 16s — only on network failure.)

- [ ] **Step 4: Open the pull request**

Title: `feat: improve locked-screen quick coin experience`

Body must cover: summary of the implementation; files/components removed (`DiceQuickTileService`, `QuickActionTileService`, `ic_quick_tile_dice.xml`, dice ARB keys); lock-screen behavior and security considerations (no `SYSTEM_ALERT_WINDOW`, no `unlockAndRun`, no new permission, PIN/biometric never bypassed); sound behavior (quick mode silent, normal mode unchanged, no audio focus/ducking in quick mode); tests executed and their results; manual testing steps for locked and unlocked devices. Check for a PR template under `.github/` before writing the body, and mirror it if present. Do not merge automatically.
