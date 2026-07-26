# Versioning & versionCode convention

This document explains how Plusly's version numbers are derived and what
MUST stay consistent between the three places a version appears. Read this
before touching any version-related logic in the CI workflow or `build.gradle.kts`.

## The three places a version lives

| Source | Example | Set by |
|--------|---------|--------|
| APK `versionCode` (what the app reads at runtime) | `21008` | Flutter build (`flutter build --build-number`) |
| GitHub release tag / `plusly-version.txt` | `v1.4.17+21008` / `1.4.17+21008` | CI `main_deploy.yml` bump step |
| `pubspec.yaml` version | `1.4.17+19007` | CI bump step (the `+19007` is the "pubspec build") |

## How the numbers relate

```
pubspec build number  = X          (e.g. 19007)
release tag / txt     = X + 2000   (e.g. 21007)
APK versionCode       = X + 2000   (e.g. 21007)   ← Flutter adds +2000 internally
```

Key facts:
- Flutter's `flutter build --build-number=Y` results in an APK `versionCode`
  of **Y + 2000** on the CI runner. This +2000 offset is applied by Flutter
  itself — do NOT try to "correct" for it elsewhere.
- The CI passes the **pubspec build number** (`build_number` output of the
  bump step) to `--build-number`. Flutter then produces the matching
  `versionCode = X + 2000`, which equals the release tag automatically.

## Why this is the way it is (history)

An earlier version of the workflow did BOTH of these:
1. `android_build_number = NEW_BUILD + 2001`  (for the tag / txt)
2. passed `android_build_number` to `--build-number`

Because Flutter also adds +2001 (actually +2000 on this runner — see below),
the APK ended up higher than the tag, while the tag was only
`NEW_BUILD + 2001`. The app then reported a version higher than the release,
causing a permanent "update available" loop where users could never satisfy
the updater.

The actual Flutter offset on the CI runner is **+2000**, not +2001. The
current setup uses `android_build_number = NEW_BUILD + 2000` and passes the
raw pubspec build to `--build-number`, so Flutter's +2000 makes the APK
versionCode exactly equal the tag/txt.

## Rules — DO NOT BREAK THESE

1. In `main_deploy.yml`, the `flutter build` commands MUST use:
   `--build-number=${{ steps.bump.outputs.build_number }}`
   (the pubspec build, NOT `android_build_number`).
2. The release tag and `plusly-version.txt` MUST use
   `android_build_number` (= `build_number + 2000`).
3. Never pass `android_build_number` to `--build-number` — that double-counts
   the offset and reintroduces the update loop.
4. The Flutter internal offset is **+2000** on the CI runner. If you change
   `android_build_number` to a different offset, also verify the APK
   `versionCode` with `aapt dump badging` after a build — it must equal the
   release tag, or the update loop returns.
5. If you change the offset math, bump the pubspec build high enough that the
   new APK `versionCode` is GREATER than any version already installed by
   users, otherwise Android will refuse the "downgrade" and the update fails
   to install.

## How to verify after a change

After any version-related CI change, install the new build and confirm:
- Settings → About shows the same number as the GitHub release tag.
- No spurious "update available" prompt appears when you are on the latest.
- `plusly-version.txt` on `main` equals the latest release tag.
