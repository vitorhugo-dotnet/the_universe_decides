# CLAUDE.md

Guidance for Claude Code when working in this repository (a Flutter app: The Universe Decides).

## Changelog on every PR

Before finishing a pull request, add an entry to `CHANGELOG.md` under an
`## Unreleased` section, written in every locale the app supports (see the
`### <code>` headings already in the file — currently en, pt, es, de, fr, hi,
it, tr, uk, matching `lib/l10n/app_*.arb`). Keep each language's entry short
and consistent in tone with the existing entries.

This same changelog text is what gets pasted into the Google Play "What's
new" listing for each locale and into the GitHub Release description when a
release is cut — write it once, here, so it can be reused as-is for both.

If a change is part of a feature that must stay hidden or undiscoverable in
the app itself (an easter egg, for example), do not describe it explicitly
in the changelog — write something that hints without spoiling it, the way
the "Unreleased" entry for the Entropy Drift minigame does.
