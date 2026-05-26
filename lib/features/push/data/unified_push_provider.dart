import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/unifiedpush.dart' as up;

import '../domain/push_provider.dart' hide PushMessage;
import '../domain/push_provider.dart' show PushProvider, PushProviderType, PushMessage;
import '../../../config/app_config.dart';
import '../../../utils/platform_infos.dart';
/// UnifiedPush implementatie — privacy-friendly push zonder Google.
///
/// Vereist een UnifiedPush distributor app (bijv. ntfy, UP-FCM distributor).
class UnifiedPushProvider implements PushProvider {
  final SharedPreferences _store;
  final List<Client> _clients;
  final _messageController = StreamController<PushMessage>.broadcast();

  bool _isActive = false;
  String? _currentEndpoint;

  @override
  String get id => 'unifiedpush';

  @override
  String get displayName => 'UnifiedPush';

  @override
  bool get isAvailable => Platform.isAndroid;

  @override
  bool get isActive => _isActive;

  UnifiedPushProvider(this._store, this._clients);

  @override
  Future<bool> initialize() async {
    if (!isAvailable) return false;

    try {
      await up.UnifiedPush.initialize(
        onNewEndpoint: (endpoint, instance) => _onNewEndpoint(endpoint, instance),
        onRegistrationFailed: (reason, instance) => _onRegistrationFailed(reason.toString(), instance),
        onUnregistered: (instance) => _onUnregistered(instance),
        onMessage: (message, instance) => _onUpMessage(message, instance),
      );
      return true;
    } catch (e, s) {
      Logs().e('[UnifiedPush] Init failed', e, s);
      return false;
    }
  }

  @override
  Future<String?> register() async {
    if (!isAvailable) return null;

    final distributors = await up.UnifiedPush.getDistributors();
    if (distributors.isEmpty) {
      Logs().i('[UnifiedPush] No distributors found');
      return null;
    }

    // Check of we al geregistreerd zijn
    final savedDistributor = await up.UnifiedPush.getDistributor();
    if (savedDistributor != null && savedDistributor.isNotEmpty) {
      if (await _hasValidEndpoint()) {
        _isActive = true;
        return _getStoredEndpoint();
      }
    }

    // Kies distributor
    final selected = await _selectDistributor(distributors);
    if (selected == null) {
      Logs().w('[UnifiedPush] No distributor selected');
      return null;
    }

    await up.UnifiedPush.saveDistributor(selected);

    // Registreer voor elke ingelogde client
    for (final client in _clients.where((c) => c.isLogged())) {
      await up.UnifiedPush.register(instance: client.clientName);
    }

    _isActive = true;
    return null; // Endpoint komt async binnen via onNewEndpoint
  }

  @override
  Future<void> unregister() async {
    try {
      for (final client in _clients.where((c) => c.isLogged())) {
        await up.UnifiedPush.unregister(instance: client.clientName);
      }
    } catch (e, s) {
      Logs().w('[UnifiedPush] Unregister failed', e, s);
    }
    _isActive = false;
    _currentEndpoint = null;
  }

  @override
  Stream<PushMessage> get messageStream => _messageController.stream;

  // ─── Interne handlers ───

  Future<void> _onNewEndpoint(up.PushEndpoint endpoint, String instance) async {
    final url = endpoint.url;
    if (url.isEmpty) {
      await _onUnregistered(instance);
      return;
    }

    final gatewayUrl = await _detectGatewayUrl(url);
    final client = _clientFromInstance(instance);
    if (client == null) return;

    await _setupPusher(
      client: client,
      gatewayUrl: gatewayUrl,
      token: url,
      useDeviceSpecificAppId: true,
    );

    await _store.setString('${client.clientName}_up_endpoint', url);
    await _store.setBool('${client.clientName}_up_registered', true);

    _currentEndpoint = url;
    _isActive = true;

    Logs().i('[UnifiedPush] Registered for ${client.clientName}: $url');
  }

  Future<void> _onRegistrationFailed(String error, String instance) async {
    Logs().e('[UnifiedPush] Registration failed: $error');
    _isActive = false;
  }

  Future<void> _onUnregistered(String instance) async {
    final client = _clientFromInstance(instance);
    if (client == null) return;

    final endpointKey = '${client.clientName}_up_endpoint';
    final registeredKey = '${client.clientName}_up_registered';
    final oldEndpoint = _store.getString(endpointKey) ?? '';

    await _store.setString(endpointKey, '');
    await _store.setBool(registeredKey, false);

    if (oldEndpoint.isNotEmpty) {
      await _removePusher(client, oldEndpoint);
    }

    _isActive = false;
    Logs().i('[UnifiedPush] Unregistered for ${client.clientName}');
  }

  Future<void> _onUpMessage(up.PushMessage message, String instance) async {
    try {
      final data = Map<String, dynamic>.from(
        json.decode(utf8.decode(message.content))['notification'],
      );
      data['devices'] ??= [];

      _messageController.add(PushMessage.fromJson(data));
    } catch (e, s) {
      Logs().e('[UnifiedPush] Failed to parse message', e, s);
    }
  }

  // ─── Helpers ───

  Future<String> _detectGatewayUrl(String endpoint) async {
    const defaultGateway =
        'https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify';

    try {
      final url = Uri.parse(endpoint)
          .replace(path: '/_matrix/push/v1/notify', query: '')
          .toString()
          .split('?')
          .first;

      final res = json.decode(
        utf8.decode((await http.get(Uri.parse(url))).bodyBytes),
      );

      if (res['gateway'] == 'matrix' ||
          (res['unifiedpush'] is Map &&
              res['unifiedpush']['gateway'] == 'matrix')) {
        return url;
      }
    } catch (_) {
      Logs().i('[UnifiedPush] No self-hosted gateway, using default');
    }

    return defaultGateway;
  }

  Future<bool> _hasValidEndpoint() async {
    for (final client in _clients.where((c) => c.isLogged())) {
      final endpoint = _store.getString('${client.clientName}_up_endpoint');
      final registered =
          _store.getBool('${client.clientName}_up_registered') ?? false;
      if (endpoint != null && endpoint.isNotEmpty && registered) {
        return true;
      }
    }
    return false;
  }

  String? _getStoredEndpoint() {
    for (final client in _clients.where((c) => c.isLogged())) {
      final endpoint = _store.getString('${client.clientName}_up_endpoint');
      if (endpoint != null && endpoint.isNotEmpty) {
        return endpoint;
      }
    }
    return null;
  }

  Future<String?> _selectDistributor(List<String> distributors) async {
    if (distributors.length == 1) return distributors.first;

    // TODO: Toon picker dialog via navigatorKey
    // Voor nu: gebruik eerste
    Logs().i('[UnifiedPush] Multiple distributors, using first: ${distributors.first}');
    return distributors.first;
  }

  Client? _clientFromInstance(String instance) {
    return _clients.firstWhereOrNull((c) => c.clientName == instance);
  }

  Future<void> _setupPusher({
    required Client client,
    required String gatewayUrl,
    required String token,
    required bool useDeviceSpecificAppId,
  }) async {
    try {
      final clientName = PlatformInfos.clientName;
      final pushers = await client.getPushers().catchError((e) {
        Logs().w('[UnifiedPush] Unable to get pushers', e);
        return <Pusher>[];
      }) ?? [];

      var appId = AppConfig.pushNotificationsAppId;
      if (useDeviceSpecificAppId) {
        appId = '$appId.${client.deviceID}';
        if (appId.length > 64) appId = appId.substring(0, 64);
      } else {
        appId += '.data_message';
      }

      // Check if pusher already set correctly
      final existing = pushers.firstWhereOrNull(
        (p) => p.pushkey == token && p.appId == appId,
      );
      if (existing != null &&
          existing.kind == 'http' &&
          existing.data.url.toString() == gatewayUrl &&
          existing.appDisplayName == clientName &&
          existing.deviceDisplayName == client.deviceName) {
        Logs().i('[UnifiedPush] Pusher already set for ${client.clientName}');
        return;
      }

      // Remove old pushers for this device
      for (final pusher in pushers) {
        if (pusher.appId == appId && pusher.pushkey != token) {
          await client.deletePusher(pusher);
        }
      }

      // Set new pusher
      await client.postPusher(
        Pusher(
          pushkey: token,
          appId: appId,
          appDisplayName: clientName,
          deviceDisplayName: client.deviceName ?? 'Plusly',
          lang: 'en',
          data: PusherData(
            url: Uri.parse(gatewayUrl),
            format: 'event_id_only',
          ),
          kind: 'http',
        ),
        append: false,
      );

      Logs().i('[UnifiedPush] Pusher set for ${client.clientName}');
    } catch (e, s) {
      Logs().e('[UnifiedPush] Failed to set pusher', e, s);
    }
  }

  Future<void> _removePusher(Client client, String endpoint) async {
    try {
      final pushers = await client.getPushers().catchError((e) {
        Logs().w('[UnifiedPush] Unable to get pushers', e);
        return <Pusher>[];
      }) ?? [];

      final pusher = pushers.firstWhereOrNull((p) => p.pushkey == endpoint);
      if (pusher != null) {
        await client.deletePusher(pusher);
        Logs().i('[UnifiedPush] Pusher removed for ${client.clientName}');
      }
    } catch (e, s) {
      Logs().e('[UnifiedPush] Failed to remove pusher', e, s);
    }
  }

  @override
  void dispose() {
    _messageController.close();
  }
}
