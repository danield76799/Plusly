import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Tests voor E2EE emoji verification.
///
/// We testen hier alleen de JSON parsing en emoji mapping logica,
/// niet de onderliggende native crypto.
void main() {
  group('SAS Emoji Verification', () {
    late List<dynamic> sasEmoji;

    setUpAll(() async {
      // Laad het SAS emoji bestand direct van disk (geen rootBundle nodig)
      final file = File('assets/sas-emoji.json');
      final raw = await file.readAsString();
      sasEmoji = json.decode(raw);
    });

    test('sas-emoji.json bevat 64 entries', () {
      expect(sasEmoji.length, 64);
    });

    test('elke entry heeft nummer, emoji, en description', () {
      for (final entry in sasEmoji) {
        expect(entry['number'], isA<int>());
        expect(entry['emoji'], isA<String>());
        expect(entry['description'], isA<String>());
      }
    });

    test('nummers zijn 0-63', () {
      final numbers = sasEmoji.map((e) => e['number'] as int).toList();
      expect(numbers, equals(List.generate(64, (i) => i)));
    });

    test('nederlandse vertaling bestaat voor entry 0 (hond)', () {
      final entry = sasEmoji[0];
      final translations =
          Map<String, dynamic>.from(entry['translated_descriptions']);
      expect(translations['nl'], 'Hond');
    });

    test('emoji voor nummer 0 is 🐶', () {
      expect(sasEmoji[0]['emoji'], '🐶');
    });

    test('emoji voor nummer 1 is 🐱', () {
      expect(sasEmoji[1]['emoji'], '🐱');
    });

    test('alle emojis zijn uniek', () {
      final emojis = sasEmoji.map((e) => e['emoji']).toSet();
      expect(emojis.length, 64); // Geen dubbele
    });

    test('translated_descriptions bevat NL voor alle entries', () {
      for (final entry in sasEmoji) {
        final translations =
            Map<String, dynamic>.from(entry['translated_descriptions']);
        expect(translations['nl'], isA<String>());
        expect(translations['nl']!.isNotEmpty, isTrue);
      }
    });
  });
}
