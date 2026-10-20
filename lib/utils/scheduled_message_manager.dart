import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:matrix/matrix.dart';

/// Een gepland bericht. Wordt opgeslagen in SharedPreferences en verstuurd
/// via een WorkManager-taak wanneer de gekozen tijd is verstreken.
class ScheduledMessage {
  final String id;
  final String roomId;
  final String clientName;
  final String content;
  final DateTime scheduledAt;
  bool sent;
  String? error;

  ScheduledMessage({
    required this.id,
    required this.roomId,
    required this.clientName,
    required this.content,
    required this.scheduledAt,
    this.sent = false,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'clientName': clientName,
    'content': content,
    'scheduledAt': scheduledAt.toIso8601String(),
    'sent': sent,
    'error': error,
  };

  factory ScheduledMessage.fromJson(Map<String, dynamic> j) => ScheduledMessage(
    id: j['id'] as String,
    roomId: j['roomId'] as String,
    clientName: j['clientName'] as String,
    content: j['content'] as String,
    scheduledAt: DateTime.parse(j['scheduledAt'] as String),
    sent: (j['sent'] as bool?) ?? false,
    error: j['error'] as String?,
  );
}

class ScheduledMessageManager {
  static const _key = 'scheduled_messages.v1';

  static Future<List<ScheduledMessage>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ScheduledMessage.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveAll(List<ScheduledMessage> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  static String _newId() =>
      'sched_${DateTime.now().microsecondsSinceEpoch}_${(9999 * (1.0)).round()}';

  static Future<ScheduledMessage> schedule({
    required String roomId,
    required String clientName,
    required String content,
    required DateTime when,
  }) async {
    final items = await loadAll();
    final msg = ScheduledMessage(
      id: _newId(),
      roomId: roomId,
      clientName: clientName,
      content: content,
      scheduledAt: when,
    );
    items.add(msg);
    await _saveAll(items);
    return msg;
  }

  static Future<bool> cancel(String id) async {
    final items = await loadAll();
    final n = items.length;
    items.removeWhere((m) => m.id == id);
    if (items.length == n) return false;
    await _saveAll(items);
    return true;
  }

  static Future<ScheduledMessage?> find(String id) async {
    final items = await loadAll();
    try {
      return items.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static Future<void> markSent(String id) async {
    final items = await loadAll();
    for (final m in items) {
      if (m.id == id) {
        m.sent = true;
      }
    }
    await _saveAll(items);
  }

  static Future<void> markFailed(String id, String error) async {
    final items = await loadAll();
    for (final m in items) {
      if (m.id == id) {
        m.error = error;
      }
    }
    await _saveAll(items);
  }

  /// Parseer `/sch <delay> <boodschap>` of `/schedule <delay> <boodschap>`.
  /// delay: 5s, 10m, 2h, 1d. Bovenaan slash kan met of zonder spatie.
  static ({DateTime when, Duration delay, String message, String delayHuman})? parseSchedule(String input) {
    final t = input.trim();
    if (!t.toLowerCase().startsWith('/sch')) return null;
    final rest = t.substring('/sch'.length).trim();
    final m = RegExp(r'^(\d+)\s*([smhd])\s+(.+)$', dotAll: true).firstMatch(rest);
    if (m == null) return null;
    final n = int.tryParse(m.group(1)!) ?? 0;
    final unit = m.group(2)!.toLowerCase();
    final msg = m.group(3)!.trim();
    if (msg.isEmpty) return null;
    final Duration dur;
    switch (unit) {
      case 's': dur = Duration(seconds: n); break;
      case 'm': dur = Duration(minutes: n); break;
      case 'h': dur = Duration(hours: n); break;
      case 'd': dur = Duration(days: n); break;
      default: return null;
    }
    final when = DateTime.now().add(dur);
    final human = dur.inDays > 0 ? '${dur.inDays} dag(en)' :
       dur.inHours > 0 ? '$n uur' :
       dur.inMinutes > 0 ? '$n minuten' : '$n seconden';
    return (when: when, delay: dur, message: msg, delayHuman: human);
  }
  /// Berichten die verstuurd moeten worden (due_time bereikt, niet yet sent).
  static Future<List<ScheduledMessage>> due() async {
    final now = DateTime.now();
    final items = await loadAll();
    return items
        .where((m) => !m.sent && m.scheduledAt.isBefore(now))
        .toList();
  }

  static Future<void> cleanupSent() async {
    final items = await loadAll();
    items.removeWhere((m) => m.sent);
    await _saveAll(items);
  }

  /// Verstuur alle due messages met de opgegeven client-map.
  static Future<int> flush({
    required Map<String, Client> clients,
  }) async {
    final due = await ScheduledMessageManager.due();
    var sent = 0;
    for (final msg in due) {
      final client = clients[msg.clientName];
      if (client == null) {
        await ScheduledMessageManager.markFailed(msg.id, 'client_not_found');
        continue;
      }
      final room = client.rooms.firstWhere(
        (r) => r.id == msg.roomId,
        orElse: () => throw Exception('room_not_found'),
      );
      try {
        final eventId = await room.sendTextEvent(msg.content);
        if (eventId != null) {
          await ScheduledMessageManager.markSent(msg.id);
          sent++;
        } else {
          await ScheduledMessageManager.markFailed(msg.id, 'send_failed');
        }
      } catch (e) {
        await ScheduledMessageManager.markFailed(msg.id, e.toString());
      }
    }
    if (sent > 0) await cleanupSent();
    return sent;
  }
}
