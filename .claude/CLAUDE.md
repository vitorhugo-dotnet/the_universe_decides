# CLAUDE.md

Guidance for Claude Code when working in this repository (a Flutter app: The Universe Decides).

## Changelog on every PR

Before finishing a pull request, add an entry to `CHANGELOG.md` under the
`## Unreleased` section.

Write the entry in every locale currently supported by the app, using the
existing `### <code>` headings in `CHANGELOG.md`:

* `en`
* `pt`
* `es`
* `de`
* `fr`
* `hi`
* `it`
* `tr`
* `uk`

These locale codes correspond to the files in `lib/l10n/app_*.arb`.

Keep every translation short, natural, and consistent with the tone and meaning
of the other languages. Do not produce awkward literal translations.

The changelog content is the single source of truth for:

* The Google Play Console "What's new" listing.
* The corresponding GitHub Release description.

Write the release note content only once in `CHANGELOG.md`. The wording must be
reused without alteration when preparing a release, although the surrounding
format may differ between GitHub and Google Play.

If the change is part of a feature that must remain hidden or undiscoverable
inside the app, such as an easter egg, do not explicitly reveal the feature in
the changelog. Use a subtle hint without spoiling it, following the tone of the
existing Entropy Drift entry.

When a release adds support for new languages, explicitly mention the newly
supported languages in every translated changelog entry.

## Google Play release notes format

When generating release notes to paste into Google Play Console, extract the
entries from the current `## Unreleased` section of `CHANGELOG.md`.

Output only the final release notes. Do not include explanations, Markdown
headings, separators, comments, or code fences.

Wrap each language in an XML-like locale block using exactly these mappings:

* `en` → `en-US`
* `pt` → `pt-BR`
* `es` → `es-ES`
* `de` → `de`
* `fr` → `fr-FR`
* `hi` → `hi`
* `it` → `it`
* `tr` → `tr`
* `uk` → `uk`

Example structure:

<en-US>
- Release note.
</en-US>

<pt-BR>
- Nota da versão.
</pt-BR>

Never use unsupported regional variants such as:

* `de-DE`
* `hi-IN`
* `it-IT`
* `tr-TR`
* `uk-UA`

Additional requirements:

1. Preserve the changelog wording exactly.
2. Preserve relevant emojis.
3. Use bullet points beginning with `-`.
4. Keep each locale block under 500 Unicode characters.
5. Include every supported locale, even when the change is small.
6. Ensure every opening locale tag has an identical closing tag.
7. Do not translate locale tags.
8. Do not omit a language because its Play Console tag differs from its Flutter
   localization code.
