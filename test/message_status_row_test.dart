// Regressietest: de voettekst van een bericht (tijd + vinkjes) mag niet
// breder zijn dan de bubbel, anders wordt de tijd links afgeknipt.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/message_status_row.dart';

void main() {
  testWidgets('de voettekst past binnen de bubbel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        // 24-uurs tijd, zodat de tijd "14:00" is en niet "2:00 PM".
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            // Zelfde opbouw als in de berichtbubbel: de IntrinsicWidth
            // bepaalt de breedte van de bubbel.
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ok'),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8, left: 4),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: MessageStatusRow(
                        timestamp: DateTime(2026, 10, 26, 14, 0),
                        ownMessage: true,
                        hasBeenRead: false,
                        status: EventStatus.sent,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // De vertalingen laden asynchroon (deferred loading): even wachten tot
    // de eerste frames binnen zijn.
    await tester.pumpAndSettle();
    final wrapWidth = tester.getSize(find.byType(Wrap)).width;
    final textWidth = tester.getSize(find.text('14:00')).width;
    final iconWidth = tester.getSize(find.byType(Icon).first).width;

    // De Wrap moet minstens zo breed zijn als de som van zijn kinderen,
    // anders loopt de inhoud naar buiten (en wordt de tijd afgeknipt).
    expect(
      wrapWidth,
      greaterThanOrEqualTo(textWidth + iconWidth),
      reason: 'voettekst is te smal en loopt uit de bubbel',
    );
    expect(tester.takeException(), isNull);
  });
}
