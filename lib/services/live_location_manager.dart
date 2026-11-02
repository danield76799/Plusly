import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/utils/platform_infos.dart';

class LiveLocationManager {
  // Singleton pattern
  static final LiveLocationManager _instance = LiveLocationManager._internal();
  factory LiveLocationManager() => _instance;
  LiveLocationManager._internal();

  Timer? _updateTimer;
  Room? _activeRoom;
  int _durationMinutes = 30;

  bool get isSharing => _updateTimer != null;

  void stopSharing() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _activeRoom = null;
  }

  Future<void> startSharing(Room room, {int minutes = 30}) async {
    stopSharing(); // Stop any existing share
    _activeRoom = room;
    _durationMinutes = minutes;

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

      final body = 'https://www.openstreetmap.org/?mlat=${position.latitude}&mlon=${position.longitude}#map=16/${position.latitude}/${position.longitude}';
      final uri = 'geo:${position.latitude},${position.longitude};u=${position.accuracy}';

      await _activeRoom?.sendEvent(
        {
          'msgtype': 'm.location',
          'body': body,
          'geo_uri': uri,
        },
        type: EventTypes.Message,
      );
    } catch (e) {
      // Silently fail for background updates
    }
  }
}
