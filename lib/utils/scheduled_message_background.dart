import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Pulsly/utils/scheduled_message_manager.dart';
import 'package:Pulsly/utils/client_manager.dart';

/// Top-level entry point for WorkManager background tasks.
@pragma('vm:entry-point')
void scheduledMessageBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // We only know the task name; dispatch by name.
      if (task == taskScheduledMessageFlush) {
        await _runFlush();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  });
}

const String taskScheduledMessageFlush = 'scheduled_message_flush';

Future<void> _runFlush() async {
  try {
    final store = await SharedPreferences.getInstance();
    final clients = await ClientManager.getClients(store: store);
    await ScheduledMessageManager.flush(
      clients: {for (final c in clients) c.clientName: c},
    );
  } catch (_) {
    // Best-effort; Foreground Scheduler will retry when app regains focus.
  }
  return;
}

/// Schedule a one-off WorkManager task to send due messages at [when].
Future<void> registerScheduledMessageTask(DateTime when) async {
  final now = DateTime.now();
  if (!when.isAfter(now)) return;
  final delay = when.difference(now);
  try {
    await Workmanager().registerOneOffTask(
      'sched_flush_${when.millisecondsSinceEpoch}',
      taskScheduledMessageFlush,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.append,
    );
  } catch (_) {
    // Best-effort; ForegroundAppScheduler will retry when app regains focus.
  }
}
