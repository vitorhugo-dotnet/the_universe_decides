# F-Droid distribution

The Android project has two distribution flavors:

- `play`: includes Google Play Games Services for achievements and leaderboards.
- `fdroid`: contains no Google Play Services dependency and keeps the minigame fully playable offline.

## Local builds

```bash
flutter pub get
flutter build apk --release --flavor play
flutter build apk --release --flavor fdroid
```

The F-Droid APK is generated at:

```text
build/app/outputs/flutter-apk/app-fdroid-release.apk
```

## Inclusion notes

- Source license: MIT.
- Application ID: `com.hugo.theuniversedecides`.
- The F-Droid build must remove the `play` source set and the `playImplementation` dependency before scanning.
- Random.org is an optional non-free network service. The app keeps a local randomness fallback, but the F-Droid metadata should declare the `NonFreeNet` anti-feature.
- F-Droid builds and signs its own APK. Do not submit the Play Store APK.

## Submission flow

1. Merge the F-Droid preparation pull request.
2. Regenerate and commit `pubspec.lock` with Flutter 3.38.1.
3. Replace the commit placeholder in `fdroid/metadata-template.yml` with the merged commit SHA or release tag.
4. Fork `fdroid/fdroiddata` on GitLab.
5. Copy the template to `metadata/com.hugo.theuniversedecides.yml` in the fork.
6. Run `fdroid readmeta`, `fdroid lint com.hugo.theuniversedecides`, and `fdroid build -v -l com.hugo.theuniversedecides`.
7. Open a merge request to `fdroid/fdroiddata`.

The upstream GitHub issue should remain open until the fdroiddata merge request is accepted and the app appears in the official repository.
