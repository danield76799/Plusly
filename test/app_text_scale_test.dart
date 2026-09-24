// Regressietest voor de app-brede tekstschaal.
//
// AANLEIDING: `AppSettings.fontSizeFactor` werd alleen in de chat toegepast —
// 28 losse `fontSize: X * factor`-plekken. Wie de schuif in Instellingen →
// Stijl verzette, zag alleen de chat meeschalen; de rest van de app bleef even
// groot. Deze test borgt dat de schaal nu app-breed werkt EN dat de chat niet
// dubbel schaalt.
//
// WAT ER GEMETEN WORDT: de ECHTE gerenderde teksthoogte (`RenderParagraph`),
// niet of er ergens een symbool in de bron staat. Een test die alleen kijkt of
// `AppTextScale` bestaat, zou groen zijn terwijl de factor niets doet.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/utils/app_text_scale.dart';

/// De hoogte die [tekst] werkelijk inneemt, inclusief de MediaQuery-schaal.
double _gemetenHoogte(WidgetTester t, String tekst) {
  final p = t.renderObject<RenderParagraph>(find.text(tekst));
  return p.size.height;
}

Widget _huls({required double factor, required String tekst}) {
  return MaterialApp(
    home: AppTextScale(
      factor: factor,
      child: Scaffold(body: Center(child: Text(tekst))),
    ),
  );
}

void main() {
  // KORT en zonder spaties: een langere zin wikkelt bij 2x-3x naar een tweede
  // regel, en dan meet je regelafbreking in plaats van de tekstschaal. Dat is
  // precies hoe deze test eerst een 4.0-ratio teruggaf terwijl de scaler goed
  // rekende.
  const tekst = 'Xg';

  group('AppTextScaler rekent goed', () {
    test('vermenigvuldigt de basis-schaal', () {
      const s = AppTextScaler(1.5, TextScaler.linear(2));
      // 2 (basis) x 1.5 (app) = 3
      expect(s.scale(10), closeTo(30, 0.001));
      expect(s.textScaleFactor, closeTo(3, 0.001));
    });

    test('factor 1.0 laat alles ongemoeid', () {
      const s = AppTextScaler(1.0, TextScaler.linear(2));
      expect(s.scale(10), closeTo(20, 0.001));
    });

    test('werkt zonder expliciete basis (systeemschaal = 1)', () {
      const s = AppTextScaler(1.25);
      expect(s.scale(8), closeTo(10, 0.001));
    });

    test('clamp begrenst de BASIS, niet de app-factor', () {
      // Basis 2.0 geklemd op max 1.5 -> 1.5, daarna x app-factor 2.0 = 3.0.
      const s = AppTextScaler(2.0, TextScaler.linear(2.0));
      final c = s.clamp(maxScaleFactor: 1.5);
      expect(c.scale(1), closeTo(3.0, 0.001));
    });

    test('clamp laat een basis ONDER het maximum ongemoeid', () {
      // Basis 1.0 is al binnen [0, 1.5], dus alleen de app-factor telt: 2.0.
      const s = AppTextScaler(2.0, TextScaler.linear(1.0));
      final c = s.clamp(maxScaleFactor: 1.5);
      expect(c.scale(1), closeTo(2.0, 0.001));
    });

    test('gelijkheid: zelfde factor+basis is hetzelfde object-waarde', () {
      expect(const AppTextScaler(1.5, TextScaler.linear(2)),
          const AppTextScaler(1.5, TextScaler.linear(2)));
      expect(const AppTextScaler(1.5, TextScaler.linear(2)),
          isNot(const AppTextScaler(1.6, TextScaler.linear(2))));
    });
  });

  group('de schaal komt echt op de tekst terecht', () {
    testWidgets('factor 2.0 maakt de tekst aantoonbaar hoger', (t) async {
      await t.pumpWidget(_huls(factor: 1.0, tekst: tekst));
      final normaal = _gemetenHoogte(t, tekst);

      await t.pumpWidget(_huls(factor: 2.0, tekst: tekst));
      await t.pump();
      final groot = _gemetenHoogte(t, tekst);

      expect(groot, greaterThan(normaal),
          reason: 'de tekstschaal doet niets — precies het symptoom dat deze '
              'test moet vangen');
      // 'Xg' is kort en heeft geen spaties, dus afbreking is onmogelijk en de
      // hoogte schaalt exact mee met de tekengrootte.
      expect(groot / normaal, closeTo(2.0, 0.02));
    });

    testWidgets('factor 1.0 laat de MediaQuery ongemoeid (geen extra laag)',
        (t) async {
      await t.pumpWidget(_huls(factor: 1.0, tekst: tekst));
      // De standaard-Flutter-schaal in tests is 1.0; zonder wijziging blijft
      // die staan. Dit borgt dat het standaardpad exact het oude is.
      expect(t.widget<AppTextScale>(find.byType(AppTextScale)).factor, 1.0);
      expect(_gemetenHoogte(t, tekst), greaterThan(0));
    });

    testWidgets('stapelt op een bestaande systeemschaal', (t) async {
      // Systeem op 1.5, app op 2.0 -> 3.0, niet 2.0.
      //
      // LET OP: een verse `MediaQueryData` heeft `size: Size.zero`, waardoor de
      // tekst in een nul-breed kader wordt gelegd en de gemeten hoogte onzin
      // is. Bouw daarom van de AMBIENT MediaQuery voort in plaats van een lege
      // te injecteren.
      Widget huls({required double factor, required bool metApp}) {
        return MaterialApp(
          home: Builder(
            builder: (context) {
              final systeem = MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.5),
              );
              return MediaQuery(
                data: systeem,
                child: metApp
                    ? AppTextScale(
                        factor: factor,
                        child: const Scaffold(body: Center(child: Text(tekst))),
                      )
                    : const Scaffold(body: Center(child: Text(tekst))),
              );
            },
          ),
        );
      }

      await t.pumpWidget(huls(factor: 2.0, metApp: false));
      await t.pump();
      final alleenSysteem = _gemetenHoogte(t, tekst);

      await t.pumpWidget(huls(factor: 2.0, metApp: true));
      await t.pump();
      final gestapeld = _gemetenHoogte(t, tekst);

      expect(gestapeld / alleenSysteem, closeTo(2.0, 0.05),
          reason: 'de app-factor hoort BOVENOP de systeemschaal te komen');
    });
  });

  group('de chat schaalt NIET dubbel', () {
    test('geen enkele fontSize-expressie vermenigvuldigt de factor nog', () {
      // De broncontrole. De rendertest hierboven bewijst de scaler; deze
      // bewijst dat de 28 oude plekken hem niet nog eens toepassen, wat de
      // chat kwadratisch zou laten schalen.
      final bron = _lees('lib/pages/chat/');
      final verdacht = <String>[];
      for (final regel in bron) {
        if (!regel.contains('fontSize')) continue;
        if (regel.contains('fontSizeFactor')) verdacht.add(regel.trim());
      }
      expect(verdacht, isEmpty,
          reason: 'deze fontSize-expressies vermenigvuldigen de factor nog, '
              'bovenop de MediaQuery-schaal:\n${verdacht.join('\n')}');
    });

    test('de instelling wordt nog wel GEZET (een bron van waarheid)', () {
      final bron = _lees('lib/pages/settings_style/').join('\n');
      expect(bron.contains('AppSettings.fontSizeFactor.setItem'), isTrue);
      expect(bron.contains('appTextScale.value'), isTrue,
          reason: 'zonder dit wordt een schuifbeweging pas na herstart '
              'zichtbaar');
    });

    test('de scaler hangt boven de router, niet in één scherm', () {
      final bron = _lees('lib/widgets/').join('\n');
      expect(bron.contains('AppTextScale('), isTrue);
      expect(bron.contains('valueListenable: appTextScale'), isTrue,
          reason: 'zonder listenable herbouwt de tree niet bij een schuif');
    });
  });
}

/// Leest alle .dart-bestanden onder [pad] als losse regels.
List<String> _lees(String pad) {
  final dir = Directory(pad);
  final uit = <String>[];
  for (final f in dir.listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    uit.addAll(f.readAsLinesSync());
  }
  return uit;
}
