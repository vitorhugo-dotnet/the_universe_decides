# Google Play Games configuration

Entropy Drift authenticates with Google Play Games only after its screen has
opened. Keep `SUPPRESS_GAME_PROFILE_CREATION` in the Android manifest so normal
app startup does not invite the user to create a game profile.

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
play or the local high score. Configure Android OAuth clients for both the Play
App Signing SHA-1 and the debug keystore SHA-1, add tester accounts, and publish
the Play Games Services configuration separately from the app release.

Before release, verify on real devices that cold start, ordinary navigation,
and app restore show no Play Games UI. Also verify that opening Entropy Drift is
the first point at which authentication can appear, and that devices without
Play Games continue to run the minigame offline.
