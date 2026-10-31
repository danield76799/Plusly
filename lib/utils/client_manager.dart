import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:collection/collection.dart';
import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_vodozemac/flutter_vodozemac.dart' as vod;
import 'package:matrix/encryption/utils/key_verification.dart';
import 'package:matrix/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart' as html;

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/custom_http_client.dart';
import 'package:Pulsly/utils/custom_image_resizer.dart';
import 'package:Pulsly/utils/init_with_restore.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/poll_events.dart';
import 'package:Pulsly/utils/push_event_log.dart';
import 'matrix_sdk_extensions/flutter_matrix_dart_sdk_database/builder.dart';

abstract class ClientManager {
  static const String clientNamespace = 'com.danield.plusly.store.clients';

  /// Clients per accountnaam, plus de lopende creaties.
  ///
  /// WAAROM DIT NODIG IS. Elke `createClient` opent de database van dat
  /// account. Opent de database twee keer tegelijk (of terwijl de vorige
  /// nog open is), dan geeft SQLite `SQLITE_MISUSE` op `BEGIN IMMEDIATE`
  /// (code 21). Bij een push-burst — twintig pushes binnen twee seconden
  /// — gebeurde dat precies: de eerste open slaagde, de rest crashte op
  /// het database-openen, waarna de push-verwerking in de catch belande en
  /// de generieke "Nieuw bericht in Plusly"-melding liet verschijnen. Eén
  /// burst leverde zo tientallen van die meldingen.
  ///
  /// Dus: één client per naam, gedeeld door alle aanroepers, en een
  /// lopende creatie wordt hergebruikt in plaats van een tweede te starten.
  static final Map<String, Client> _clients = {};
  static final Map<String, Future<Client>> _creatingClients = {};

  /// Verwijdert de gecachte client van een account (bij uitloggen of
  /// verwijderen), zodat een volgende creatie een verse database opent.
  static void forgetClient(String clientName) {
    _clients.remove(clientName);
  }

  /// Open de clients van meerdere accounts, zonder dat één kapot account de
  /// rest meeneemt.
  ///
  /// Geeft de clients terug die openslaagden, plus de namen van de accounts
  /// die niet openden.
  ///
  /// LET OP: een account dat niet opent wordt NIET uit de store verwijderd.
  /// De database kan tijdelijk op slot staan (migratie, een tweede isolate
  /// die dezelfde file opent) en dan zou de gebruiker stilletjes uit een
  /// werkend account worden gezet. Het account wordt alleen overgeslagen en
  /// gelogd; opruimen doet de gebruiker zelf.
  @visibleForTesting
  static Future<({List<T> clients, List<String> kapot})> openAccounts<T>(
    Iterable<String> names,
    Future<T> Function(String name) open, {
    Duration herhaalPoging = Duration.zero,
  }) async {
    final clients = <T>[];
    final kapot = <String>[];
    for (final name in names) {
      try {
        clients.add(await open(name));
      } catch (e, s) {
        if (herhaalPoging > Duration.zero) {
          try {
            await Future.delayed(herhaalPoging);
            clients.add(await open(name));
            Logs().w('Client $name opende pas bij de tweede poging');
            continue;
          } catch (e2, s2) {
            Logs().e('Client $name faalde ook bij de tweede poging', e2, s2);
          }
        }
        kapot.add(name);
        Logs().e('Client $name kon niet worden geopend, overgeslagen', e, s);
      }
    }
    return (clients: clients, kapot: kapot);
  }

  static Future<List<Client>> getClients({
    bool initialize = true,
    required SharedPreferences store,
  }) async {
    final clientNames = <String>{};
    try {
      final clientNamesList = store.getStringList(clientNamespace) ?? [];
      clientNames.addAll(clientNamesList);
    } catch (e, s) {
      Logs().w('Client names in store are corrupted', e, s);
      await store.remove(clientNamespace);
    }
    if (clientNames.isEmpty) {
      clientNames.add(PlatformInfos.clientName);
      await store.setStringList(clientNamespace, clientNames.toList());
    }
    // EEN KAPOTTE ACCOUNT MAG DE REST NIET MEENEMEN.
    //
    // `Future.wait` faalt op de eerste fout. Als één account zijn database
    // niet kan openen (bijvoorbeeld een uitgelogd account, of een database
    // die even op slot staat doordat de push-isolate dezelfde file opende),
    // dan gooit deze hele lijst weg — inclusief de accounts die prima zijn.
    // Dat was de oorzaak van het doodgaan van het pushkanaal: bij elke
    // start crashte het ophalen van de clients, waardoor de pushers bij de
    // homeserver nooit werden hersteld en er geen enkele push binnenkwam.
    //
    // Dus: per account apart, fouten isoleren. Het account wordt alleen
    // overgeslagen, niet uit de store gehaald (zie openAccounts).
    final geopend = await openAccounts(
      clientNames,
      (name) => createClient(name, store),
    );
    final clients = geopend.clients;
    final kapotteAccounts = geopend.kapot;
    if (kapotteAccounts.isNotEmpty) {
      Logs().w(
        'Accounts overgeslagen omdat hun database niet opent: '
        '${kapotteAccounts.join(', ')}',
      );
      // Zichtbaar maken in de push-diagnose: anders valt het weg zonder
      // dat iemand merkt waarom een account geen meldingen meer krijgt.
      PushEventLog().add('client_skipped', {
        'accounts': kapotteAccounts.join(', '),
      });
    }
    if (clients.isEmpty) {
      throw StateError(
        'Geen enkel account kon worden geopend '
        '(kapot: ${kapotteAccounts.join(', ')})',
      );
    }
    if (initialize) {
      await Future.wait(
        clients.map(
          (client) => client
              .initWithRestore(
                onMigration: () async {
                  final l10n = await lookupL10n(
                    PlatformDispatcher.instance.locale,
                  );
                  sendInitNotification(
                    l10n.databaseMigrationTitle,
                    l10n.databaseMigrationBody,
                  );
                },
              )
              .catchError(
                (e, s) => Logs().e('Unable to initialize client', e, s),
              ),
        ),
      );
    }
    if (clients.length > 1 && clients.any((c) => !c.isLogged())) {
      final loggedOutClients = clients.where((c) => !c.isLogged()).toList();
      for (final client in loggedOutClients) {
        Logs().w(
          'Multi account is enabled but client ${client.userID} is not logged in. Removing...',
        );
        clientNames.remove(client.clientName);
        clients.remove(client);
      }
      await store.setStringList(clientNamespace, clientNames.toList());
    }
    return clients;
  }

  static Future<void> addClientNameToStore(
    String clientName,
    SharedPreferences store,
  ) async {
    final clientNamesList = store.getStringList(clientNamespace) ?? [];
    clientNamesList.add(clientName);
    await store.setStringList(clientNamespace, clientNamesList);
  }

  static Future<void> removeClientNameFromStore(
    String clientName,
    SharedPreferences store,
  ) async {
    final clientNamesList = store.getStringList(clientNamespace) ?? [];
    clientNamesList.remove(clientName);
    await store.setStringList(clientNamespace, clientNamesList);
  }

  static NativeImplementations get nativeImplementations => kIsWeb
      ? const NativeImplementationsDummy()
      : NativeImplementationsIsolate(
          compute,
          vodozemacInit: () => vod.init(wasmPath: './assets/assets/vodozemac/'),
        );

  static Future<Client> createClient(
    String clientName,
    SharedPreferences store,
  ) {
    // Zie de uitleg bij [_clients]: één client per account, en een lopende
    // creatie wordt gedeeld. Anders opent elke push de database opnieuw.
    final bestaand = _clients[clientName];
    if (bestaand != null) return Future.value(bestaand);
    final lopend = _creatingClients[clientName];
    if (lopend != null) return lopend;
    final future = _createClient(clientName, store);
    _creatingClients[clientName] = future;
    future
        .then((client) {
          if (identical(_creatingClients[clientName], future)) {
            _creatingClients.remove(clientName);
            _clients[clientName] = client;
          }
        })
        .catchError((e, s) {
          if (identical(_creatingClients[clientName], future)) {
            _creatingClients.remove(clientName);
          }
          Logs().e('Unable to create client $clientName', e, s);
          // De fout gaat door naar de aanroeper; de push-verwerking vangt
          // hem op.
          throw e;
        });
    return future;
  }

  static Future<Client> _createClient(
    String clientName,
    SharedPreferences store,
  ) async {
    final shareKeysWith = AppSettings.shareKeysWith.value;
    final enableSoftLogout = AppSettings.enableSoftLogout.value;

    return Client(
      clientName,
      httpClient: CustomHttpClient.createHTTPClient(),
      verificationMethods: {
        KeyVerificationMethod.numbers,
        if (kIsWeb || PlatformInfos.isMobile || PlatformInfos.isLinux)
          KeyVerificationMethod.emoji,
      },
      importantStateEvents: <String>{
        // To make room emotes work
        'im.ponies.room_emotes',
      },
      roomPreviewLastEvents: <String>{
        EventTypes.Message,
        EventTypes.Encrypted,
        EventTypes.Sticker,
        EventTypes.CallInvite,
        EventTypes.CallAnswer,
        EventTypes.CallReject,
        EventTypes.CallHangup,
        EventTypes.GroupCallMember,
        PollEvents.pollStart,
      },
      logLevel: kReleaseMode ? Level.warning : Level.verbose,
      database: await flutterMatrixSdkDatabaseBuilder(clientName),
      supportedLoginTypes: {
        AuthenticationTypes.password,
        AuthenticationTypes.sso,
      },
      nativeImplementations: nativeImplementations,
      customImageResizer: PlatformInfos.isMobile ? customImageResizer : null,
      defaultNetworkRequestTimeout: const Duration(minutes: 5),
      // Upload-timeout: de SDK-standaard is 1 minuut, wat te kort is voor
      // grote video's (zelfs gecomprimeerd) bij trage verbindingen. 10 minuten
      // geeft de upload voldoende ruimte om te voltooien of correct te falen.
      sendTimelineEventTimeout: const Duration(minutes: 10),
      enableDehydratedDevices: true,
      shareKeysWith:
          ShareKeysWith.values.singleWhereOrNull(
            (share) => share.name == shareKeysWith,
          ) ??
          ShareKeysWith.all,
      convertLinebreaksInFormatting: false,
      onSoftLogout: enableSoftLogout
          ? (client) => client.refreshAccessToken()
          : null,
    );
  }

  static void sendInitNotification(String title, String body) async {
    if (kIsWeb) {
      html.Notification(title, body: body);
      return;
    }
    if (Platform.isLinux) {
      await NotificationsClient().notify(
        title,
        body: body,
        appName: AppConfig.applicationName,
        hints: [NotificationHint.soundName('message-new-instant')],
      );
      return;
    }

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('notifications_icon'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    flutterLocalNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'error_message',
          'Error Messages',
          importance: Importance.high,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(sound: 'notification.caf'),
      ),
    );
  }
}
