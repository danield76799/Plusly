import 'dart:async';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/pages/settings_ringtone/settings_ringtone_view.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/widgets/matrix.dart';

class SettingsRingtone extends StatefulWidget {
  const SettingsRingtone({super.key});

  @override
  State<StatefulWidget> createState() => SettingsRingtoneController();
}

class SettingsRingtoneController extends State<SettingsRingtone> {
  late final SharedPreferences store;
  bool ringtonePlaying = false;
  Timer? _ringtoneTimer;

  @override
  void initState() {
    super.initState();
    store = Matrix.of(context).store;
  }

  @override
  void dispose() {
    _ringtoneTimer?.cancel();
    if (ringtonePlaying) {
      Matrix.of(context).voipPlugin?.stopRingtone();
    }
    super.dispose();
  }

  String get currentRingtone {
    return AppSettings.ringtone.value;
  }

  bool get isSystemRingtoneAvailable => PlatformInfos.isMobile;

  void setRingtone(String ringtone) {
    setState(() {
      AppSettings.ringtone.setItem(ringtone);
      previewRingtone();
    });
  }

  void previewRingtone() {
    final voipPlugin = Matrix.of(context).voipPlugin;
    if (ringtonePlaying) {
      ringtonePlaying = false;
      _ringtoneTimer?.cancel();
      voipPlugin?.stopRingtone();
      return;
    }
    ringtonePlaying = true;
    voipPlugin?.playRingtone();
    _ringtoneTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted) return;
      voipPlugin?.stopRingtone();
      if (mounted) setState(() => ringtonePlaying = false);
    });
  }

  @override
  Widget build(BuildContext context) => SettingsRingtoneView(this);
}
