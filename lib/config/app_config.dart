import 'dart:ui';

abstract class AppConfig {
  // Const and final configuration values (immutable)
  static const Color primaryColor = Color(0xFF49AFC2);
  static const Color primaryColorLight = Color(0xFF6FC5D8);
  static const Color secondaryColor = Color(0xFF3A8FA0);

  static const Color chatColor = primaryColor;
  static const double messageFontSize = 16.0;
  static const bool allowOtherHomeservers = true;
  static const bool enableRegistration = true;
  static const bool hideTypingUsernames = false;

  static const String inviteLinkPrefix = 'https://matrix.to/#/';
  static const String deepLinkPrefix = 'com.danield.plusly://chat/';
  static const String schemePrefix = 'matrix:';
  static const String pushNotificationsChannelId = 'plusly_push';
  static const String pushNotificationsAppId = 'com.danield.plusly';
  static const double borderRadius = 16.0;
  static const double spaceBorderRadius = 11.0;
  static const double columnWidth = 360.0;

  static const String enablePushTutorial =
      'https://github.com/krille-chan/fluffychat/wiki/Push-Notifications-without-Google-Services';
  static const String encryptionTutorial =
      'https://github.com/krille-chan/fluffychat/wiki/How-to-use-end-to-end-encryption-in-FluffyChat';
  static const String startChatTutorial =
      'https://github.com/krille-chan/fluffychat/wiki/How-to-Find-Users-in-FluffyChat';
  static const String howDoIGetStickersTutorial =
      'https://fluffychat.im/faq/#how_do_i_get_stickers';
  static const String appId = 'com.danield.plusly';
  static const String appOpenUrlScheme = 'com.danield.plusly';
  static const String appSsoUrlScheme = 'com.danield.plusly.auth';

  static const String sourceCodeUrl =
      'https://github.com/danield76799/Plusly';
  static const String supportUrl =
      'https://plusly.im/help';
  static const String changelogUrl = 'https://plusly.im/changelog';

  static const Set<String> defaultReactions = {'👍', '❤️', '😂', '😮', '😢'};

  static final Uri newIssueUrl = Uri(
    scheme: 'https',
    host: 'github.com',
    path: '/danield76799/Plusly/issues/new',
  );

  static final Uri homeserverList = Uri(
    scheme: 'https',
    host: 'raw.githubusercontent.com',
    path: 'krille-chan/fluffychat/refs/heads/main/recommended_homeservers.json',
  );

  static const String mainIsolatePortName = 'main_isolate';
  static const String pushIsolatePortName = 'push_isolate';
}
