// Borgt de FluffyChat-pariteit van de push-procedure (23-09-2026).
//
// Deze tests toetsen STRUCTUUR in de broncode, niet gedrag: de betrokken
// code loopt in de koude-start/headless tak, die een widgettest niet kan
// bereiken. Elke assertie hoort rood te kunnen — dat is hier bewezen door de
// tests op de ongefixte code te draaien (zie de commit-message).
//
// VALKUIL die deze helper oplost: `indexOf` matcht óók tekst binnen
// commentaar. De toelichtingen hierboven en in main.dart noemen bewust
// `ClientManager.getClients` en `startService`, dus een naïeve indexOf zou de
// verkeerde regel meten en de test rood maken op correcte code.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Broncode zonder commentaar: uitleg citeert bewust de oude/andere code.
String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

/// Regelindex van de eerste CODE-regel die [fragment] bevat, of -1.
/// Slaat commentaarregels over zodat een toelichting niet gemeten wordt.
int _codeLineIndex(String bron, String fragment) {
  final regels = bron.split('\n');
  for (var i = 0; i < regels.length; i++) {
    final t = regels[i].trim();
    if (t.isEmpty || t.startsWith('//')) continue;
    if (regels[i].contains(fragment)) return i;
  }
  return -1;
}

void main() {
  group('Push-procedure = FluffyChat (structuur)', () {
    test('foreground-service start VÓÓR de zware client-init', () {
      final main = _code('lib/main.dart');
      final startIdx = _codeLineIndex(main, "startService('background_push')");
      final clientsIdx = _codeLineIndex(main, 'ClientManager.getClients(');

      expect(startIdx, greaterThan(-1),
          reason: 'main.dart moet de push-foreground-service starten');
      expect(clientsIdx, greaterThan(-1),
          reason: 'main.dart moet de clients laden');
      expect(
        startIdx,
        lessThan(clientsIdx),
        reason: 'Upstream-volgorde (main.dart:86): AppSettings.init -> '
            'startService -> getClients. Staat de service ná getClients, dan '
            'blijft het hele koude-start-venster onbeschermd en vaagt Android '
            'het proces weg vóór de notificatie — de "present-but-late"-variant '
            'die een aanwezigheidscheck niet ziet.',
      );
    });

    test('de headless engine wordt ook bij lifecycleState==null herkend', () {
      final main = _code('lib/main.dart');
      expect(
        main.contains('lifecycleState == null'),
        isTrue,
        reason: 'Een koud gestarte UP-engine heeft geen Activity: Flutter '
            'laat lifecycleState dan null. `detached == lifecycleState` is dan '
            'false en de hele background-tak wordt overgeslagen.',
      );
      expect(
        main.contains('AppLifecycleState.detached'),
        isTrue,
        reason: 'de originele detached-toets moet blijven bestaan',
      );
      expect(main.contains('AppStarter(clients, store)'), isTrue,
          reason: 'vangnet: GUI start bij de eerste echte lifecycle-wijziging');
    });

    test('elke start logt de effectieve lifecycle-state', () {
      final main = _code('lib/main.dart');
      expect(main.contains("'startup_state'"), isTrue,
          reason: 'zonder deze regel bewijst een dump niet welke tak liep');
      expect(main.contains("'branch'"), isTrue);
    });

    test('de foreground-service wordt ook weer gestopt (finally)', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains("stopService('background_push')"),
        isTrue,
        reason: 'upstream stopt hem in de finally (push_helper.dart:93-94); '
            'zonder stop blijft de service (en zijn melding) hangen',
      );
      final stopIdx = _codeLineIndex(helper, "stopService('background_push')");
      final finallyIdx = _codeLineIndex(helper, '} finally {');
      expect(stopIdx, greaterThan(finallyIdx),
          reason: 'de stop hoort in het finally-blok, niet in het try');
    });

    test('één canonieke notificatie-ID voor show én cancel', () {
      final helper = _code('lib/utils/push_helper.dart');
      final bgPush = _code('lib/utils/background_push.dart');
      final handler = _code('lib/utils/notification_background_handler.dart');

      expect(helper.contains('int notificationIdFor('), isTrue,
          reason: 'één top-level functie, niet een instance-getter: statische '
              'call sites (pushHelper) kunnen geen instance-state lezen');
      expect(helper.contains('notificationIdFor('), isTrue);
      expect(bgPush.contains('notificationIdFor('), isTrue,
          reason: 'cancelNotification moet exact dezelfde formule gebruiken');
      expect(handler.contains('notificationIdFor('), isTrue);

      // Geen achtergebleven tweede formule in de push-bestanden.
      expect(
        helper.contains(r"id: notification.roomId?.hashCode"),
        isFalse,
        reason: 'show() gebruikte roomId.hashCode terwijl elk cancel-pad de '
            'client-gekwalificeerde vorm gebruikte: Android past die cancel dan '
            'nooit toe op de getoonde melding',
      );
      expect(
        bgPush.contains(r"'${client.clientName}_$roomId'.hashCode"),
        isFalse,
        reason: 'cancelNotification moet via notificationIdFor gaan',
      );
    });

    test('cancelAll alleen bij unread==0 én één account', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains('clients.length == 1'),
        isTrue,
        reason: 'upstream (push_helper.dart:139-140) wist alleen bij één '
            'account; Plusly wiste ongeacht het aantal accounts',
      );
      expect(
        helper.contains('notification.counts?.unread == null ||'),
        isFalse,
        reason: 'unread==null meenemen wist ELKE actieve melding zodra UP het '
            'unread-veld stript — de melding was er even en verdween weer',
      );
    });

    test('de clientOnly-factory krijgt de hele client-lijst', () {
      final bgPush = _code('lib/utils/background_push.dart');
      expect(
        bgPush.contains('factory BackgroundPush.clientOnly(List<Client> clients)'),
        isTrue,
        reason: 'upstream background_push.dart:142-144 — met één client kreeg '
            'een push voor een tweede account altijd de eerste als "opgeloste" '
            'client',
      );
      final main = _code('lib/main.dart');
      expect(main.contains('BackgroundPush.clientOnly(clients)'), isTrue);
      expect(main.contains('BackgroundPush.clientOnly(clients.first)'), isFalse);
    });

    test('de acties en de samenvattingsmelding zijn aangezet', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(helper.contains('useNotificationActions = true'), isTrue);
      expect(helper.contains('Future<void> updateSummaryNotification('), isTrue,
          reason: 'upstream r404-441: groeps-samenvatting op Android');
      expect(helper.contains('setAsGroupSummary: true'), isTrue);
      expect(helper.contains('void updateAppBadge('), isTrue,
          reason: 'upstream r393-402');
    });

    test('de versleutelde-tak volgt upstream (geen placeholder/retry)', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains('_showEncryptedPlaceholder'),
        isFalse,
        reason: 'upstream toont direct de generieke tekst en probeert geen '
            'ontsleuteling na te jagen; de twee-fasen DM-fix was Plusly-eigen',
      );
      expect(helper.contains('push_retry_ok'), isFalse);
      expect(helper.contains('push_duplicate'), isFalse,
          reason: 'de event_id-dedup was Plusly-eigen; upstream heeft hem niet');
    });
  });
}
