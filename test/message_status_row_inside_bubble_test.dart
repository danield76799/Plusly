// Reproduceert de afgekapte tijd in de berichtbubbel: bij een kort
// bericht ("Hi") moet het tijdstip volledig zichtbaar zijn binnen de
// bubbel.
//
// De bug: de voettekst (tijd + vinkjes) is breder dan de bubbel, waardoor
// Align(alignment: centerRight) het naar buiten duwt. De linkerkant wordt
// dan door de ClipRRect van de bubbel afgesneden: "20:04" wordt "0:04".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/message_status_row.dart';

void main() {
  testWidgets('het tijdstip valt binnen de bubbel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: L10n.localizationsDelegates,
        supportedLocales: L10n.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        ),
        home: Scaffold(
          body: Center(
            // Zelfde opbouw als in de berichtbubbel: de IntrinsicWidth
            // bepaalt de breedte van de bubbel, en de ClipRRect knipt af.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hi'),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8, left: 4),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: MessageStatusRow(
                          timestamp: DateTime(2026, 10, 29, 20, 4),
                          ownMessage: true,
                          hasBeenRead: true,
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
      ),
    );
    await tester.pumpAndSettle();

    final bubbel = tester.getRect(find.byType(IntrinsicWidth));
    final tijd = tester.getRect(find.text('20:04'));

    expect(
      tijd.left,
      greaterThanOrEqualTo(bubbel.left - 0.01),
      reason: 'de tijd loopt uit de bubbel en wordt afgeknipt '
          '(bubbel $bubbel, tijd $tijd)',
    );
    expect(tijd.right, lessThanOrEqualTo(bubbel.right + 0.01));
    expect(tester.takeException(), isNull);
  });
}
