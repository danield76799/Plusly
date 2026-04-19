import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/pages/profile/profile.dart';
import 'package:Pulsly/utils/adaptive_bottom_sheet.dart';
import 'package:Pulsly/utils/platform_infos.dart';

void showProfile({
  required BuildContext context,
  required Profile profile,
  bool noProfileWarning = false,
}) {
  final url = Uri(
    path: '/user/${profile.userId}',
    queryParameters: <String, dynamic>{
      'display_name': profile.displayName,
      'avatar_uri': profile.avatarUrl?.toString(),
      'no_profile_warning': noProfileWarning.toString(),
    },
  ).toString();
  if (PlatformInfos.isMobile) {
    context.push(url);
  } else {
    showAdaptiveBottomSheet(
      context: context,
      builder: (p0) => ProfilePage(profile, noProfileWarning: noProfileWarning),
      useRootNavigator: true, // we are PROBABLY not on mobile, use root nav
    );
  }
}
