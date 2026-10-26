import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/utils/bridge_utils.dart';

/// Regressietests voor de brugdetectie.
///
/// De detectie wordt gevoed door kamersamen, -aliassen en -gebruikersnamen
/// en moet daarom héél streng zijn: een gewone Matrix-chat mag nooit als
/// WhatsApp/Telegram/... worden aangemerkt. Vroeger gebeurde dat wél, bij
///voorbeeld bij een contact "Ritsa wa", een groep met een lid "Signal" of
/// een kamer die op een telefoonnummer begint.
void main() {
  group('bridgeNetworkFromUserId', () {
    test('herkent bridge-bots', () {
      expect(bridgeNetworkFromUserId('@whatsappbot:beeper.com'), 'whatsapp');
      expect(bridgeNetworkFromUserId('@wa:example.org'), 'whatsapp');
      expect(bridgeNetworkFromUserId('@wa_31612345678:example.org'), 'whatsapp');
      expect(bridgeNetworkFromUserId('@telegram:example.org'), 'telegram');
      expect(bridgeNetworkFromUserId('@telegrambot:example.org'), 'telegram');
      expect(bridgeNetworkFromUserId('@signalbot:example.org'), 'signal');
      expect(bridgeNetworkFromUserId('@discordbot:example.org'), 'discord');
      expect(bridgeNetworkFromUserId('@slackbot:example.org'), 'slack');
      expect(bridgeNetworkFromUserId('@linkedinbot:example.org'), 'linkedin');
    });

    test('laat gewone accounts met rust', () {
      expect(bridgeNetworkFromUserId('@jan:example.org'), isNull);
      expect(bridgeNetworkFromUserId('@signaluser:example.org'), isNull);
      expect(bridgeNetworkFromUserId('@telegramfan:example.org'), isNull);
      expect(bridgeNetworkFromUserId('@wa_and_zo:example.org'), isNull);
      expect(bridgeNetworkFromUserId(''), isNull);
      expect(bridgeNetworkFromUserId(null), isNull);
    });
  });

  group('bridgeNetworkFromAlias', () {
    test('herkent brug-aliases', () {
      expect(bridgeNetworkFromAlias('#wa_31612345678:example.org'), 'whatsapp');
      expect(bridgeNetworkFromAlias('#whatsapp_x:example.org'), 'whatsapp');
      expect(bridgeNetworkFromAlias('#telegram_x:example.org'), 'telegram');
      expect(bridgeNetworkFromAlias('#signal_x:example.org'), 'signal');
      expect(bridgeNetworkFromAlias('#discord_x:example.org'), 'discord');
      expect(bridgeNetworkFromAlias('#slack_x:example.org'), 'slack');
      expect(bridgeNetworkFromAlias('#linkedin_x:example.org'), 'linkedin');
    });

    test('laat gewone aliassen met rust', () {
      expect(bridgeNetworkFromAlias('#general:example.org'), isNull);
      expect(bridgeNetworkFromAlias('#wa:example.org'), isNull);
      expect(bridgeNetworkFromAlias('#signaal:example.org'), isNull);
      expect(bridgeNetworkFromAlias(''), isNull);
      expect(bridgeNetworkFromAlias(null), isNull);
    });
  });

  group('bridgeNetworkFromString', () {
    test('herkent netwerknamen uit state-events', () {
      expect(bridgeNetworkFromString('WhatsApp'), 'whatsapp');
      expect(bridgeNetworkFromString('Telegram'), 'telegram');
      expect(bridgeNetworkFromString('signal'), 'signal');
      expect(bridgeNetworkFromString('discord'), 'discord');
      expect(bridgeNetworkFromString('slack'), 'slack');
      expect(bridgeNetworkFromString('linkedin'), 'linkedin');
    });

    test('laat vrije tekst met rust', () {
      expect(bridgeNetworkFromString('m.room.member'), isNull);
      expect(bridgeNetworkFromString('Beeper'), isNull);
      expect(bridgeNetworkFromString('Ritsa wa'), isNull);
      expect(bridgeNetworkFromString('+31612345678'), isNull);
      expect(bridgeNetworkFromString(''), isNull);
      expect(bridgeNetworkFromString(null), isNull);
    });
  });

  group('regressie: vrije tekst leidt nooit tot een netwerk', () {
    // De oude detectie keek óók naar kamer- en gebruikersnamen. Daardoor
    // werden gewone chats als WhatsApp/Telegram aangemerkt.
    test('"wa" in een naam levert geen netwerk op', () {
      for (final naam in ['Ritsa wa', 'Ken wa', 'Altijd wa', 'waar is dat']) {
        expect(bridgeNetworkFromString(naam), isNull, reason: naam);
        expect(bridgeNetworkFromUserId(naam), isNull, reason: naam);
        expect(bridgeNetworkFromAlias(naam), isNull, reason: naam);
      }
    });

    test('een netwerkwoord in een user-id of alias is geen netwerk', () {
      // "WhatsApp groep" is een geldige bridge_name in een state-event,
      // maar als user-id of alias is het willekeur.
      for (final naam in [
        'WhatsApp groep',
        'Signal',
        'Telegram',
        '@signaluser:example.org',
        '@telegramfan:example.org',
      ]) {
        expect(bridgeNetworkFromUserId(naam), isNull, reason: naam);
        expect(bridgeNetworkFromAlias(naam), isNull, reason: naam);
      }
    });

    test('een telefoonnummer als kamernaam levert geen netwerk op', () {
      expect(bridgeNetworkFromString('+31612345678'), isNull);
      expect(bridgeNetworkFromString('0612345678'), isNull);
      expect(bridgeNetworkFromAlias('+31612345678'), isNull);
    });
  });

  group('netwerkmetadata', () {
    test('elk ondersteund netwerk heeft een label, kleur en icoon', () {
      const netwerken = [
        'whatsapp',
        'telegram',
        'signal',
        'discord',
        'slack',
        'matrix',
        'linkedin',
      ];
      for (final netwerk in netwerken) {
        expect(getBridgeTypeLabel(netwerk), isNot('Other'), reason: netwerk);
        expect(getBridgeTypeSvg(netwerk), isNotNull, reason: netwerk);
      }
    });
  });

  group('sanitizePreview', () {
    test('haalt de brugmarkering uit de preview', () {
      expect('Jeroen IJntema (WA): Ja, met fruit sapjes'.sanitizePreview(),
          'Ja, met fruit sapjes');
      expect('Fenna (WA): Ooooooke'.sanitizePreview(), 'Ooooooke');
      expect('(WA): hallo'.sanitizePreview(), 'hallo');
      expect('. (WA): hallo'.sanitizePreview(), 'hallo');
      expect('WhatsApp (WA): hallo'.sanitizePreview(), 'hallo');
      expect('bridge bot: hallo'.sanitizePreview(), 'hallo');
    });

    test('laat gewone berichten ongemoeid', () {
      expect('Hallo, hoe gaat het?'.sanitizePreview(), 'Hallo, hoe gaat het?');
      expect('(WA) is een afkorting'.sanitizePreview(), '(WA) is een afkorting');
      expect(''.sanitizePreview(), '');
    });
  });
}
