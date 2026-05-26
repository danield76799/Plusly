import 'dart:io';

import 'package:Pulsly/utils/platform_infos.dart';

String getDownloadsDirectory() {
  if (PlatformInfos.isAndroid) {
    return "/sdcard/Download/Plusly";
  } else if (PlatformInfos.isLinux) {
    return "${Platform.environment['HOME']}/Downloads/Plusly";
  } else if (PlatformInfos.isWindows) {
    return "${Platform.environment['USERPROFILE']}\\Downloads\\Extera";
  }

  return "";
}
