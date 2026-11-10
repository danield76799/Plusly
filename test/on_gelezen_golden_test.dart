// Golden-test voor de ongelezen-scheiding en de badge op de scroll-knop.
//
// Schrijft een PNG van de compositie, zodat de vorm visueel gecontroleerd
// kan worden:
//
//   flutter test --update-goldens test/on_gelezen_golden_test.dart
//
// De PNG komt in test/goldens/on_gelezen_scheiding.png.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/unread_separator.dart';

/// Evenaart de badge op de scroll-naar-onder-knop uit chat_view.dart.
Widget _badge({required int count}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      FloatingActionButton(
        onPressed: () {},
        heroTag: null,
        mini: true,
        elevation: 6,
        backgroundColor: const Color(0xfff2f2f7),
        foregroundColor: const Color(0xff1c1c1e),
        shape: CircleBorder(
          side: BorderSide(
            color: const Color(0xff1c1c1e).withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: const Icon(Icons.arrow_downward_outlined),
      ),
      if (count > 0)
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xffd92c2c),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xfff2f2f7), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ),
    ],
  );
}

Widget _bubbel(String tekst, {required bool eigen}) {
  return Align(
    alignment: eigen ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: eigen ? const Color(0xffd9fdd3) : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        tekst,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
      ),
    ),
  );
}

void main() {
  testWidgets('on gelezen-scheiding en badge', (tester) async {
    const surface = Color(0xfff7f7f9);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        locale: const Locale('nl'),
        home: Scaffold(
          backgroundColor: surface,
          body: Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _bubbel('Dit had ik al gelezen', eigen: false),
                      _bubbel('Deze ook', eigen: true),
                      const UnreadSeparator(count: 3),
                      _bubbel('Hier begint het nieuwe', eigen: false),
                      _bubbel('En dit is mijn antwoord', eigen: true),
                    ],
                  ),
                ),
              ),
              Positioned(right: 16, bottom: 24, child: _badge(count: 3)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/on_gelezen_scheiding.png'),
    );
  });
}
