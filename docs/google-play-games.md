# Google Play Games configuration

Entropy Drift authenticates with Google Play Games only after its screen has
opened. Keep `SUPPRESS_GAME_PROFILE_CREATION` in the Android manifest so normal
app startup does not invite the user to create a game profile.

## Application ID

The configured Google Play Games Services numeric project ID is
`595881887646`. In Play Console, open **Grow users > Play Games Services >
Setup and management > Configuration** and use the numeric **Project ID** shown
for the linked cloud project. This is not an OAuth client ID, Android package
name, achievement ID, or leaderboard ID.

Android maps this value through
`android/app/src/main/res/values/games-ids.xml` as
`@string/game_services_project_id`. The `<application>` element in
`AndroidManifest.xml` then assigns that resource to the
`com.google.android.gms.games.APP_ID` metadata entry.

## Android application classification

The app is primarily a productivity and decision-making utility for random
selections. Entropy Drift is a secondary hidden feature, and integrating Play
Games Services for that feature does not require classifying the entire Android
application as a game.

The main manifest therefore sets `android:appCategory="productivity"` as a
best-effort signal to Android and device manufacturers. The Play Games APP_ID,
achievements, leaderboard, and delayed authentication remain enabled. The
deprecated `android:isGame` attribute is not set; its default is already false.

This signal is not a guarantee. OEM launchers, Samsung Gaming Hub, and similar
services can apply their own classification heuristics beyond Flutter or the
Android manifest. Keep the primary Play Console listing categorized as an app
under Tools or Productivity rather than as a game, and verify behavior on the
target devices.

## Play Console configuration

Create the hidden achievements and high-score leaderboard in Play Console,
then provide their generated IDs when building the Android app:

```sh
flutter build appbundle \
  --dart-define=PLAY_GAMES_ENTROPY_DISCOVERED_ID=... \
  --dart-define=PLAY_GAMES_FIRST_DRIFT_ID=... \
  --dart-define=PLAY_GAMES_SURVIVOR_30S_ID=... \
  --dart-define=PLAY_GAMES_FRAGMENT_COLLECTOR_ID=... \
  --dart-define=PLAY_GAMES_ENTROPY_MASTER_ID=... \
  --dart-define=PLAY_GAMES_ENTROPY_LEADERBOARD_ID=...
```

An omitted ID disables that individual online feature without affecting local
play or the local high score.

Configure separate Android OAuth credentials as needed for each signing
certificate:

- **Play App Signing SHA-1:** the certificate Google Play uses to sign builds
  delivered from Play. Copy it from **Release > Setup > App integrity** in Play
  Console; it is normally different from the upload-key certificate.
- **Debug SHA-1:** the certificate belonging to the local debug keystore, used
  for builds installed with `flutter run` or a debug APK. Obtain it with the
  Gradle `signingReport` task and register it for local testing only.

Add test accounts to the Play Games Services **Testers** list. Play Store
internal, closed, or open-track testers are not automatically Play Games
Services testers. After configuring credentials, achievements, and
leaderboards, publish the Play Games Services configuration separately; making
an app release available on a Play Store track does not publish that
configuration.

## Real-device validation

Use a real Android device with Google Play Services and a tester account:

1. Install a build whose signing SHA-1 is registered in the matching Android
   OAuth credential.
2. Cold-start the app and navigate normally. Confirm no Play Games prompt or UI
   appears during startup, restore, or ordinary navigation.
3. Open the hidden experience and confirm that this is the first point where
   authentication is attempted. Google Play Games Services v2 can authenticate
   silently, so no welcome popup does not by itself indicate failure.
4. Complete a local run, restart the app, and confirm local gameplay and the
   local high score still work even if the device is offline or Play Games is
   unavailable.
5. With achievement and leaderboard IDs supplied, verify each configured
   online operation. An omitted ID should disable only its corresponding
   operation.

## Troubleshooting

Debug builds emit non-sensitive messages tagged `EntropyDriftPlayGames` when
sign-in, authentication verification, APP_ID/project configuration, or an
online operation fails. No tokens, account details, or resource IDs are logged.
Capture and filter Android logs while opening the hidden experience:

```sh
adb logcat -c
adb logcat | grep -E 'EntropyDriftPlayGames|GamesSignIn|GoogleSignIn|PlayGames'
```

For a sign-in failure, check that the device account is a Play Games Services
tester, the configuration is published, networking and Google Play Services
are available, and the installed build's signing SHA-1 matches its Android
OAuth credential. For a configuration or unauthenticated result, also verify
that the manifest resolves `com.google.android.gms.games.APP_ID` to
`@string/game_services_project_id`, that the value is `595881887646`, and that
the OAuth credential uses the correct package name. Missing achievement or
leaderboard build-time IDs are reported separately and do not disable local
play or unrelated online features.
