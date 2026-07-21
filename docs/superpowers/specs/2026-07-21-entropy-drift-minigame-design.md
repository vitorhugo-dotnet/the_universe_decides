# Entropy Drift Minigame (Easter Egg) Design

Closes #21.

## Goal

Add a hidden, offline, optional minigame ("Entropy Drift") as an easter egg, reachable only through a secret gesture, without touching the existing decision flows or adding any visible hint in the main UI.

## Unlock Gesture

`RitualHeader` gains a small decorative glyph (star/moon) before the eyebrow text on every screen. A Riverpod `Notifier` (`entropyDriftUnlockProvider`) counts taps on that glyph: 7 taps within a rolling window (gap ≤ 1.5s between taps) triggers unlock. A slower tap resets the counter to 1 (the tap itself still counts as a fresh start) rather than to 0. On the 7th tap, the glyph plays a brief pulse/glow animation and the app navigates to the game screen via `Navigator.push` (`MaterialPageRoute(fullscreenDialog: true)`), independent of the `MainScreen`'s `IndexedStack`, so back navigation returns instantly to whichever tab was active.

The glyph carries no label or tooltip and is styled as part of the mystical theme (matches `AppColors` tokens already in use) so it reads as decoration, not a control.

## Game Module (`lib/minigame/`)

- `entropy_drift_game.dart` — `FlameGame` subclass owning the game loop: spawns `BlackHoleComponent` and `FragmentComponent` from screen edges at an interval that shortens over time, moves them across the play field, increases their speed on a difficulty timer, and tracks elapsed survival time.
- `components/player_star_component.dart` — the controlled star. A `PanDetector`-equivalent input on the game (via `HasDraggables`/drag callbacks) moves the star to the drag position, clamped to the play field bounds.
- `components/black_hole_component.dart` — obstacle; circular collider, colliding with the star ends the game.
- `components/fragment_component.dart` — collectible; circular collider, colliding with the star removes it, adds score, and plays a small particle burst.
- `entropy_drift_screen.dart` — hosts `GameWidget<EntropyDriftGame>`, a score HUD overlay during play, and a game-over overlay (message "The universe has decided.", final score, current high score, "Jogar novamente" / "Voltar" buttons).
- `entropy_drift_high_score_service.dart` — `Notifier<int>` over `SharedPreferences` (key `entropy_drift_high_score`), same pattern as `SoundEffectsNotifier`: loads on build, exposes `submitScore(int)` which persists only when the new score is higher.

All visuals are drawn procedurally (Flame `Paint`/gradients/`ParticleSystemComponent`) — no new image assets — to keep the app size impact minimal per the issue's acceptance criteria.

## Scoring & Difficulty

- Score = 1 point per 0.5s survived + 5 points per fragment collected.
- Every 10s survived, obstacle/fragment spawn interval decreases and movement speed increases, up to a capped maximum so the game stays winnable-feeling rather than instantly punishing.

## Audio & Haptics

Reuses the existing `soundEffectsProvider` (About screen toggle) to gate any in-game sound effects, and Flutter's built-in `HapticFeedback` (already used for dice rolls) for collision/collection feedback. No new audio or vibration dependency; both already respect device/system settings.

## Dependency

Add `flame` (latest version compatible with the project's Flutter 3.44 / Dart ^3.10 constraints) to `pubspec.yaml`.

## Testing

- `entropy_drift_unlock_provider_test.dart` — 7 taps within the window unlocks; slow taps reset the streak; fewer than 7 taps does not unlock.
- `entropy_drift_high_score_service_test.dart` — persists a new high score, ignores a lower score, loads a previously persisted value.
- No dedicated tests for Flame's internal game-loop physics/rendering — out of scope per the issue's own suggested technical tasks, which call out only unlock and persistence testing.

## Out of Scope (per issue)

Unity integration, multiplayer, online ranking, authentication, backend, purchases/ads/external rewards, complex 3D mechanics, and any change to existing draw/decision behavior.
