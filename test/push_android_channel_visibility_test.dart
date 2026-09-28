// Bewaakt de fix die garandeert dat de Plusly-notificatie in de Android-OS-balk
// verschijnt (2026-09-28).
//
// Symptoom: pipeline liep door tot en met `flutterLocalNotificationsPlugin.show()`,
// de App noteerde `push_shown` — maar de gebruiker zag niets in de notificatie-
// balk. Root-cause was dat het notificatiekanaal `plusly_push` nooit expliciet
// met `createNotificationChannel` werd aangemaakt; Android liet 'm daardoor op
// importance Default staan, wat op Android 13+ resulteert in een stille
// (onzichtbare) notificatie.
//
// De fix:
//   1. voor elke show() wordt het kanaal met `Importance.max` gerecreëerd;
//   2. de return-waarde van `show()` wordt gelogd als `push_show_result`,
//      zodat een `false` of exceptie zichtbaar wordt in de push-diagnose.
//   3. bij `false` wordt een kale fallback zonder MessagingStyle verstuurd.
//
// Deze tests zijn STRUCTUUR-tests: ze lezen de broncode en verifiëren dat
//   (a) het kanaal expliciet wordt aangemaakt met Importance.max,
//   (b) de show()-returnwaarde wordt afgevangen met een try/catch,
//   (c) er een fallback-show() bestaat voor het geval show() false geeft,
//   (d) `push_show_result` als event-log regelnaam bestaat.
//
// Een nettere verificatie van *runtime*-gedrag zou een integration-test
// zijn die `flutterLocal_notifications` in een echte Android-VM draait —
// die hebben we (nog) niet in CI, dus deze source-tests zijn de grens.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  final regels = zonderBlok
      .split('\n')
      // Per regel: verwijder het stuk vanaf '//' tot het regeleinde. We
      // werken op een enkele regel en gebruiken [endOfString] via de
      // RegexAnchor, niet via '$', omdat Dart's `//.*$` zonder multiLine
      // anders op de hele string loslaat i.p.v. per regel — wat eerder een
      // vals-positieve comment-match in een assertion veroorzaakte.
      .map((r) {
        final idx = r.indexOf('//');
        return idx == -1 ? r : r.substring(0, idx);
      });
  return regels.join('\n');
}

void main() {
  group('Android-kanaal zichtbaar in OS-balk', () {
    final push = _code('lib/utils/push_helper.dart');

    test('kanaal wordt expliciet aangemaakt met Importance.max', () {
      // De Android-plugin moet aangesproken worden met createNotificationChannel
      // en Importance.max — Default zou de notificatie stilhouden op Android 13+.
      expect(
        push.contains('createNotificationChannel'),
        isTrue,
        reason: 'zonder createNotificationChannel blijft het kanaal op '
            'Default-importance staan en toont Android de notificatie niet.',
      );
      expect(
        push.contains('Importance.max'),
        isTrue,
        reason: 'Importance.max is nodig voor heads-up + geluid.',
      );
    });

    test('show()-excepties worden afgevangen', () {
      // `await flutterLocalNotificationsPlugin.show(...)` zonder try/catch
      // laat een PlatformException onzichtbaar weglekken. De fix zet de
      // aanroep in een try/catch en logt het resultaat.
      expect(
        push.contains('shownError'),
        isTrue,
        reason: 'zonder shownError-tracking kan een mislukte show() niet '
            'in de push-diagnose worden getoond.',
      );
      // Probeer-blok om de aanroep heen.
      final heeftProbeerBlok = RegExp(
        r'Object\?\s+shownError[\s\S]{0,400}try\s*\{[\s\S]{0,200}flutterLocalNotificationsPlugin\.show',
      ).hasMatch(push);
      expect(
        heeftProbeerBlok,
        isTrue,
        reason: 'show() moet in een try/catch staan zodat excepties '
            'zichtbaar worden.',
      );
    });

    test('er bestaat een kale fallback zonder MessagingStyle', () {
      // Als de zware MessagingStyle variant faalt (large icon bitmap, etc.)
      // moet een kale variant alsnog een notificatie kunnen posten.
      expect(
        push.contains('fallback'),
        isTrue,
        reason: 'zonder fallback heeft een show()=false geen tweede kans.',
      );
    });

    test('push_show_result event-log regel wordt toegevoegd', () {
      // De push-diagnose leest `push_show_result` regels om te bepalen of
      // Android de notificatie daadwerkelijk accepteerde.
      expect(
        push.contains("'push_show_result'"),
        isTrue,
        reason: 'zonder push_show_result blijft het onmogelijk om via de '
            'diagnose vast te stellen of Android de notificatie weigerde.',
      );
    });

    test('kanaal-id blijft plusly_push (geen breaking change)', () {
      // Bestaande gebruikers met automatisch aangemaakte kanalen zouden bij
      // een id-wissel alle bestaande channel-instellingen verliezen.
      final appConfig = _code('lib/config/app_config.dart');
      expect(
        appConfig.contains("pushNotificationsChannelId = 'plusly_push'"),
        isTrue,
        reason: 'plusly_push is het canonieke kanaal-id — niet wijzigen.',
      );
    });
  });
}
