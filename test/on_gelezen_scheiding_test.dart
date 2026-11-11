// Regressietests voor de ongelezen-scheiding (1) en de badge op de
// scroll-naar-onder-knop (2).
//
// 1. Ongelezen-scheiding: een lijn met "N ongelezen berichten" tussen het
//    laatst gelezen en het eerste ongelezen bericht. Zonder die lijn liep
//    oud en nieuw door elkaar — je zag nergens waar je gebleven was.
// 2. Badge: het aantal berichten onder die scheiding, op de knop die naar
//    het nieuwste bericht springt.
//
// Belangrijk detail dat deze tests vastleggen: het leespunt is een
// SNAPSHOT van het moment van openen. Het gesprek wordt bij het openen meteen
// als gelezen gemarkeerd (setReadMarker), dus met het live leespunt zou de
// scheiding binnen een seconde verdwijnen.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/generated/l10n/l10n_en.dart';
import 'package:Pulsly/generated/l10n/l10n_nl.dart';
import 'package:Pulsly/pages/chat/events/unread_separator.dart';

Widget _metTaal(Widget child, Locale locale) {
  return MaterialApp(
    localizationsDelegates: L10n.localizationsDelegates,
    supportedLocales: L10n.supportedLocales,
    locale: locale,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Ongelezen-scheiding', () {
    testWidgets('toont het aantal in het Nederlands', (tester) async {
      await tester.pumpWidget(
        _metTaal(const UnreadSeparator(count: 3), const Locale('nl')),
      );
      await tester.pumpAndSettle();

      expect(find.text('3 ongelezen berichten'), findsOneWidget);
    });

    testWidgets('gebruikt enkelvoud bij één bericht', (tester) async {
      await tester.pumpWidget(
        _metTaal(const UnreadSeparator(count: 1), const Locale('nl')),
      );
      await tester.pumpAndSettle();

      expect(find.text('1 ongelezen bericht'), findsOneWidget);
    });

    test('is gelokaliseerd: Engels heeft eigen tekst', () {
      // Bewust geen tweede widget-test met een andere taal: twee locales in
      // dezelfde test-run laten de l10n-loader de verkeerde klasse
      // teruggeven. De Engelse tekst wordt daarom rechtstreeks op de
      // gegenereerde klasse gecontroleerd — dat is precies wat de app bij
      // taal "en" gebruikt.
      expect(L10nEn().unreadMessages(4), '4 unread messages');
      expect(L10nEn().unreadMessages(1), '1 unread message');
      expect(L10nEn().unreadMessages(4), isNot(L10nNl().unreadMessages(4)));
    });

    test('staat boven het eerste ongelezen bericht', () {
      // In een nieuwste-eerst lijst is het eerste ongelezen bericht één
      // index lager dan het leespunt. De scheiding hoort daarboven, dus bij
      // events[dividerIndex - 1] — en niet bij events[dividerIndex].
      final bron = File(
        'lib/pages/chat/chat_event_list.dart',
      ).readAsStringSync();

      expect(bron, contains('dividerIndex - 1'));
      expect(bron, contains('UnreadSeparator(count: unreadCount)'));
    });

    test('het leespunt is een snapshot en schuift niet mee', () {
      // Als unreadDividerEventId aan het LIVE leespunt zou hangen, zou de
      // scheiding verdwijnen zodra setReadMarker() draait — en dat gebeurt
      // meteen bij het openen van het gesprek.
      final bron = File('lib/pages/chat/chat.dart').readAsStringSync();

      // Alleen kijken binnen het laden van de timeline, want setReadMarker()
      // staat op meerdere plekken in dit bestand.
      final methode = bron.indexOf('Future<void> _tryLoadTimeline()');
      expect(methode, greaterThan(0));

      final snapshotRegel = bron.indexOf('unreadDividerEventId =', methode);
      expect(
        snapshotRegel,
        greaterThan(methode),
        reason: 'Het leespunt moet bij het openen bewaard worden',
      );

      final zetGelezenRegel = bron.indexOf('setReadMarker();', snapshotRegel);
      expect(
        zetGelezenRegel,
        greaterThan(snapshotRegel),
        reason:
            'Het leespunt moet bewaard worden VOORDAT het gesprek als '
            'gelezen gemarkeerd wordt, anders is de grens meteen weg',
      );
    });

    test('de grens komt uit eigen read-receipts, niet uit fullyRead', () {
      // room.fullyRead (de m.fully_read-marker) loopt achter op de
      // read-receipts. Daardoor wees hij nog naar een bericht dat allang
      // gelezen was en stond er "4 ongelezen" terwijl er 0 ongelezen waren.
      // De grens moet daarom uit je eigen read-receipts komen.
      final bron = File('lib/pages/chat/chat.dart').readAsStringSync();

      expect(bron, contains('lastOwnReadEventId'));
      expect(
        bron,
        contains("r.user.senderId == sendingClient.userID"),
        reason: 'De grens moet de eigen read-receipts gebruiken',
      );
    });

    test('eigen berichten tellen niet mee als ongelezen', () {
      final bron = File(
        'lib/pages/chat/chat_event_list.dart',
      ).readAsStringSync();

      expect(
        bron,
        contains('event.senderId != ownUserId'),
        reason:
            'Je eigen verzonden berichten zijn geen ongelezen berichten',
      );
      expect(
        bron,
        contains('event.type == EventTypes.Message'),
        reason: 'State-events tellen niet mee als ongelezen berichten',
      );
    });

    test('de badge gebruikt hetzelfde getal als de scheiding', () {
      final eventList = File(
        'lib/pages/chat/chat_event_list.dart',
      ).readAsStringSync();
      final chatView = File('lib/pages/chat/chat_view.dart').readAsStringSync();

      expect(
        eventList,
        contains('unreadCountNotifier.value = unreadCount'),
        reason: 'Het getal moet vanuit de timeline op de badge belanden',
      );
      expect(
        chatView,
        contains('unreadCountNotifier'),
        reason: 'De scroll-knop moet de badge met dat getal tonen',
      );
    });
  });
}
