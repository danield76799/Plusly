import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/utils/push_event_log.dart';

/// Push-instrumentatie die FluffyChat wél heeft en Plusly miste:
///
/// 1. [schrijfCrashRapport] — FC push_helper.dart r55-63: bij een crash in de
///    push-helper worden error + stack weggeschreven naar prefs zodat
///    Instellingen → Meldingen ze kan tonen. Zonder dit blijft een push-crash
///    onzichtbaar (alleen console-logging, die niemand ziet).
/// 2. [markeerLaatstePush] — FC's `lastReceivedPushNotification`-map: per
///    client de tijd van de laatst ontvangen push. In Plusly bewaard in prefs
///    zodat ook de UI het kan lezen; sluit het "Last push timestamp: none"-
///    gat in de push-debugscreen-samenvatting.
class PushHelperInstrumentation {
  /// Schrijf een crash-rapport. Alleen niet-uitputtende fouten (FC filtert
  /// TimeoutException/IOException/ClientException uit — die zijn
  /// verwachtbaar bij netwerkproblemen en zijn geen code-bugs).
  static Future<void> schrijfCrashRapport(
    Object error,
    StackTrace stack,
  ) async {
    try {
      final store = await SharedPreferences.getInstance();
      await store.setStringList(AppConfig.pushHelperCrashReportKey, [
        error.toString(),
        stack.toString(),
      ]);
    } catch (_) {
      // Rapporteren mag nooit crashen.
    }
  }

  /// Registreer de laatst ontvangen push per client.
  static Future<void> markeerLaatstePush(String? clientName) async {
    if (clientName == null || clientName.isEmpty) return;
    try {
      final store = await SharedPreferences.getInstance();
      await store.setInt(
        'push_last_received_ts_$clientName',
        DateTime.now().millisecondsSinceEpoch,
      );
      PushEventLog().add('push_timestamp', {'client': clientName});
    } catch (_) {}
  }
}