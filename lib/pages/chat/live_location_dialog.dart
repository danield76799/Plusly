import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/widgets/adaptive_dialogs/adaptive_dialog_action.dart';
import 'package:Pulsly/widgets/future_loading_dialog.dart';

class LiveLocationDialog extends StatefulWidget {
  final Room room;

  const LiveLocationDialog({required this.room, super.key});

  @override
  LiveLocationDialogState createState() => LiveLocationDialogState();
}

class LiveLocationDialogState extends State<LiveLocationDialog> {
  bool _disabled = false;
  bool _denied = false;
  bool _isStarting = false;
  Position? _position;
  Object? _error;
  
  // Live location settings
  static const int _defaultTimeoutMinutes = 30;
  int _selectedMinutes = _defaultTimeoutMinutes;
  Timer? _locationUpdateTimer;
  String? _beaconInfoEventId;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      setState(() => _disabled = true);
      return;
    }
    
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _denied = true);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() => _denied = true);
      return;
    }
    
    try {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 30),
          ),
        );
      } on TimeoutException {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 30),
          ),
        );
      }
      setState(() => _position = position);
    } catch (e) {
      setState(() => _error = e);
    }
  }

  Future<void> _startLiveLocation() async {
    if (_position == null) return;
    
    setState(() => _isStarting = true);
    
    try {
      // Step 1: Create the beacon_info event (MSC3489)
      final timeoutMs = _selectedMinutes * 60 * 1000;
      final beaconInfoContent = {
        'description': 'Live Location',
        'timeout': timeoutMs,
        'live': true,
      };
      
      // Send the initial location as the first beacon
      final uri = 'geo:${_position!.latitude},${_position!.longitude};u=${_position!.accuracy}';
      final beaconContent = {
        'uri': uri,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'accuracy': _position!.accuracy,
        'altitude': _position!.altitude,
        'speed': _position!.speed,
      };
      
      // Send beacon_info event
      final result = await showFutureLoadingDialog<Event>(
        context: context,
        future: () => widget.room.sendEvent(
          beaconInfoContent,
          type: 'm.beacon_info.imou',
        ),
      );
      
      final eventId = result.result?.eventId;
      if (eventId != null) {
        _beaconInfoEventId = eventId;
        
        // Send the first beacon location event
        await showFutureLoadingDialog(
          context: context,
          future: () => widget.room.sendEvent(
            beaconContent,
            type: 'm.beacon',
          ),
        );
        
        // Start periodic updates (every 30 seconds)
        _locationUpdateTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => _sendLocationUpdate(),
        );
      }
      
      if (!mounted) return;
      Navigator.of(context, rootNavigator: false).pop();
    } catch (e) {
      setState(() {
        _error = e;
        _isStarting = false;
      });
    }
  }

  Future<void> _sendLocationUpdate() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 15),
        ),
      );
      
      final uri = 'geo:${position.latitude},${position.longitude};u=${position.accuracy}';
      final beaconContent = {
        'uri': uri,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
      };
      
      await widget.room.sendEvent(
        beaconContent,
        type: 'm.beacon',
      );
    } catch (e) {
      // Silently fail for updates
    }
  }

  Future<void> _stopLiveLocation() async {
    _locationUpdateTimer?.cancel();
    
    if (_beaconInfoEventId != null) {
      // Send final beacon_info with live=false
      try {
        await widget.room.sendEvent(
          {
            'description': 'Live Location',
            'timeout': 0,
            'live': false,
          },
          type: 'm.beacon_info.imou',
        );
      } catch (e) {
        // Ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    
    if (_position != null) {
      // Show map preview with timeout selector
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Map preview (reuse existing MapBubble widget)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Timeout selector
          Text(
            'Delen voor:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 5, label: Text('5m')),
              ButtonSegment(value: 15, label: Text('15m')),
              ButtonSegment(value: 30, label: Text('30m')),
              ButtonSegment(value: 60, label: Text('1u')),
            ],
            selected: {_selectedMinutes},
            onSelectionChanged: (selection) {
              setState(() => _selectedMinutes = selection.first);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Je locatie wordt gedeeld tot ${DateTime.now().add(Duration(minutes: _selectedMinutes)).hour}:${DateTime.now().add(Duration(minutes: _selectedMinutes)).minute.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_disabled) {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_disabled, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            L10n.of(context).locationDisabledNotice,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_denied) {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            L10n.of(context).locationPermissionDeniedNotice,
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_error != null) {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            L10n.of(context).errorObtainingLocation(_error.toString()),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      contentWidget = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(width: 12),
          Text(L10n.of(context).obtainingLocation),
        ],
      );
    }
    
    return AlertDialog.adaptive(
      title: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.red),
          const SizedBox(width: 8),
          Text(L10n.of(context).shareLiveLocation),
        ],
      ),
      content: contentWidget,
      actions: [
        AdaptiveDialogAction(
          onPressed: () {
            _locationUpdateTimer?.cancel();
            Navigator.of(context, rootNavigator: false).pop();
          },
          child: Text(L10n.of(context).cancel),
        ),
        if (_position != null)
          AdaptiveDialogAction(
            onPressed: _isStarting ? null : _startLiveLocation,
            child: _isStarting
                ? const CupertinoActivityIndicator()
                : Text(L10n.of(context).startLiveLocation),
          ),
      ],
    );
  }
}