/// Build flavor, passed via --dart-define=APP_FLAVOR=play|github.
///
/// - "play"  : Play-Store build (AAB). In-app updates use the official
///             Google Play In-App Updates API. No REQUEST_INSTALL_PACKAGES.
/// - "github": Sideload/APK build. Keeps REQUEST_INSTALL_PACKAGES for direct
///             APK install + browser download from GitHub releases.
///
/// Defaults to "github" so local debug/release builds keep sideload working.
const String kAppFlavor =
    String.fromEnvironment('APP_FLAVOR', defaultValue: 'github');

/// True when building the Play-Store compliant flavor.
bool get isPlayFlavor => kAppFlavor == 'play';
