
import 'dart:async';
import 'package:flutter/material.dart';

// import 'package:android_system_font/android_system_font.dart'; // TEMPORARILY DISABLED - causes Kotlin daemon crash on cross-drive builds
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Pulsly/config/routes.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/download_manager/download_manager.dart';
import 'package:Pulsly/utils/check_updates.dart';
import 'package:Pulsly/widgets/app_lock.dart';
import 'package:Pulsly/widgets/background_audio_player.dart';
import 'package:Pulsly/widgets/theme_builder.dart';
import '../config/app_config.dart';
import '../utils/app_text_scale.dart';
import '../utils/custom_scroll_behaviour.dart';
import '../utils/first_launch_setup.dart';
import 'matrix.dart';

class PluslyApp extends StatefulWidget {
  final Widget? testWidget;
  final List<Client> clients;
  final String? pincode;
  final SharedPreferences store;

  const PluslyApp({
    super.key,
    this.testWidget,
    required this.clients,
    required this.store,
    this.pincode,
  });

  /// getInitialLink may rereturn the value multiple times if this view is
  /// opened multiple times for example if the user logs out after they logged
  /// in with qr code or magic link.
  static bool gotInitialLink = false;

  // Router must be outside of build method so that hot reload does not reset
  // the current path.
  //
  // De content://-redirect geldt alleen bij de INITIËLE route-resolutie.
  //
  // Eerder stond hij als onvoorwaardelijke regel: élke navigatie waarvan de
  // target-URI op content:// begon werd teruggezet naar '/'. Dat is nodig om
  // een share-intent niet als GoRouter-route te laten mislukken, MAAR hij
  // vuurde ook midden in een sessie (share-handler + redirect vlogen in het
  //zelfde frame): de routestapel werd herbouwd terwijl de share-dialog route
  // al aan het openen was, en routes die al aan het afsluiten waren werden
  // opnieuw "compleet" gezet → crash "Bad state: Future already completed"
  // in Route.didComplete (gezien bij foto delen vanuit Google Foto's).
  //
  // Nu: alleen de eerste keer (initialLocation-resolutie), daarna neemt de
  // share-handler in chat_list het intent volledig over.
  static bool _initialRouteResolved = false;
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: AppRoutes.routes,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Altijd content:// URIs afvangen (koudstart share-intent).
      // Deze redirect mag elke keer draaien; hij veroorzaakt geen
      // "Future already completed" crash omdat hij NIET in het share-dialog
      // frame vuurt (die navigeert naar /rooms/..., niet content://).
      if (state.uri.scheme == 'content') return '/';

      // Overige redirects slechts één keer (voorkomt herbouw tijdens
      // share-dialog in hetzelfde frame — crash "Bad state: Future already completed").
      if (_initialRouteResolved) return null;
      _initialRouteResolved = true;
      return null;
    },
  );

  @override
  State<PluslyApp> createState() => _PluslyAppState();
}

class _PluslyAppState extends State<PluslyApp> {
  // final _androidSystemFontPlugin = AndroidSystemFont(); // DISABLED
  Timer? _updateCheckTimer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // First-launch setup: ask for notification + battery permissions.
    // Delay so the router/navigator context exists for showing dialogs.
    Future.delayed(const Duration(seconds: 3), () {
      final routerContext =
          PluslyApp.router.routerDelegate.navigatorKey.currentContext;
      if (mounted && routerContext != null) {
        maybeShowFirstLaunchSetup(routerContext);
      }
    });
    // Check for updates on app startup (with delay to let UI load).
    // Use the GoRouter navigator context, not the raw PluslyApp state context,
    // because there is no Navigator above MaterialApp.router yet.
    Future.delayed(const Duration(seconds: 2), () {
      final routerContext =
          PluslyApp.router.routerDelegate.navigatorKey.currentContext;
      if (mounted && routerContext != null) {
        checkForUpdates(routerContext);
      }
    });

    // Repeat update check every 12 hours while the app is running.
    _updateCheckTimer = Timer.periodic(const Duration(hours: 12), (_) {
      final routerContext =
          PluslyApp.router.routerDelegate.navigatorKey.currentContext;
      if (mounted && routerContext != null) {
        checkForUpdates(routerContext);
      }
    });
  }

  @override
  void dispose() {
    _updateCheckTimer?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  // DISABLED - android_system_font plugin causes Kotlin daemon crash on cross-drive builds
  Future<void> initPlatformState() async {
    // Font loading disabled - was using android_system_font plugin
    // if (!mounted) return;
    // setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeBuilder(
      builder:
          (
            context,
            themeMode,
            primaryColor,
            schemeVariant,
            pureBlack,
            twemoji,
          ) => MaterialApp.router(
            title: AppConfig.applicationName,
            themeMode: themeMode,
            theme: FluffyThemes.buildTheme(
              context,
              Brightness.light,
              primaryColor,
              schemeVariant,
              pureBlack,
              twemoji,
            ),
            darkTheme: FluffyThemes.buildTheme(
              context,
              Brightness.dark,
              primaryColor,
              schemeVariant,
              pureBlack,
              twemoji,
            ),
            scrollBehavior: CustomScrollBehavior(),
            localizationsDelegates: L10n.localizationsDelegates,
            supportedLocales: L10n.supportedLocales,
            routerConfig: PluslyApp.router,
            builder: (context, child) => ValueListenableBuilder(
              // De tekstschaal moet de HELE app dekken, dus boven de router —
              // en opnieuw bouwen zodra de schuif in Instellingen → Stijl
              // verschuift, zonder herstart.
              valueListenable: appTextScale,
              builder: (context, factor, _) => AppTextScale(
                factor: factor,
                child: AppLockWidget(
                  pincode: widget.pincode,
                  clients: widget.clients,
                  // Need a navigator above the Matrix widget for
                  // displaying dialogs
                  child: DownloadManager(
                    child: BackgroundAudioPlayer(
                      child: Matrix(
                        clients: widget.clients,
                        store: widget.store,
                        child: widget.testWidget ?? child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
