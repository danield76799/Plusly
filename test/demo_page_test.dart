import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/demo/demo_page.dart';

Widget _app(Widget child) => MaterialApp(
      locale: const Locale('nl'),
      localizationsDelegates: L10n.localizationsDelegates,
      supportedLocales: L10n.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('demo opent zonder login en toont voorbeeldgesprekken',
      (tester) async {
    await tester.pumpWidget(_app(const DemoPage()));
    await tester.pumpAndSettle();

    expect(find.text('Tamara'), findsOneWidget);
    expect(find.text('Familie App'), findsOneWidget);
    expect(find.textContaining('demo'), findsWidgets);
  });

  testWidgets('demo-gesprek stuurt een lokaal bericht', (tester) async {
    await tester.pumpWidget(_app(const DemoPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tamara'));
    await tester.pumpAndSettle();

    expect(find.text('Zal ik ze bij je afgeven of leg je ze klaar?'),
        findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Tot zo!');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tot zo!'), findsOneWidget);
  });
}
