import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/services/live_location_manager.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/widgets/adaptive_dialogs/adaptive_dialog_action.dart';

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

  static const int _defaultTimeoutMinutes = 30;
  int _selectedMinutes = _defaultTimeoutMinutes;

  @override
  void initState() {
    super.initState();
    _requestLocation();
  }

  @override
  void dispose() {
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
      await LiveLocationManager().startSharing(
        widget.room,
        minutes: _selectedMinutes,
      );

      // Send info message to the room
      final endTime = DateTime.now().add(Duration(minutes: _selectedMinutes));
      await widget.room.sendTextEvent(
        '📍 Live locatie actief voor $_selectedMinutes minuten (tot ${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')})',
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: false).pop();
    } catch (e) {
      setState(() {
        _error = e;
        _isStarting = false;
      });
    }
  }

  String _getEndTime() {
    final endTime = DateTime.now().add(Duration(minutes: _selectedMinutes));
    return '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;

    if (_position != null) {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Text(L10n.of(context).shareFor, style: Theme.of(context).textTheme.titleSmall),
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
            'Je locatie wordt gedeeld tot ${_getEndTime()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
          Text(L10n.of(context).locationDisabledNotice, textAlign: TextAlign.center),
        ],
      );
    } else if (_denied) {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(L10n.of(context).locationPermissionDeniedNotice, textAlign: TextAlign.center),
        ],
      );
    } else if (_error != null) {
      contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(L10n.of(context).errorObtainingLocation(_error.toString()), textAlign: TextAlign.center),
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