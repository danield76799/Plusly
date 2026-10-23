# Plusly v1.4.17+23515

## Push-notificaties
- **Stabiele notificaties bij pushes** — 6 kleine afwijkingen hersteld: volgorde foreground-check / push-rule filter / badge, titel/body die de conversation view overschreven, MessagingStyle-eigenaar (nu lokale gebruiker), actieknoppen alleen bij bericht-types, mute semantic action en `client_name` schrijven/vergelijken.
- **Geen dubbele meldingen meer** — fallback-notificatie (`openAppToReadMessages`) verwijderd waar die dubbelde met MessagingStyle, en duplicate-check in `MessagingStyle` gefixt (`notificationBody`-scope en null-safety).
- **Geen crash op koude start** — `PushruleEvaluator.match` crasht bij `userID == null` (Null check operator); nu gewrapt met `if (userID == null) skip` + try/catch met fallback `notify=true` en logging.
- **Filtering correct** — eigen Matrix-berichten en events zonder room-context worden stil onderdrukt i.p.v. als fallback te tonen.
- **Foreground-service stabiel** — rollback `flutter_foreground_task` 11.x → 10.x tegen regressie van de “Berichten laden”-placeholder; watchdog en `reconcileOnForegroundStart` blijven actief.

## Geplande berichten
- **Nieuw:** `/schedule` en “Gepland verzenden” via attach-menu met datum/tijd-picker, emoji-veilige input, WorkManager/storage en lijst met annuleren.
- Meerdere fixes: clear persisted draft na plannen, aggressive init flush verwijderd (voorkwam onterechte logout), WorkManager-isolate gedropt i.v.m. SQLite-lock, fallback non-blocking bij foreground.

## Theming
- **Custom accent color picker** (HSV + hex + L10n) in appearance settings.

## Dependencies & Build
- Flutter 3.47.7 behouden; `dynamic_color` 1.8.1→2.1.0 (Kotlin 2.x compat), daarna pins voor Dart 3.10 compat; `receive_sharing_intent` 1.8.1; `unifiedpush` 6.1.0 / `unifiedpush_android` 3.1.1; Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20 voor CI.

## Store-teksten
- Play Store en-US/nl-NL: “100 seats interne test”-framing verwijderd; korte omschrijvingen nu met keywords *Matrix, WhatsApp & Telegram bridges, multi-account, scheduling*.

---

# Plusly v1.4.17+23497

## Dependencies
- **Upgraded Flutter to 3.47.7 (Dart 3.13.5).** The previous version was
  3.41.9 / Dart 3.11.5. This unlocks newer package versions that require
  Dart 3.12+ and brings the latest engine, tooling and platform fixes.
- **Major dependency upgrades across the board.** 189 packages updated via
  `flutter pub upgrade`, including:
  - `flutter_foreground_task` 10.0.0 → 11.0.3 — adds Kotlin Gradle Plugin
    (KGP) migration and Swift Package Manager support; resolves long-standing
    foreground-service reliability issues on Android.
  - `flutter_new_badger` 1.1.1 → 2.0.0 — app-icon badge support refreshed.
  - `record` 6.2.1 → 7.1.2 — audio recording API updated (required
    `record_linux` override bump to ^2.1.3 for compatibility).
  - `flutter_secure_storage` 10.0.0 → 11.2.0 — improved platform backends.
  - `flutter_webrtc` 1.4.1 → 1.6.2 — WebRTC stability and feature updates.
  - `go_router` 17.1.0 → 18.1.0 — routing fixes and improvements.
  - `permission_handler` 12.0.1 → 13.0.2 — Android 14/15 permission handling.
  - `share_plus` 12.0.1 → 14.x — share sheet updates.
  - `image` 4.8.0 → 4.12.0 — image processing improvements.
  - `wakelock_plus` 1.4.0 → 1.8.1 — wake-lock reliability.
- **API breaking changes resolved** (20 compile errors fixed):
  - `PowerLevel` is now an extension type wrapping `int`. All comparisons
    now use `.level` (e.g. `powerLevel.level >= 100`). Affected: chat
    member lists, participant items, member action menus, and chat
    forwarding dialogs.
  - `reportEvent()` no longer accepts a `score` parameter in the Matrix
    SDK. The offensiveness-level prompt was removed from the report flow;
    reports now send only the reason text.
  - `joinRoom()` parameter renamed `serverName` → `via` (3 call sites in
    URL launcher updated).
  - `MatrixLocals.unknownEvent()` now takes `(senderName, typeKey)` instead
    of just `(typeKey)` — localized unknown-event messages now show the
    actual sender name.

## Notifications
- **Fixed missing `notificationDismissed` case** in the notification tap
  handler. `flutter_local_notifications` v22 added this enum value; the
  switch is now exhaustive.
- **Screen wakes on push notifications.** `fullScreenIntent: true` is set
  on message notifications, and `requestFullScreenIntentPermission()` is
  called at initialisation — Android 14+ requires explicit user approval
  for full-screen intents, without which the screen stays off.
- **Eliminated the persistent "Berichten laden" (Loading messages)
  notification.** Root cause was a foreground service started before
  client initialisation that was only stopped in a `finally` block — if
  initialisation hung or the process was killed, the service (and its
  notification) stayed forever. Two safety nets now prevent this:
  - A 30-second watchdog timer that force-stops the service if the push
    pipeline doesn't complete in time.
  - `reconcileOnForegroundStart()` — called immediately on foreground
    entry, before heavy initialisation — detects and stops any stale
    service left over from a previous lifecycle.

## Chat
- **Blue read receipts (WhatsApp-style).** Read messages now show a blue
  double-tick (`readReceiptBlue` from the theme) instead of hardcoded
  green. Sending (clock) and error (warning) states keep their own icons
  and colors. Applies to all three message bubble layouts (modern,
  default, legacy).
- **Refreshed chat UI contrast and typography.** 60% black dim-overlay
  over the wallpaper for readability; status line truncates with ellipsis
  instead of marquee; fixed WhatsApp-style dark-theme bubble colors
  (`#005C53` outgoing, `#1E2225` incoming); capsule-shaped input field
  with `#005C53` accent send button; semi-transparent timestamp overlay
  on image bubbles.
- **Send button redesigned** to a ton-sur-ton circular style: teal
  background (`#1B6E64`-ish) with darker teal icon (`#0F3D37`-ish),
  `Icons.send_rounded`, circular splash feedback.

## Chat List
- **Fixed tab bar jumping to the left.** The scrollable tab bar
  (`All`, `Unread`, `Groups`, `Pinned`, `Favorites`) rebuilt and
  re-animated on every state change, causing it to snap back to the
  start. The tab controller is now reused, unnecessary rebuilds are
  reduced, and a `PageStorageKey` preserves the tab index across
  rebuilds.

## Code Quality
- **All tests green: 183/183 pass.** Previously 2 tests failed in
  `read_receipt_blue_test.dart` due to hardcoded colors — now fixed.
- **Reduced `flutter analyze` warnings from 59 to 50.** Removed unused
  imports, dead code, unnecessary null-checks, and unused variables in:
  `sync_debugger.dart`, `llm_service.dart`, `timeline_cache.dart`,
  `new_private_chat_view.dart`, `notifications_view.dart`,
  `bridge_utils.dart`, `favorites_page.dart`, and test files.
- **Removed duplicate CI workflow** (`.github/workflows/build-release.yml`
  was a duplicate of `main_deploy.yml`).

## Matrix SDK
- **Evaluated the ExteraApp matrix-dart-sdk fork** (v8.1.0 + 50 commits
  ahead of upstream). The fork adds security-incident tracking, SSSS
  wipe, and key-rotation detection not yet in upstream v14. Migration to
  upstream v14 is planned as a separate project (requires API migration
  and sqlite3 v2→v3 upgrade). The fork remains active for now.

## Infrastructure
- **CI/CD pipeline verified.** GitHub Actions builds and publishes
  releases automatically on push to `main`. Latest release:
  v1.4.17+23497.

---

# Plusly v1.4.17+23437

## Notifications
- **Rewrote the push pipeline so notifications survive a cold start.** Android
  can tear down a headless process while a push is still being handled — the
  distributor logs the message as delivered, but the app processes nothing and
  dies quietly. A foreground service now starts *before* the Matrix clients are
  initialised, so the entire cold-start window is protected rather than only its
  tail. A missing lifecycle state is also treated as a cold start; previously
  that case was never detected at all and night-time pushes were silently lost.
- **Notification content and ordering now match the reference behaviour.**
  Six separate deviations were corrected: the order in which the foreground
  check, the push-rule filter and the badge are evaluated; title/body being sent
  separately on Android (which overwrote the conversation view and broke message
  stacking); the MessagingStyle owner being the sender instead of the local
  user; action buttons appearing on event types where "Reply" has no meaning;
  the mute action missing its semantic action; and the pusher's `client_name`
  not being written and compared.
- **Fixed push re-registration after re-login.** A stale client could report
  `endpoint=saved` while registration had in fact failed, which blocked a forced
  re-setup — so the new session never registered and push failed silently. The
  registration flow is now the shared one instead of hand-rolled bookkeeping.
- **Restored the push diagnostic log**, which had been lost during an earlier
  rollback. It merges its in-memory buffer with what is on disk before writing,
  so a screen copied after a restart still shows the earlier history. Without it
  a delivered-but-unprocessed push was indistinguishable from one never sent.
- **Fixed a false `registered=false`** in the status screen. A migration wrote
  the default value into the per-client key whenever the global key was absent,
  so the flag reported failure while push was working. The flag is diagnostic
  only and never gated behaviour, but it made every dump misleading.

## Chat
- **Location sharing renders a real map again.** Two independent faults: a
  "compact" pass had shrunk the card to a flat strip by dropping the aspect-ratio
  wrapper while halving its height, and underneath that the card collapsed to a
  single pixel because the map widget cannot answer the intrinsic-width query
  that the chat bubble issues. Both are fixed; the card is square and tappable
  in every context.
- **Font size now scales across the whole app**, not just the chat. The setting
  under Settings → Style previously applied to chat messages only, so the rest
  of the interface stayed the same size and the setting looked half-applied. It
  now scales Settings, lists, dialogs and buttons too, and changing it takes
  effect immediately without a restart.
- **Quick reactions** — tap and hold a message for an inline reaction bar.
- **"New messages" divider** shown at the last-read message.
- **Read-state ticks** — two green ticks for read, one orange tick for sent.
- **Swiping a message** now opens the reply composer.

## Removed
- **"Send later" has been removed.** Scheduled messages were unreliable on
  several counts: the server-side route sent the message immediately instead of
  deferring it, the local fallback fired for messages still in the future, and
  cancelling failed on every server. The server-side route also skipped
  end-to-end encryption for encrypted rooms, which is not patchable without
  rebuilding the SDK's encryption on a raw request. The feature is gone rather
  than half-working.

## Build System
- **Release tags now point at the commit the APK was actually built from.** The
  release step attached the tag to the branch tip at publication time, which
  happens well after the build starts — so a tag could name newer code than the
  binary it labelled, making release verification meaningless. The tag is now
  pinned to the built commit and verified against the remote before publishing.

## Known Issues
- The cold-start fix is verified in code and covered by tests, but has not yet
  been confirmed on a device over a full night cycle.
- Smart reply suggestions were evaluated and withdrawn; Dutch output quality was
  not good enough to ship.

---

# Plusly v1.4.17

## Chat & Berichten
- **Verstuurde foto's verschijnen nu direct in de tijdlijn** — voorheen verscheen
  een verstuurde afbeelding pas in de chat nadat je die opnieuw opende. De
  tijdlijn ververscht nu bij het verzenden, via een post-frame `updateView`.
- **Chat-UI herontworpen (WhatsApp-dichtheid)**
  - Bubbels maximaal 75% van de schermbreedte, met strakkere groepeer-marges van
    2px/8px.
  - Inkomende berichten tonen een avatar-goot; uitgaande berichten staan rechts
    uitgelijnd.
  - Afbeeldingen lopen van rand tot rand in de bubbel; tijdstempels staan inline
    rechtsonder bij het laatste bericht van een reeks.
  - Uniforme Material-bubbel met een harde linker-/rechterbovenhoek bij het
    eerste bericht van een groep (staart), elders afgerond.

## In-app-updater
- **Fatale crash bij het installeren van een APK-update verholpen** — de
  installatiestap gooide een niet-afgevangen `Exception` (permission denied /
  `OpenFile`-fout) op het scherm met 100% download. Fouten worden nu opgevangen
  en als SnackBar getoond.
- **`REQUEST_INSTALL_PACKAGES` gedeclareerd** in `AndroidManifest.xml`, zodat de
  in-app-updater daadwerkelijk installatierechten kan aanvragen.
- **Fijnmazige terugval bij installatierechten** — als de gebruiker de rechten
  weigert, opent een SnackBar de systeempagina "Onbekende apps installeren" voor
  Plusly, zodat diegene het kan aanzetten en het opnieuw kan proberen.
- **Betrouwbare update-detectie** — de GHA schrijft `plusly-version.txt` en de
  release-tag nu met dezelfde `+2000`-offset die de gebouwde APK rapporteert,
  zodat "Controleren op updates" niet langer onterecht "al de nieuwste" meldt.

## Buildsysteem
- **Android Jetifier uitgeschakeld** (`android.enableJetifier=false`) — die
  dwong een `JetifyTransform` af op de Flutter native-lib JAR's, waardoor de
  GHA-runner een OOM kreeg (`Java heap space` in `mergeReleaseNativeLibs`).
  Heap verhoogd naar `-Xmx4g`.
- Split-per-ABI APK's (arm64-v8a, armeabi-v7a) en AAB-builds zijn nu stabiel.

---

# Plusly v1.4.9 — UnifiedPush Edition

## Breaking changes
- **Firebase Cloud Messaging verwijderd** — Plusly gebruikt nu alleen UnifiedPush (SunUP)
- Alle FCM-code is opgeruimd: `firebase_push_provider.dart`, `FcmPushService.kt`, `fcm_shared_isolate` weg
- `google-services.json` niet langer nodig (Firebase-account niet meer vereist)

## Nieuwe functies
- **Alleen UnifiedPush (UP)** — stabiele pushnotificaties via SunUP
- **Gesplitste APK's** — aparte downloads voor 32-bit (armeabi-v7a), 64-bit (arm64-v8a), x86_64
- **AAB** voor de Play Store blijft beschikbaar

## Opgeloste fouten
- `UnifiedPush.unregister()` — positional parameter gefixt (was een named param, crashte op runtime)
- Background handler `Firebase.initializeApp()` toegevoegd voor background-isolates
- "Nieuw Push Systeem"-toggle verwijderd uit de instellingen (overbodig — alles is UP)
- `useFirebase`-feature flag toegevoegd (default false) op de main-branch
- CI: `cancel-in-progress: false` — builds worden niet meer halverwege afgebroken
- CI: `flutter pub get` vóór asset-generatie — dependency-resolving gefixt
- CI: Flutter 3.27.0 → 3.41.9 — verouderde Flutter-versie opgelost
- CI: auto bump patch + buildnummer met `[skip ci]`
- CI: Play Store-deploy optioneel (alleen als het secret bestaat)

## Buildsysteem
- **Split-per-abi**: 3 aparte APK-builds i.p.v. 1 fat APK (~130MB → ~45MB elk)
- **Signing**: nieuwe keystore gegenereerd, consistent in GitHub-secrets
- **CI volledig herschreven**: stabielere workflows, minder failures
- `versions.env` opgeschoond (geen commentaarregels die GITHUB_ENV breken)

---

# Plusly v1.4.1

## Nieuwe functies
- **Sync-debugscherm**: nieuw probleemoplossingsscherm voor sync- en pushproblemen, met realtime logging
- **Betere thumbnails**: verhoogd van 128x128 naar 800x600 voor duidelijkere afbeeldingen

## Verbeteringen
- **APK-downloads**: "Controleren op updates" detecteert nu goed of er een APK beschikbaar is
- **Foutafhandeling bij downloads**: betere foutafhandeling met logging en terugval, om crashes met een leeg scherm te voorkomen
- **Geplande berichten**: gefixt om dubbele verzending te voorkomen; de invoerbalk wordt leeggemaakt na het plannen
- **Windows-build**: workflow_dispatch-trigger toegevoegd voor handmatige builds

## Opgeloste fouten
- Compileerfouten in sync_debugger.dart gefixt (RoomsUpdate join is Map, geen List)
- playstore-vNNN-tags waren altijd nieuwer dan semver-versies — gefixt
- Versievergelijking voor semantische versus build-tag-releases gefixt
- Incompatibiliteit van material_design_icons_flutter met Flutter 3.41+ gefixt
- AAB-downloads en release-URL-afhandeling gefixt
- Null-check op context vóór toegang tot .mounted gefixt

## Buildsysteem
- Ruby/Fastlane-setup draait nu vóór de Play Store-versiecheck
- Automatische release-creatie uitgeschakeld in overbodige build-workflows
- jarsigner vervangt apksigner voor betrouwbaardere APK-ondertekening
- Flutter bijgewerkt naar 3.41.9
- REQUEST_INSTALL_PACKAGES-recht toegevoegd voor APK-installatie

---

# Plusly v1.4.0

## Nieuwe functies
- **Live locatie delen**: deel je live locatie met een time-outkeuze (5m, 15m, 30m, 1u) via MSC3489
- **Geplande berichten**: plan berichten om later te versturen, met bescherming tegen dubbele verzending

## UI/UX-verbeteringen
- **Onderste navigatiebalk**: herontworpen met Plusly-teal (#49AFC2), 30% grotere iconen, geoptimaliseerde opacity
- **Naam van de afzender in de chatlijst**: het berichtvoorbeeld toont nu de afzender
- **Bericht kopiëren**: terug in het contextmenu van berichten

## Opgeloste fouten
- Versievergelijking voor playstore-N- en playstore-vNNN-tagformaten gefixt
- playstore-tags waren altijd nieuwer dan +-buildtags — gefixt
- "Controleren op updates" draaide altijd in debug-modus — gefixt

## Buildsysteem
- Dynamische versietagging in main_deploy.yml
- Ondersteuning voor zowel debug- als release-APK-builds
- Betere keystore-afhandeling in de release-workflow

---

# Plusly v1.3.0

## Nieuwe functies
- **Favorieten**: bewaar berichten als favoriet, met een eigen tabblad
- **Play Store AAB-builds**: App Bundle-ondersteuning voor Play Store-uploads

## Verbeteringen
- **Optimalisatie van de berichtwidget**: gebruikerscache toegevoegd om onnodige FutureBuilder-rebuilds te voorkomen
- Betere chat-scrollprestaties door minder widget-rebuilds

## UI/UX
- Onderste navigatiebalk met Plusly-teal branding (#49AFC2)
- Consistentere theming door de hele app

---

# Plusly v1.2.5

## Opgeloste fouten
- Compileerfouten in de updatecheck gefixt — schone code
- isNewerVersion gefixt: vergelijk buildnummers alleen als de huidige een +suffix heeft
- material_design_icons_flutter uitgeschakeld (incompatibel met Flutter 3.41+)

---

# Plusly v1.2.4

## Opgeloste fouten
- Updatecheck gefixt — flag resetten vóór het controleren

---

# Plusly v1.2.3

## Nieuwe functies
- **Favorieten**: favorieten toevoegen en verwijderen, alle favoriete berichten bekijken
- **Eén FAB**: één uniforme floating action button door de hele app

---

# Plusly v1.1.5

## Nieuwe functies
- **Favorieten**: berichten opslaan als favoriet vanuit het contextmenu