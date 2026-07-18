# Decision Sounds Design

## Goal

Provide a brief, optional confirmation sound after every completed decision.

## Design

`SoundEffectsService` owns the persisted enabled flag and one audio player. It configures the player to respect silent mode and device volume, ignores playback failures, and skips a request while the previous sound is active. Each decision screen calls it only after its result and any reveal animation have completed. The About screen exposes the localized preference.

## Scope

Coin, dice, playing-card, list, and tarot decisions use one short bundled sound. The preference defaults to enabled and persists between launches. Tests cover preference persistence and no-overlap behavior.
