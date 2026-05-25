import 'dart:async';

import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/push_provider.dart';

/// Firebase Cloud Messaging fallback provider.
///
/// Werkt op alle platforms, vereist Google Play Services.
class FirebasePushProvider implements PushProvider {
  final SharedPreferences _store;
  final List<Client> _clients;
  final _messageController = StreamController<PushMessage>.broadcast();

  bool _isActive = false;

  @override
  String get id => 'firebase';

  @override
  String get displayName => 'Firebase Cloud Messaging';

  @override
  bool get isAvailable => true; // Overal beschikbaar als fallback

  @override
  bool get isActive => _isActive;

  FirebasePushProvider(this._store, this._clients);

  @override
  Future<bool> initialize() async {
    // FCM initialiseert zichzelf via Firebase core
    // Geen expliciete init nodig voor basis functionaliteit
    return true;
  }

  @override
  Future<String?> register() async {
    // TODO: Implementeer FCM token ophalen
    // Dit vereist firebase_messaging package integratie
    //
    // Pseudocode:
    // final token = await FirebaseMessaging.instance.getToken();
    // if (token != null) {
    //   await _setupPusherForAllClients(token);
    //   _isActive = true;
    //   return token;
    // }

    Logs().w('[FirebasePush] Not yet implemented — using legacy BackgroundPush');
    return null;
  }

  @override
  Future<void> unregister() async {
    // TODO: Implementeer FCM cleanup
    _isActive = false;
  }

  @override
  Stream<PushMessage> get messageStream => _messageController.stream;

  @override
  void dispose() {
    _messageController.close();
  }
}
