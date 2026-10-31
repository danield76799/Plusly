import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:Pulsly/config/setting_keys.dart';
import 'app_config.dart';

abstract class FluffyThemes {
  static const double columnWidth = 380.0;

  static const double navRailWidth = 80.0;

  static bool isColumnModeByWidth(double width) =>
      width > columnWidth * 2 + navRailWidth;

  static bool isColumnMode(BuildContext context) =>
      isColumnModeByWidth(MediaQuery.sizeOf(context).width);

  static bool isThreeColumnMode(BuildContext context) =>
      MediaQuery.sizeOf(context).width > FluffyThemes.columnWidth * 3.5;

  static LinearGradient backgroundGradient(BuildContext context, int alpha) {
    final colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topCenter,
      colors: [
        colorScheme.primaryContainer.withAlpha(alpha),
        colorScheme.secondaryContainer.withAlpha(alpha),
        colorScheme.tertiaryContainer.withAlpha(alpha),
        colorScheme.primaryContainer.withAlpha(alpha),
      ],
    );
  }

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Curve animationCurve = Curves.easeInOut;

  static ThemeData buildTheme(
    BuildContext context,
    Brightness brightness, [
    Color? seed,
    DynamicSchemeVariant? variant,
    bool? pureBlack,
    bool? twemoji,
  ]) {
    final extraDarkColors = (brightness == Brightness.dark && pureBlack == true)
        ? {
            'surface': const Color.fromARGB(255, 0, 0, 0),
            'surfaceBright': const Color.fromARGB(255, 0, 0, 0),
            'surfaceContainer': const Color.fromARGB(255, 11, 11, 11),
            'surfaceContainerHigh': const Color.fromARGB(255, 22, 22, 22),
            'surfaceContainerHighest': const Color.fromARGB(255, 22, 22, 22),
            'surfaceContainerLow': const Color.fromARGB(255, 11, 11, 11),
            'surfaceContainerLowest': const Color.fromARGB(255, 8, 8, 8),
            'surfaceDim': const Color.fromARGB(255, 0, 0, 0),
            'surfaceTint': const Color.fromARGB(255, 11, 11, 11),
            'surfaceVariant': const Color.fromARGB(255, 0, 0, 0),
            'background': const Color.fromARGB(255, 0, 0, 0),
          }
        : {};

    final colorScheme = ColorScheme.fromSeed(
      brightness: brightness,
      seedColor: seed ?? Color(AppSettings.colorSchemeSeed.value),
      surface: extraDarkColors['surface'],
      surfaceBright: extraDarkColors['surfaceBright'],
      surfaceContainer: extraDarkColors['surfaceContainer'],
      surfaceContainerHigh: extraDarkColors['surfaceContainerHigh'],
      surfaceContainerHighest: extraDarkColors['surfaceContainerHighest'],
      surfaceContainerLow: extraDarkColors['surfaceContainerLow'],
      surfaceContainerLowest: extraDarkColors['surfaceContainerLowest'],
      surfaceDim: extraDarkColors['surfaceDim'],
      surfaceTint: extraDarkColors['surfaceTint'],
      surfaceVariant: extraDarkColors['surfaceVariant'],
      background: extraDarkColors['background'],
      dynamicSchemeVariant: variant ?? DynamicSchemeVariant.tonalSpot,
    );
    final isColumnMode = FluffyThemes.isColumnMode(context);
    return ThemeData(
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      useSystemColors: true,
      fontFamily: AppSettings.systemFont.value ? 'SystemFont' : null,
      fontFamilyFallback: twemoji == true
          ? ['Twemoji Mozilla', 'SystemFont', 'Roboto']
          : null,
      dividerColor: brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest
          : colorScheme.surfaceContainer,
      popupMenuTheme: PopupMenuThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          iconColor: colorScheme.onSurface,
          disabledIconColor: colorScheme.onSurface,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: colorScheme.onSurface.withAlpha(128),
        selectionHandleColor: colorScheme.secondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      chipTheme: ChipThemeData(
        showCheckmark: false,
        backgroundColor: colorScheme.surfaceContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
      ),
      appBarTheme: AppBarTheme(
        toolbarHeight: isColumnMode ? 72 : 56,
        shadowColor: isColumnMode
            ? colorScheme.surfaceContainer.withAlpha(128)
            : null,
        surfaceTintColor: isColumnMode ? colorScheme.surface : null,
        backgroundColor: isColumnMode ? colorScheme.surface : null,
        actionsPadding: isColumnMode
            ? const EdgeInsets.symmetric(horizontal: 16.0)
            : null,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: brightness.reversed,
          statusBarBrightness: brightness,
          systemNavigationBarIconBrightness: brightness.reversed,
          systemNavigationBarColor: colorScheme.surface,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: 1, color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: colorScheme.primary),
            borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
          ),
        ),
      ),
      snackBarTheme: isColumnMode
          ? const SnackBarThemeData(
              showCloseIcon: true,
              behavior: SnackBarBehavior.floating,
              width: FluffyThemes.columnWidth * 1.5,
            )
          : const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

extension on Brightness {
  Brightness get reversed =>
      this == Brightness.dark ? Brightness.light : Brightness.dark;
}

extension BubbleColorTheme on ThemeData {
  /// Uitgaande bubbel: de containerkleur van het thema.
  ///
  /// Waarom niet een eigen kleur: het thema garandeert voor het paar
  /// (primaryContainer, onPrimaryContainer) minstens 4.5:1. Met de oude
  /// eigen teal (primary gemengd met surface) haalde de berichttekst in
  /// light mode nog maar 4.29:1 — net onder de AA-norm voor kleine tekst.
  /// De containerkleur is bovendien WhatsApp-achtig: een bleke eigen
  /// bubbel op een neutrale achtergrond.
  Color get bubbleColor => colorScheme.primaryContainer;

  /// Tekst op de uitgaande bubbel: het bijbehorende "on"-color van het
  /// thema, dus altijd met de juiste contrastwaarde.
  Color get onBubbleColor => colorScheme.onPrimaryContainer;

  /// Inkomende bubbel. Licht thema: één stap boven surface. Donker thema:
  /// hetzelfde vlak, één stap hoger dan de pagina.
  ///
  /// Was hardcoded WhatsApp-grijs (#1E2225); met surfaceContainerHigh
  /// volgt de bubbel het thema én blijft hij neutraal, zodat de eigen
  /// bubbel de kleur draagt.
  Color get incomingBubbleColor => brightness == Brightness.light
      ? colorScheme.surfaceContainerHighest
      : colorScheme.surfaceContainerHigh;

  /// WhatsApp-style read-receipt blue for the double tick on own messages.
  ///
  /// Helder blauw in dark mode (#53BDEB, zoals WhatsApp) en de donkere
  /// tint van dezelfde blauw in light mode (#1F6FEB). Het lichte ijsblauw
  /// (#B9E7FA) dat hier eerst stond, haalde nog 1.0:1 op de bleke lichte
  /// bubbel en was daarmee onzichtbaar. Beide halen ≥3.0 op hun bubbel,
  /// bewaakt in test/read_receipt_blue_test.dart met de echte themakleuren.
  Color get readReceiptBlue => brightness == Brightness.light
      ? const Color(0xFF1F6FEB)
      : const Color(0xFF53BDEB);

  /// Subtle border for incoming bubbles in light mode so they don't
  /// blend into the background. Dark mode surfaces already have enough
  /// contrast without a border.
  Border? get incomingBubbleBorder => brightness == Brightness.light
      ? Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 0.5,
        )
      : null;

  /// Reply indicator bar color: opacity-based so it blends with any
  /// bubble background.
  Color replyBarColor(bool ownMessage) => ownMessage
      ? onBubbleColor.withValues(alpha: 0.35)
      : colorScheme.primary.withValues(alpha: 0.3);

  Color get secondaryBubbleColor => HSLColor.fromColor(
    brightness == Brightness.light
        ? colorScheme.tertiary
        : colorScheme.tertiaryContainer,
  ).withSaturation(0.5).toColor();

  /// Achtergrond van de invoerbalk-capsule. Donker: vaste WhatsApp-grijs
  /// (#1E2225); licht: surface.
  Color get inputBarColor => brightness == Brightness.light
      ? colorScheme.surface
      : const Color(0xFF1E2225);

  /// Accentkleur voor de invoerbalk (border-highlight bij tekst). Donker:
  /// WhatsApp-teal (#005C53); licht: primair.
  Color get inputBarAccent => brightness == Brightness.light
      ? colorScheme.primary
      : const Color(0xFF005C53);

  /// Achtergrond van de ronde verstuurknop. Een gedempte zeegroene tint
  /// (#1B6E64) in ton-sur-ton stijl, zoals het referentiescreenshot.
  Color get sendButtonColor => const Color(0xFF1B6E64);

  /// Icoonkleur van de verstuurknop: een donkerdere groentint (#0F3D37) voor
  /// een subtiele ton-sur-ton stijl op [sendButtonColor].
  Color get sendButtonIconColor => const Color(0xFF0F3D37);
}
