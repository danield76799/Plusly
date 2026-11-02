import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/foreground_services.dart';

class LiveLocationManager {
  // Singleton pattern
  static final LiveLocationManager _instance = LiveLocationManager._internal();
  factory LiveLocationManager() => _instance;
  LiveLocationManager._internal();

  Timer? _updateTimer;
  Room? _activeRoom;
  int _durationMinutes = 30;
  Position? _lastSentPosition;
  DateTime? _expiryDate;

  bool get isSharing => _updateTimer != null;

  void stopSharing() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _activeRoom = null;
    _lastSentPosition = null;
    _expiryDate = null;
    
    if (ForegroundServices.platformSupported) {
      ForegroundServices.stopService(ForegroundServices.liveLocationService);
    }
  }

  Future<void> startSharing(Room room, {int minutes = 30}) async {
    stopSharing(); // Stop any existing share
    _activeRoom = room;
    _durationMinutes = minutes;
    _expiryDate = DateTime.now().add(Duration(minutes: minutes));

    if (ForegroundServices.platformSupported) {
      await ForegroundServices.startService(ForegroundServices.liveLocationService);
    }

    // Send initial location immediately
    await _sendCurrentLocation();

    // Start periodic updates
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (_activeRoom == null) {
        stopSharing();
        return;
      }
      await _sendCurrentLocation();
    });

    // Auto-stop after the selected duration
    Timer(Duration(minutes: minutes), () {
      stopSharing();
    });
  }

  Future<void> _sendCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Battery optimization: only send if moved > 10 meters
      if (_lastSentPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastSentPosition!.latitude,
          _lastSentPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance < 10.0) {
          return; // Too close, skip update
        }
      }

      _lastSentPosition = position;

      final body = 'https://www.openstreetmap.org/?mlat=${position.latitude}&mlon=${position.longitude}#map=16/${position.latitude}/${position.longitude}';
      final uri = 'geo:${position.latitude},${position.longitude};u=${position.accuracy}';

      await _activeRoom?.sendEvent(
        {
          'msgtype': 'm.location',
          'body': body,
          'geo_uri': uri,
          'live_location': true,
          'expires_at': _expiryDate?.toIso8601String(),
        },
        type: EventTypes.Message,
      );
    } catch (e) {
      // Silently fail for background updates
    }
  }
}