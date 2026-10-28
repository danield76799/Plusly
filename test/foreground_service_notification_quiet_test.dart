// Borgt vast dat de foreground-service-melding zo onopvallend mogelijk is.
//
// HET PROBLEM. Zodra Plusly op de achtergrond wakker wordt om een bericht
// op te halen, start het een foreground-service. Android eist daarbij een
// zichtbare melding — de gebruiker zag die als een opvallende kaart met
// "Plusly / Meldingen ophalen" naast de berichtmeldingen.
//
// De melding is onvermijdelijk (Android-vereiste), maar hoeft niet op te
// vallen: een eigen kanaal met importance MIN blijft ingeklapt in de
// schaduw en komt niet in de statusbalk. Het oude kanaal
// ('notification_channel_id') blijft bestaan voor de gespreksnotificaties,
// want daar wil je wél horen dat er belt.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _code(String pad) {
  final c = File(pad).readAsStringSync();
  final zonderBlok = c.replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '');
  return zonderBlok
      .split('\n')
      .map((r) => r.replaceAll(RegExp(r'//.*$', multiLine: true), ''))
      .join('\n');
}

void main() {
  group('foreground-service-melding', () {
    final code = _code('lib/utils/foreground_services.dart');

    test('de service heeft een eigen kanaal', () {
      expect(
        code.contains("channelId: 'plusly_foreground_service'"),
        isTrue,
        reason: 'een eigen kanaal, zodat de belangrijkheid (MIN) bij '
            'bestaande installaties ook echt wordt toegepast — een bestaand '
            'kanaal behoudt zijn importantie',
      );
    });

    test('het kanaal is minimaal en stil', () {
      expect(
        code.contains('channelImportance: NotificationChannelImportance.MIN'),
        isTrue,
        reason: 'importance MIN: de melding blijft ingeklapt en komt niet in '
            'de statusbalk',
      );
      expect(
        code.contains('playSound: false'),
        isTrue,
        reason: 'geen geluid',
      );
      expect(
        code.contains('enableVibration: false'),
        isTrue,
        reason: 'geen trilling',
      );
    });

    test('het gesprekskanaal blijft ongemoeid', () {
      // De gespreksnotificaties delen 'notification_channel_id' met andere
      // meldingen; dat kanaal moet dus niet door de service worden
      // overgeschreven.
      final dialer = _code('lib/pages/dialer/dialer.dart');
      expect(
        dialer.contains("channelId: 'notification_channel_id'"),
        isTrue,
        reason: 'de gespreksmeldingen houden hun eigen kanaal',
      );
    });
  });
}
