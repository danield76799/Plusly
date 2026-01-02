import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class DialerTaskHandler extends TaskHandler {

  final void Function() muteMicrophone;
  final void Function() switchSpeaker;
  final void Function() hangUp;

  DialerTaskHandler({
    required this.muteMicrophone,
    required this.switchSpeaker,
    required this.hangUp,
  });

  @override
  void onNotificationButtonPressed(String id) {
    switch (id) {
      case 'mute':
        muteMicrophone();
        break;
      case 'speaker':
        switchSpeaker();
        break;
      case 'hangup':
        hangUp();
        break;
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
  
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    
  }

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {

  }

}