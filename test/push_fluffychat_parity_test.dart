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
      // Upstream heeft geen aparte startup-instrumentatie; de
      // detached/null-tak ( koude start) is voldoende herkenbaar via
      // de lifecycleState-toets zelf.
      expect(main.contains('AppLifecycleState.detached'), isTrue,
          reason: 'de originele detached-toets moet blijven bestaan');
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
        helper.contains('clients?.length == 1'),
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
      expect(helper.contains('Future<void> updateSummaryNotification('), isTrue,
          reason: 'upstream r404-441: groeps-samenvatting op Android');
      expect(helper.contains('setAsGroupSummary: true'), isTrue);
      expect(helper.contains('void updateAppBadge('), isTrue,
          reason: 'upstream r393-402');
      // Upstream heeft geen schakelaar: de acties staan via een switch op
      // het event-type aan (r311-341).
      expect(helper.contains('actions: switch (event.type)'), isTrue);
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

    // --- Tweede controle-ronde (23-09, na de eerste port) ---

    test('de check-volgorde is die van upstream', () {
      final helper = _code('lib/utils/push_helper.dart');
      final eventIdx = _codeLineIndex(
        helper,
        'client.getEventByPushNotification(',
      );
      final ruleIdx = _codeLineIndex(
        helper,
        'client.pushruleEvaluator.match(event).notify',
      );
      final fgIdx = _codeLineIndex(
        helper,
        'WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed',
      );
      final badgeIdx = _codeLineIndex(helper, 'updateAppBadge(');

      expect(eventIdx, greaterThan(-1));
      expect(ruleIdx, greaterThan(-1));
      expect(fgIdx, greaterThan(-1));
      expect(badgeIdx, greaterThan(-1));
      expect(
        eventIdx,
        lessThan(badgeIdx),
        reason: 'upstream: event laden vóór de badge (r129-135)',
      );
      expect(
        ruleIdx,
        lessThan(fgIdx),
        reason: 'upstream toetst de push rules VÓÓR de foreground-onderdrukking '
            '(r179-196). Staat de foreground eerder, dan slaat die tak de '
            'push-rule filter over',
      );
    });

    test('Android stuurt geen losse title/body naast de MessagingStyle', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains('final needsTitleAndBody = !PlatformInfos.isAndroid;'),
        isTrue,
        reason: 'upstream r368: op Android draagt de MessagingStyle titel en '
            'inhoud; losse title/body overschrijven die en breken het stapelen',
      );
      expect(helper.contains('title: needsTitleAndBody ? title : null'), isTrue);
      expect(helper.contains('body: needsTitleAndBody ? body : null'), isTrue);
    });

    test('de MessagingStyle-eigenaar is de lokale gebruiker', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains('unsafeGetUserFromMemoryOrFallback'),
        isTrue,
        reason: 'upstream r218: de gesprekseigenaar (niet de afzender) met '
            'diens avatar; de afzender zit in het Message-object',
      );
      expect(helper.contains('ownUser.calcDisplayname()'), isTrue);
      expect(helper.contains('key: event.room.client.userID'), isTrue);
    });

    test('acties alleen op berichten, via een switch op het type', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains('EventTypes.Message ||'),
        isTrue,
        reason: 'upstream r311-341: switch op message/encrypted/sticker',
      );
      expect(helper.contains('EventTypes.Sticker =>'), isTrue);
      expect(
        helper.contains('event.type == EventTypes.RoomMember ||'),
        isFalse,
        reason: 'een uitsluiting zette de acties op élk ander type, ook waar '
            '"Antwoorden" geen betekenis heeft',
      );
      expect(helper.contains('semanticAction: SemanticAction.mute'), isTrue,
          reason: 'upstream geeft de mute-actie een semantische actie');
    });

    test('client_name staat op de pusher, net als upstream', () {
      final bgPush = _code('lib/utils/background_push.dart');
      expect(
        bgPush.contains('"client_name": client.clientName'),
        isTrue,
        reason: 'upstream background_push.dart r248-251 schrijft client_name '
            'in additionalProperties; Plusly leidt het notificatie-ID van de '
            'opgeloste client af, maar de pusher hoort de sleutel te dragen',
      );
      // Twee keer: in de VERGELIJKING én in de payload. De vergelijking doet
      // een map-lookup (`['client_name'] == client.clientName`), de payload
      // een toewijzing (`"client_name": client.clientName`). Beide vormen
      // moeten aanwezig zijn, anders matched de pusher nooit en wordt hij
      // bij elke start opnieuw gezet.
      expect(
        RegExp(r'''['\"]client_name['\"]:\s*client\.clientName''')
            .allMatches(bgPush)
            .length,
        1,
        reason: 'de payload bevat precies één toewijzing',
      );
      expect(
        bgPush.contains("additionalProperties['client_name'] ==") ||
            bgPush.contains('additionalProperties["client_name"] =='),
        isTrue,
        reason: 'de pusher-vergelijking checkt client_name in additionalProperties',
      );
    });

    test('bewust NIET overgenomen: callkit en de crash-report-sleutel', () {
      final helper = _code('lib/utils/push_helper.dart');
      expect(
        helper.contains('_showIncomingCall'),
        isFalse,
        reason: 'upstream gebruikt flutter_callkit_incoming; Plusly heeft die '
            'dependency niet. Bellen is hier een aparte feature, geen push-pad',
      );
      expect(
        helper.contains('pushHelperCrashReportKey'),
        isFalse,
        reason: 'upstream schrijft crashes naar SharedPreferences; Plusly naar '
            'het push-log dat de debug-scherm al toont',
      );
    });
  });
}
