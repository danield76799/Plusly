# Plusly v1.4.9 — UnifiedPush Edition

## Breaking Changes
- **Firebase Cloud Messaging verwijderd** — Plusly gebruikt nu alleen UnifiedPush (SunUP)
- Alle FCM code is opgeruimd: `firebase_push_provider.dart`, `FcmPushService.kt`, `fcm_shared_isolate` weg
- `google-services.json` niet langer nodig (Firebase account niet meer vereist)

## New Features
- **UnifiedPush (UP) only** — stabiele push notificaties via SunUP
- **Gesplitste APKs** — aparte downloads voor 32-bit (armeabi-v7a), 64-bit (arm64-v8a), x86_64
- **AAB** voor Play Store blijft beschikbaar

## Bugfixes
- `UnifiedPush.unregister()` — positional parameter gefixt (was named param, crashed op runtime)
- Background handler `Firebase.initializeApp()` toegevoegd voor background isolates
- "Nieuw Push Systeem" toggle verwijderd uit settings (overbodig — alles is UP)
- `useFirebase` feature flag toegevoegd (default false) op main branch
- CI: `cancel-in-progress: false` — builds worden niet meer halverwege afgebroken
- CI: `flutter pub get` vóór asset generation — dependency resolving gefixt
- CI: Flutter 3.27.0 → 3.41.9 — verouderde Flutter versie opgelost
- CI: auto bump patch + build nummer met `[skip ci]`
- CI: Play Store deploy optioneel (alleen als secret bestaat)

## Build System
- **Split-per-abi**: 3 aparte APK builds i.p.v. 1 fat APK (~130MB → ~45MB elk)
- **Signing**: Nieuwe keystore gegenereerd, consistent in GitHub secrets
- **CI volledig herschreven**: stabielere workflows, minder failures
- `versions.env` opgeschoond (geen comment-regels die GITHUB_ENV breken)

---

# Plusly v1.4.1

## New Features
- **Sync Debug Screen**: New troubleshooting screen for sync/push issues with real-time logging
- **Improved Thumbnail Resolution**: Increased from 128x128 to 800x600 for clearer images

## Improvements
- **APK Downloads**: Check for updates now properly detects APK availability
- **Download Error Handling**: Improved error handling with logging and fallback to prevent blank screen crashes
- **Scheduled Messages**: Fixed to prevent duplicate sends, input bar clears after scheduling
- **Windows Build**: Added workflow_dispatch trigger for manual builds

## Fixes
- Fixed sync_debugger.dart compile errors (RoomsUpdate join is Map not List)
- Fixed playstore-vNNN tags always being newer than semver versions
- Fixed version comparison for semantic vs build tag releases
- Fixed material_design_icons_flutter incompatibility with Flutter 3.41+
- Fixed AAB downloads and release URL handling
- Fixed null check on context before accessing .mounted

## Build System
- Ruby/Fastlane setup now runs before Play Store version check
- Disabled auto-release creation in redundant build workflows
- jarsigner replaced apksigner for more reliable APK signing
- Bumped Flutter to 3.41.9
- Added REQUEST_INSTALL_PACKAGES permission for APK installation

---

# Plusly v1.4.0

## New Features
- **Live Location Sharing**: Share live location with timeout selector (5m, 15m, 30m, 1u) using MSC3489
- **Scheduled Messages**: Schedule messages to send later, with duplicate prevention

## UI/UX Improvements
- **Bottom Navigation Bar**: Redesigned with Plusly teal color (#49AFC2), 30% larger icons, optimized opacity
- **Sender Name in Chat List**: Message preview now shows sender name
- **Copy Message Option**: Restored to message context menu

## Fixes
- Fixed version comparison for playstore-N and playstore-vNNN tag formats
- Fixed playstore tags always being newer than + build tags
- Fixed Ensure check for updates always runs in debug mode

## Build System
- Dynamic version tagging in main_deploy.yml
- Support for both debug and release APK builds
- Improved keystore handling in release workflow

---

# Plusly v1.3.0

## New Features
- **Favorites Feature**: Save messages as favorites, access from dedicated Favorites tab
- **Play Store AAB Builds**: App Bundle support for Play Store uploads

## Improvements
- **Message Widget Optimization**: Added user caching to prevent unnecessary FutureBuilder rebuilds
- Improved chat scrolling performance by reducing widget rebuilds

## UI/UX
- Bottom nav bar with Plusly teal branding (#49AFC2)
- Improved theming consistency across the app

---

# Plusly v1.2.5

## Fixes
- Fixed update check compile errors - clean code
- Fixed isNewerVersion: only compare build numbers when current has +suffix
- Disabled material_design_icons_flutter (incompatible with Flutter 3.41+)

---

# Plusly v1.2.4

## Fixes
- Fixed update check - reset flag before checking

---

# Plusly v1.2.3

## New Features
- **Favorites Feature**: Add/remove favorites, view all favorited messages
- **Single FAB**: Unified floating action button across the app

---

# Plusly v1.1.5

## New Features
- **Favorites Feature**: Save messages as favorites from context menu