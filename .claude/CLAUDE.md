# CLAUDE.md

Guidance for Claude Code when working in this repository (a Flutter app: The Universe Decides).

Before making changes, read and follow the repository-wide instructions in
`/AGENTS.md`, especially the CI path-filter policy, semantic versioning policy,
changelog policy, and F-Droid release procedure.

## Application version name

Before finishing any application `feat`, `fix`, or `refactor`, increment the
semantic version name in `pubspec.yaml` exactly once:

```yaml
version: <major>.<minor>.<patch>+<buildNumber>
```

Choose the increment according to the change:

* `MAJOR` for incompatible or breaking application changes.
* `MINOR` for backward-compatible features or new user-facing capabilities.
* `PATCH` for backward-compatible fixes, refactors, performance improvements,
  or internal application changes.

When multiple categories apply, use the highest applicable level and reset the
lower components according to Semantic Versioning.

Change only the `MAJOR.MINOR.PATCH` portion. Preserve the value after `+`
exactly as it is. Never manually increment or replace the build number because
CI/CD owns it.

Do not increment the semantic version for documentation-only, test-only,
CI/workflow-only, changelog-only, or agent-instruction-only changes that do not
modify the application.

## Changelog for user-visible changes

Before finishing any user-visible `feat`, `fix`, or `refactor`, rewrite
`CHANGELOG.xml`.

Remove all previous release-note content and replace it with notes only for the
current change. Never append new notes to old notes. Documentation, tests,
chore-only changes, and internal refactors with no user-visible impact do not
require release notes.

`CHANGELOG.xml` is the single source of truth and must be ready to copy and
paste directly into the Google Play Console production release notes field.
Do not create or maintain a Markdown changelog.

Include every locale currently supported by the app, using exactly these Play
Console tags and this order:

* `en-US`
* `pt-BR`
* `es-ES`
* `de`
* `fr-FR`
* `hi`
* `it`
* `tr`
* `uk`

These tags correspond to the files in `lib/l10n/app_*.arb`.

Use this exact structure:

<en-US>
- Release note.
</en-US>

<pt-BR>
- Nota da versão.
</pt-BR>

Keep every translation short, natural, and consistent in meaning. Do not
produce awkward literal translations.

Additional requirements:

1. Use bullet points beginning with `-`.
2. Keep each locale block under 500 Unicode characters.
3. Include every supported locale, even for a small change.
4. Ensure every opening locale tag has an identical closing tag.
5. Do not translate locale tags or use unsupported regional variants such as
   `de-DE`, `hi-IN`, `it-IT`, `tr-TR`, or `uk-UA`.
6. Preserve relevant emojis.
7. If a feature must remain hidden, such as an easter egg, use a subtle hint
   without revealing it.
8. When adding languages, mention the newly supported languages in every locale.

## GitHub Release format

The CI/CD workflow converts `CHANGELOG.xml` into Markdown for the GitHub
Release by replacing each opening locale block with a `### <locale>` heading,
removing the closing tags, and preserving the localized bullets. Do not write
or append a separate Markdown version manually.
