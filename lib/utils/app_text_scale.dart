// App-brede tekstschaal.
//
// WAAROM DIT BESTAAT: `AppSettings.fontSizeFactor` werd alleen in de chat
// toegepast — 28 losse `fontSize: X * AppSettings.fontSizeFactor.value`-plekken
// onder `pages/chat/`. Wie de schuif in Instellingen → Stijl verzet, zag alleen
// de chat meeschalen; de rest van de app (instellingen, lijsten, dialogen,
// knoppen) bleef even groot. Dat leest als een halfwerkende instelling.
//
// WAT DIT DOET: de schaal één keer op de `MediaQuery` zetten, boven de hele
// app. Elke `Text` die géén eigen `textScaler`/`textScaleFactor` meegeeft, leest
// hem daar — dat is het pad `(null, null) => MediaQuery.textScalerOf(context)`
// in Flutter's `Text.build`.
//
// WAT DIT BEWUST NIET DOET: rekenen met het aantal beeldpunten of de
// devicePixelRatio. Dat is "Display size" (de hele UI, inclusief knoppen en
// randen), en dat is een ander mechanisme dat Flutter's ViewConfiguration moet
// overschrijven. Hier gaat het alleen om TEKST.
//
// DE VERMENIGVULDIGING: deze scaler zit BOVENOP de systeemschaal. Iemand die
// Android op "groot" heeft staan én de app-schuif op 1,3 zet, krijgt
// systeemschaal × 1,3. Dat is hetzelfde gedrag als de systeeminstelling: de
// app-schuif is een extra vermenigvuldiger, geen vervanging.
//
// NIET ZICHTBAAR VOOR: tekst die via een `TextPainter` of `CustomPaint` loopt,
// en widgets die expliciet `textScaleFactor:` meegeven (bijv. de `Linkify`-
// aanroepen in de chat, die de systeemschaal al doorgeven). Gecontroleerd: de
// 28 chat-plekken zijn allemaal gewone `Text`-widgets en er staat geen
// `TextPainter` in die bestanden.

import 'package:flutter/widgets.dart';

/// De app-brede tekstschaal als listenable.
///
/// WAAROM EEN EIGEN NOTIFIER: `AppSettings.fontSizeFactor` is een enum-waarde
/// met een synchrone getter naar SharedPreferences — geen [ValueListenable].
/// Er kan dus niet op geluisterd worden, en zonder listenable zou een
/// schuifbeweging pas zichtbaar worden na een herstart.
///
/// De instelling blijft de bron van waarheid (die overleeft een herstart); deze
/// notifier is alleen de brug naar de widget-tree. Wie de schaal zet, moet
/// BEIDE bijwerken — zie `changeFontSizeFactor` in settings_style.dart.
final ValueNotifier<double> appTextScale = ValueNotifier<double>(1.0);

/// Vermenigvuldigt de binnenkomende tekstschaal met [factor].
///
/// Subklasse van [TextScaler] omdat die twee leden verplicht stelt: [scale] en
/// [textScaleFactor]. Flutter's eigen `_LinearTextScaler` is privé, dus dit is
/// de enige manier om een eigen schaal in te brengen zonder het hele
/// `MediaQueryData` te vervangen.
@immutable
class AppTextScaler extends TextScaler {
  /// De schaal die de app-instelling toevoegt (1.0 = niets extra).
  final double factor;

  /// De schaal die al gold — doorgaans de systeemschaal van het toestel.
  final TextScaler base;

  const AppTextScaler(this.factor, [this.base = TextScaler.noScaling]);

  @override
  double scale(double fontSize) => base.scale(fontSize) * factor;

  // `textScaleFactor` is in Flutter deprecated ten gunste van de niet-lineaire
  // `scale()`, maar het is nog steeds een VERPLICHT lid van `TextScaler`: een
  // subklasse zonder deze override compileert niet. De deprecation-melding is
  // hier dus onvermijdelijk — vandaar de ignore.
  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  TextScaler clamp({
    double minScaleFactor = 0,
    double maxScaleFactor = double.infinity,
  }) {
    return AppTextScaler(
      factor,
      base.clamp(
        minScaleFactor: minScaleFactor,
        maxScaleFactor: maxScaleFactor,
      ),
    );
  }

  /// Zonder `==` en `hashCode` bouwt Flutter de hele boom opnieuw op elke keer
  /// dat deze scaler een nieuw object wordt, ook als de factor gelijk bleef.
  @override
  bool operator ==(Object other) =>
      other is AppTextScaler && other.factor == factor && other.base == base;

  @override
  int get hashCode => Object.hash(factor, base);

  @override
  String toString() => 'AppTextScaler(${factor}x, base: $base)';
}

/// Zet [AppTextScaler] op de [MediaQuery] boven de hele app.
///
/// [factor] komt uit `AppSettings.fontSizeFactor`; de schaal die al in de
/// MediaQuery stond (de systeemschaal) blijft de basis.
///
/// Bij factor 1.0 wordt de bestaande MediaQuery ONGEWIJZIGD teruggegeven. Dat
/// houdt het standaardpad — en dus elke bestaande golden/render-test — exact
/// gelijk aan voorheen.
class AppTextScale extends StatelessWidget {
  final double factor;
  final Widget child;

  const AppTextScale({super.key, required this.factor, required this.child});

  @override
  Widget build(BuildContext context) {
    if (factor == 1.0) return child;
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: AppTextScaler(factor, media.textScaler),
      ),
      child: child,
    );
  }
}
