import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../utils/notification_background_handler.dart';

/// 🆕 Moderne notification router die werkt ZONDER IsolateNameServer.
/// 
/// Gebruikt een static callback pattern dat compatibel is met
/// flutter_local_notifications background handling.
class NotificationRouter {
  static GoRouter? _router;
  static List<Client>? _clients;
  static final _tapController = StreamController<NotificationResponse>.broadcast();

  /// Initialiseer de router met dependencies
  static void initialize({
    GoRouter? router,
    required List<Client> clients,
  }) {
    _router = router;
    _clients = clients;
  }

  /// Stream van notification taps (voor intern gebruik)
  static Stream<NotificationResponse> get tapStream => _tapController.stream;

  /// Handler voor foreground notification taps
  static void onTap(NotificationResponse response) {
    _tapController.add(response);
    _handleTap(response);
  }

  /// Handler voor background notification taps
  /// 
  /// ⚠️ Dit moet een static functie zijn voor flutter_local_notifications
  @pragma('vm:entry-point')
  static void onBackgroundTap(NotificationResponse response) {
    // In background mode: sla op voor later of gebruik isolate communicatie
    // Voor nu: log alleen (het echte werk gebeurt in notificationTapBackground)
    _tapController.add(response);
  }

  static void _handleTap(NotificationResponse response) {
    if (_router == null || _clients == null) {
      Logs().w('[NotificationRouter] Not initialized, ignoring tap');
      return;
    }

    notificationTap(
      response,
      clients: _clients!,
      router: _router,
    );
  }

  /// Cleanup
  static void dispose() {
    _tapController.close();
    _router = null;
    _clients = null;
  }
}
