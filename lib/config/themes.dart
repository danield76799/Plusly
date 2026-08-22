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
  /// Outgoing bubble: primary softened with 20% surface blend (light) so it
  /// is a lighter, lower-strain petrol instead of a solid dark block, or
  /// primaryContainer at 85% opacity (dark) so it doesn't glow on AMOLED.
  Color get bubbleColor => brightness == Brightness.light
      ? Color.lerp(colorScheme.primary, colorScheme.surface, 0.20)!
      // Dark: blend primaryContainer with surface so the bubble is a softer,
      // lower-strain petrol instead of an opaque block against the dark
      // scaffold background.
      : Color.lerp(
          colorScheme.primaryContainer,
          colorScheme.surface,
          0.18,
        )!;

  Color get onBubbleColor => brightness == Brightness.light
      ? colorScheme.onPrimary
      : colorScheme.onPrimaryContainer;

  /// Incoming bubble: one step above surface for clear hierarchy.
  Color get incomingBubbleColor => brightness == Brightness.light
      ? colorScheme.surfaceContainerHighest
      : colorScheme.surfaceContainerHigh;

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
}
