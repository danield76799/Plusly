# Plusly App - Code Analyse Rapport

## Overzicht
Plusly is een Matrix client app gebaseerd op Extera Next/FluffyChat. Het is een complexe Flutter app met veel features.

## Gevonden Issues

### 1. **Push Notifications Problemen** 🔴
- **Bestand:** `lib/utils/background_push.dart`
- **Probleem:** De code heeft veel workarounds voor UnifiedPush en Firebase
- **Impact:** Push notificaties werken mogelijk niet betrouwbaar
- **Details:**
  - UnifiedPush integratie is complex en heeft veel edge cases
  - Firebase code is uitgecommentarieerd maar nog steeds aanwezig
  - Badge updates op iOS zijn een workaround

### 2. **Memory Management** 🟡
- **Bestand:** `lib/utils/client_manager.dart`
- **Probleem:** Clients worden niet altijd correct opgeschoond
- **Impact:** Mogelijke memory leaks bij langdurig gebruik
- **Details:**
  - `clientNames` set wordt niet altijd gesynchroniseerd met daadwerkelijke clients
  - Multi-account cleanup is niet waterdicht

### 3. **Database Initialisatie** 🟡
- **Bestand:** `lib/utils/init_with_restore.dart` (niet bekeken maar wel aangeroepen)
- **Probleem:** Database migratie kan lang duren zonder feedback
- **Impact:** App lijkt "vast" te zitten bij eerste opstart

### 4. **Error Handling** 🟡
- **Bestand:** `lib/main.dart`
- **Probleem:** Fatal errors worden afgevangen maar niet gelogd naar externe service
- **Impact:** Crashes zijn moeilijk te debuggen in productie

### 5. **Netwerk Timeouts** 🟡
- **Bestand:** `lib/utils/client_manager.dart`
- **Probleem:** `defaultNetworkRequestTimeout` is 30 minuten
- **Impact:** Te lang voor de meeste operaties, kan UI laten hangen

### 6. **Update Check** 🟢
- **Bestand:** `lib/config/app_config.dart`
- **Probleem:** Update check URL is hardcoded
- **Impact:** Minder flexibel maar geen kritiek probleem

## Performance Issues

### 1. **Image Resizing**
- Custom image resizer wordt alleen gebruikt op mobile
- Desktop gebruikt geen resizer, wat kan leiden tot grote afbeeldingen in memory

### 2. **Room Loading**
- `firstClient?.roomsLoading` wordt awaited in `startGui`
- Dit blokkeert de UI startup tot alle rooms geladen zijn

### 3. **Sync Presence**
- Presence updates worden gestuurd bij elke app state change
- Dit kan veel netwerkverkeer genereren

## Aanbevelingen

### Korte termijn (Direct te fixen):
1. **Verlaag network timeout** van 30 min naar 2-5 minuten
2. **Voeg loading indicator toe** bij database migratie
3. **Verbeter error logging** naar externe service (bijv. Sentry)

### Middellange termijn:
1. **Refactor push notificaties** - Vereenvoudig UnifiedPush integratie
2. **Implementeer lazy loading** voor rooms - laad alleen zichtbare rooms
3. **Voeg image caching toe** voor desktop platform

### Lange termijn:
1. **Code splitting** - De app is erg groot (80+ dependencies)
2. **State management** - Overweeg Riverpod of Bloc voor betere state handling
3. **Testing** - Voeg meer unit tests toe (nu alleen widget_test.dart)

## Conclusie
Plusly is een feature-rijke app maar heeft enkele performance en betrouwbaarheids issues. De push notificatie systeem is het meest kwetsbaar. De app zou baat hebben bij een refactoring van de background services en betere error handling.

---
*Rapport gegenereerd door Robbie 🤖*
*Datum: 26 april 2026*
