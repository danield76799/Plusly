// Tests voor het delen van een contact (Matrix `m.contact`).
//
// HET PROBLEEM: Plusly kon geen contact delen. Het berichttype `m.contact`
// bestaat wel in de Matrix-wereld, maar de SDK kent het niet (het valt
// onder de 'onbekende' berichttypes en kwam dus als kale tekst binnen).
//
// Wat hier getest wordt:
//  1. De contactgegevens worden uit het event gelezen, ook als een andere
//     client ze onder een andere sleutel bewaart.
//  2. Een contact zonder herkenbare gegevens levert niets op.
//  3. De verzonden inhoud heeft de vorm die andere Matrix-clients lezen.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/pages/chat/events/contact_bubble.dart';

class _FakeRoom implements Room {
  @override
  final String id;

  _FakeRoom({required this.id});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Event _contactEvent(Map<String, dynamic> content) => Event(
  eventId: 'contact',
  senderId: '@dana:example.org',
  originServerTs: DateTime.now(),
  room: _FakeRoom(id: '!kamer:example.org'),
  type: EventTypes.Message,
  content: content,
);

void main() {
  group('ContactDetails.fromEvent', () {
    test('leest de gegevens uit m.contact', () {
      final event = _contactEvent({
        'msgtype': 'm.contact',
        'body': 'Jan de Vries',
        'm.contact': {
          'display_name': 'Jan de Vries',
          'matrix_id': '@jan:example.org',
          'phone': '+31612345678',
          'email': 'jan@example.org',
        },
      });

      final contact = ContactDetails.fromEvent(event);
      expect(contact, isNotNull);
      expect(contact!.displayName, 'Jan de Vries');
      expect(contact.matrixId, '@jan:example.org');
      expect(contact.phones, ['+31612345678']);
      expect(contact.emails, ['jan@example.org']);
      expect(contact.primaryPhone, '+31612345678');
      expect(contact.primaryEmail, 'jan@example.org');
      expect(contact.hasDetails, isTrue);
    });

    test('leest ook de oudere sleutel', () {
      final event = _contactEvent({
        'msgtype': 'm.contact',
        'body': 'Piet',
        'org.matrix.msc4041.contact': {
          'display_name': 'Piet',
          'matrix_id': '@piet:example.org',
        },
      });
      final contact = ContactDetails.fromEvent(event);
      expect(contact, isNotNull);
      expect(contact!.displayName, 'Piet');
      expect(contact.matrixId, '@piet:example.org');
    });

    test('valt terug op de body als er geen naam in de contact staat', () {
      final event = _contactEvent({
        'msgtype': 'm.contact',
        'body': 'Zonder details',
      });
      final contact = ContactDetails.fromEvent(event);
      expect(contact, isNotNull);
      expect(contact!.displayName, 'Zonder details');
      expect(contact.hasDetails, isFalse);
    });

    test('een ander berichttype levert geen contact op', () {
      final event = _contactEvent({
        'msgtype': 'm.text',
        'body': 'gewoon tekst',
      });
      expect(ContactDetails.fromEvent(event), isNull);
    });
  });

  group('lijsten met meerdere contactgegevens', () {
    test('de WhatsApp-brug stuurt telefoons als lijst', () {
      final event = _contactEvent({
        'msgtype': 'm.contact',
        'body': 'Jan',
        'm.contact': {
          'display_name': 'Jan',
          'phone': ['+31611111111', '+31622222222'],
          'email': ['jan@example.org', 'jan@werk.nl'],
        },
      });
      final contact = ContactDetails.fromEvent(event);
      expect(contact, isNotNull);
      expect(contact!.phones, ['+31611111111', '+31622222222']);
      expect(contact.emails, ['jan@example.org', 'jan@werk.nl']);
      expect(contact.primaryPhone, '+31611111111');
    });

    test('de vcard van de brug blijft bewaard', () {
      final event = _contactEvent({
        'msgtype': 'm.contact',
        'body': 'Jan',
        'm.contact': {
          'display_name': 'Jan',
          'vcard_url': 'mxc://example.org/janvcf',
          'vcard_name': 'Jan.vcf',
        },
      });
      final contact = ContactDetails.fromEvent(event);
      expect(contact!.vcardUrl, 'mxc://example.org/janvcf');
      expect(contact.vcardName, 'Jan.vcf');
    });
  });

  group('het berichttype', () {
    test('is m.contact', () {
      expect(contactMessageType, 'm.contact');
    });
  });

  group('de verzonden inhoud', () {
    test('heeft de vorm die andere Matrix-clients lezen', () {
      final code = File(
        'lib/pages/chat/send_contact_dialog.dart',
      ).readAsStringSync();
      expect(
        code.contains("'msgtype': contactMessageType"),
        isTrue,
        reason: 'het berichttype moet m.contact zijn',
      );
      expect(
        code.contains("'m.contact': contact"),
        isTrue,
        reason: 'de gegevens horen onder de sleutel m.contact',
      );
      expect(
        code.contains("'body': naam"),
        isTrue,
        reason: 'de body is de naam, zodat oudere clients iets te tonen '
            'hebben',
      );
    });

    test('de knop staat in het bijlage-menu', () {
      final code = File(
        'lib/pages/chat/chat_input_row.dart',
      ).readAsStringSync();
      expect(
        code.contains("value: 'contact'"),
        isTrue,
        reason: 'zonder menu-item is er geen knop om een contact te delen',
      );
      final chat = File('lib/pages/chat/chat.dart').readAsStringSync();
      expect(
        chat.contains("if (choice == 'contact') {"),
        isTrue,
        reason: 'anders doet de knop niets',
      );
      expect(
        chat.contains('sendContactAction()'),
        isTrue,
      );
    });
  });
}
